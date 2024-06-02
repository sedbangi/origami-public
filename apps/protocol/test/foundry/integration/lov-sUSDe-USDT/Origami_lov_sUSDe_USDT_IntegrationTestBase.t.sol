pragma solidity 0.8.19;
// SPDX-License-Identifier: AGPL-3.0-or-later

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { IOrigamiInvestment } from "contracts/interfaces/investments/IOrigamiInvestment.sol";
import { IOrigamiOracle } from "contracts/interfaces/common/oracle/IOrigamiOracle.sol";
import { IOrigamiLovTokenMorphoManager } from "contracts/interfaces/investments/lovToken/managers/IOrigamiLovTokenMorphoManager.sol";

import { OrigamiTest } from "test/foundry/OrigamiTest.sol";
import { OrigamiMath } from "contracts/libraries/OrigamiMath.sol";
import { ExternalContracts, LovTokenContracts, Origami_lov_sUSDe_USDT_TestDeployer } from "test/foundry/deploys/lov-sUSDe-USDT/Origami_lov_sUSDe_USDT_TestDeployer.t.sol";
import { LovTokenHelpers } from "test/foundry/libraries/LovTokenHelpers.t.sol";
import { IMorpho } from "@morpho-org/morpho-blue/src/interfaces/IMorpho.sol";

contract Origami_lov_sUSDe_USDT_IntegrationTestBase is OrigamiTest {
    using OrigamiMath for uint256;

    error BadSwapParam(uint256 expected, uint256 found);
    error UnknownSwapAmount_BorrowToReserve(uint256 amount);
    error UnknownSwapAmount_ReserveToBorrow(uint256 amount);
    error InvalidRebalanceUpParam();
    error InvalidRebalanceDownParam();

    Origami_lov_sUSDe_USDT_TestDeployer internal deployer;
    ExternalContracts public externalContracts;
    LovTokenContracts public lovTokenContracts;

    function setUp() public virtual {
        fork("mainnet", 19506752);
        vm.warp(1711311924);

        deployer = new Origami_lov_sUSDe_USDT_TestDeployer(); 
        origamiMultisig = address(deployer);
        (externalContracts, lovTokenContracts) = deployer.deployForked(origamiMultisig, feeCollector, overlord);

        // Bootstrap the morpho pool with some USDT
        supplyIntoMorpho(500_000e6);
    }

    function supplyIntoMorpho(uint256 amount) internal {
        doMint(externalContracts.usdtToken, origamiMultisig, amount);
        vm.startPrank(origamiMultisig);
        IMorpho morpho = lovTokenContracts.borrowLend.morpho();
        SafeERC20.forceApprove(externalContracts.usdtToken, address(morpho), amount);
        morpho.supply(lovTokenContracts.borrowLend.getMarketParams(), amount, 0, origamiMultisig, "");
        vm.stopPrank();
    }

    function investLovToken(address account, uint256 amount) internal returns (uint256 amountOut) {
        doMint(externalContracts.sUsdeToken, account, amount);
        vm.startPrank(account);
        externalContracts.sUsdeToken.approve(address(lovTokenContracts.lovToken), amount);

        (IOrigamiInvestment.InvestQuoteData memory quoteData, ) = lovTokenContracts.lovToken.investQuote(
            amount,
            address(externalContracts.sUsdeToken),
            0,
            0
        );

        amountOut = lovTokenContracts.lovToken.investWithToken(quoteData);
    }

    function exitLovToken(address account, uint256 amount, address recipient) internal returns (uint256 amountOut) {
        vm.startPrank(account);

        (IOrigamiInvestment.ExitQuoteData memory quoteData, ) = lovTokenContracts.lovToken.exitQuote(
            amount,
            address(externalContracts.sUsdeToken),
            0,
            0
        );

        amountOut = lovTokenContracts.lovToken.exitToToken(quoteData, recipient);
    }

    function rebalanceDownParams(
        uint256 targetAL,
        uint256 swapSlippageBps,
        uint256 alSlippageBps
    ) internal virtual view returns (
        IOrigamiLovTokenMorphoManager.RebalanceDownParams memory params,
        uint256 reservesAmount
    ) {
        reservesAmount = LovTokenHelpers.solveRebalanceDownAmount(
            lovTokenContracts.lovTokenManager, 
            targetAL
        );

        // Use the oracle price (and scale for USDC)
        // Round down to be conservative on how much is borrowed
        params.borrowAmount = lovTokenContracts.sUsdeToUsdtOracle.convertAmount(
            address(externalContracts.sUsdeToken),
            reservesAmount,
            IOrigamiOracle.PriceType.SPOT_PRICE,
            OrigamiMath.Rounding.ROUND_DOWN
        );

        (reservesAmount, params.swapData) = swapBorrowTokenToReserveTokenQuote(params.borrowAmount);
        params.supplyAmount = reservesAmount.subtractBps(swapSlippageBps, OrigamiMath.Rounding.ROUND_DOWN);

        params.minNewAL = uint128(targetAL.subtractBps(alSlippageBps, OrigamiMath.Rounding.ROUND_DOWN));
        params.maxNewAL = uint128(targetAL.addBps(alSlippageBps, OrigamiMath.Rounding.ROUND_UP));

        // When to sweep surplus balances and supply as collateral
        params.supplyCollateralSurplusThreshold = 0;
    }

    // Increase liabilities to lower A/L
    function doRebalanceDown(
        uint256 targetAL, 
        uint256 slippageBps, 
        uint256 alSlippageBps
    ) internal virtual returns (uint256 reservesAmount) {
        IOrigamiLovTokenMorphoManager.RebalanceDownParams memory params;
        (params, reservesAmount) = rebalanceDownParams(targetAL, slippageBps, alSlippageBps);

        vm.startPrank(origamiMultisig);
        lovTokenContracts.lovTokenManager.rebalanceDown(params);
    }
    
    function rebalanceUpParams(
        uint256 targetAL,
        uint256 swapSlippageBps,
        uint256 alSlippageBps
    ) internal virtual view returns (
        IOrigamiLovTokenMorphoManager.RebalanceUpParams memory params
    ) {
        // ideal reserves (sUSDe) amount to remove
        params.withdrawCollateralAmount = LovTokenHelpers.solveRebalanceUpAmount(lovTokenContracts.lovTokenManager, targetAL);

        (params.repayAmount, params.swapData) = swapReserveTokenToBorrowTokenQuote(params.withdrawCollateralAmount);

        // If there's a fee (currently disabled on Spark) then remove that from what we want to request
        uint256 feeBps = 0;
        params.repayAmount = params.repayAmount.inverseSubtractBps(feeBps, OrigamiMath.Rounding.ROUND_UP);

        // Apply slippage to the amount what's actually flashloaned is the lowest amount which
        // we would get when converting the collateral [sUSDe] to the flashloan asset [wETH].
        // We need to be sure it can be paid off. Any remaining wETH is repaid on the wETH debt in Spark
        params.repayAmount = params.repayAmount.subtractBps(swapSlippageBps, OrigamiMath.Rounding.ROUND_DOWN);

        // When to sweep surplus balances and repay
        params.repaySurplusThreshold = 0;

        params.minNewAL = uint128(targetAL.subtractBps(alSlippageBps, OrigamiMath.Rounding.ROUND_DOWN));
        params.maxNewAL = uint128(targetAL.addBps(alSlippageBps, OrigamiMath.Rounding.ROUND_UP));
    }

    // Decrease liabilities to raise A/L
    function doRebalanceUp(
        uint256 targetAL, 
        uint256 slippageBps, 
        uint256 alSlippageBps
    ) internal virtual {
        IOrigamiLovTokenMorphoManager.RebalanceUpParams memory params = rebalanceUpParams(targetAL, slippageBps, alSlippageBps);
        vm.startPrank(origamiMultisig);

        lovTokenContracts.lovTokenManager.rebalanceUp(params);
    }

    function swapBorrowTokenToReserveTokenQuote(uint256 borrowAmount) internal pure returns (uint256 reservesAmount, bytes memory swapData) {
        // @note Ensure sDAI is listed as a connector token

        // REQUEST:
        /*
        curl -X GET \
"https://api.1inch.dev/swap/v5.2/1/swap?src=0xdAC17F958D2ee523a2206206994597C13D831ec7&dst=0x9D39A5DE30e57443BfF2A8307A4256c8797A3497&amount=155648216&from=0x0000000000000000000000000000000000000000&slippage=50&disableEstimate=true&connectorTokens=0x83F20F44975D03b1b09e64809B757c47f942BEeA" \
-H "Authorization: Bearer PinnqIP4n9rxYRndzIyWDVrMfmGKUbZG" \
-H "accept: application/json" \
-H "content-type: application/json"
        */

        if (borrowAmount == 155_628.853120e6) {
            reservesAmount = 150_535.684173820153362235e18;
            swapData = hex"12aa3caf000000000000000000000000e37e799d5077682fa0a244d46e5649f71457bd09000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec70000000000000000000000009d39a5de30e57443bff2a8307a4256c8797a3497000000000000000000000000e37e799d5077682fa0a244d46e5649f71457bd090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000243c33d780000000000000000000000000000000000000000000000ff0472427ed174c7b9d0000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000001600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028c00000000000000000000000000000000000000000000000000000000026e00a007e5c0d200000000000000000000000000000000000000024a00017a0000ca0000b05120d632f22692fac7611d2aa1c0d552930d43caed3bdac17f958d2ee523a2206206994597c13d831ec70044a6417ed600000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000107f9acb25fbae4a132a0020d6bdbf78853d955acef822db058eb8505911ed77f175b99e5120ce6431d21e3fb1036ce9973a3312368ed96f5ce7853d955acef822db058eb8505911ed77f175b99e00443df02124000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f7537ff64081248a14b5120167478921b907422f8e88b43c4af2b8bea278d3a83f20f44975d03b1b09e64809b757c47f942beea0044ddc1f59d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff0472427ed174c7b9d0000000000000000000000001111111254eeb25477b68fb85ed929f73a96058200000000000000000000000000000000000000008b1ccac8";
        } else if (borrowAmount == 311_218.950064e6) {
            reservesAmount = 300_990.440107446778884199e18;
            swapData = hex"12aa3caf000000000000000000000000e37e799d5077682fa0a244d46e5649f71457bd09000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec70000000000000000000000009d39a5de30e57443bff2a8307a4256c8797a3497000000000000000000000000e37e799d5077682fa0a244d46e5649f71457bd0900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004876184fb0000000000000000000000000000000000000000000001fde5cbae1032a3d3833000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003090000000000000000000000000000000000000000000000000000000002eb00a007e5c0d20000000000000000000000000000000000000002c70001f700014700012d00a0c9e75c4800000000000000002a080000000000000000000000000000000000000000000000000000ff00004f02a00000000000000000000000000000000000000000000005476143ea4dfbbfc7aeee63c1e500c2a856c3aff2110c1171b8f942256d40e980c726dac17f958d2ee523a2206206994597c13d831ec75120d632f22692fac7611d2aa1c0d552930d43caed3bdac17f958d2ee523a2206206994597c13d831ec70044a6417ed6000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001bb5fb2063b87e813b5c0020d6bdbf78853d955acef822db058eb8505911ed77f175b99e5120ce6431d21e3fb1036ce9973a3312368ed96f5ce7853d955acef822db058eb8505911ed77f175b99e00443df02124000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ee894a7da0377ab3b615120167478921b907422f8e88b43c4af2b8bea278d3a83f20f44975d03b1b09e64809b757c47f942beea0044ddc1f59d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001fde5cbae1032a3d38330000000000000000000000001111111254eeb25477b68fb85ed929f73a96058200000000000000000000000000000000000000000000008b1ccac8";
        } else if (borrowAmount == 312_218.950065e6) {
            reservesAmount = 301_952.391867708703011149e18;
            swapData = hex"12aa3caf000000000000000000000000e37e799d5077682fa0a244d46e5649f71457bd09000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec70000000000000000000000009d39a5de30e57443bff2a8307a4256c8797a3497000000000000000000000000e37e799d5077682fa0a244d46e5649f71457bd09000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000048b1b319b1000000000000000000000000000000000000000000001ff86f9c77ac0b1838a6000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003090000000000000000000000000000000000000000000000000000000002eb00a007e5c0d20000000000000000000000000000000000000002c70001f700014700012d00a0c9e75c4800000000000000002a080000000000000000000000000000000000000000000000000000ff00004f02a000000000000000000000000000000000000000000000054bb8b14e0b72345a94ee63c1e500c2a856c3aff2110c1171b8f942256d40e980c726dac17f958d2ee523a2206206994597c13d831ec75120d632f22692fac7611d2aa1c0d552930d43caed3bdac17f958d2ee523a2206206994597c13d831ec70044a6417ed6000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001bccc4271f507587afd90020d6bdbf78853d955acef822db058eb8505911ed77f175b99e5120ce6431d21e3fb1036ce9973a3312368ed96f5ce7853d955acef822db058eb8505911ed77f175b99e00443df02124000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f01eabc30c83d7122e35120167478921b907422f8e88b43c4af2b8bea278d3a83f20f44975d03b1b09e64809b757c47f942beea0044ddc1f59d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ff86f9c77ac0b1838a60000000000000000000000001111111254eeb25477b68fb85ed929f73a96058200000000000000000000000000000000000000000000008b1ccac8";
        } else if (borrowAmount == 155.648216e6) {
            reservesAmount = 150.604567441654225485e18;
            swapData = hex"12aa3caf000000000000000000000000e37e799d5077682fa0a244d46e5649f71457bd09000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec70000000000000000000000009d39a5de30e57443bff2a8307a4256c8797a3497000000000000000000000000e37e799d5077682fa0a244d46e5649f71457bd09000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000094700d80000000000000000000000000000000000000000000000041507741353948d26000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002110000000000000000000000000000000000000000000000000000000001f300a007e5c0d20000000000000000000000000000000000000000000001cf0000ff00004f02a000000000000000000000000000000000000000000000000439b20066c1887a54ee63c1e500c2a856c3aff2110c1171b8f942256d40e980c726dac17f958d2ee523a2206206994597c13d831ec75120ce6431d21e3fb1036ce9973a3312368ed96f5ce7853d955acef822db058eb8505911ed77f175b99e00443df02124000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f5778521163c76a95120c559f6716d8b1471fc2dc10aafeb0faa219fe9df83f20f44975d03b1b09e64809b757c47f942beea0044ddc1f59d0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041507741353948d260000000000000000000000001111111254eeb25477b68fb85ed929f73a9605820000000000000000000000000000008b1ccac8";
        } else {
            revert UnknownSwapAmount_BorrowToReserve(borrowAmount);
        }
    }

    function swapReserveTokenToBorrowTokenQuote(uint256 reservesAmount) internal pure returns (uint256 borrowAmount, bytes memory swapData) {
        // @note Ensure sDAI is listed as a connector token

        // REQUEST:
        /*
        curl -X GET \
"https://api.1inch.dev/swap/v5.2/1/swap?src=0x9D39A5DE30e57443BfF2A8307A4256c8797A3497&dst=0xdAC17F958D2ee523a2206206994597C13D831ec7&amount=301952391867708703011149&from=0x0000000000000000000000000000000000000000&slippage=50&disableEstimate=true&connectorTokens=0x83F20F44975D03b1b09e64809B757c47f942BEeA" \
-H "Authorization: Bearer PinnqIP4n9rxYRndzIyWDVrMfmGKUbZG" \
-H "accept: application/json" \
-H "content-type: application/json"
        */
        
        if (reservesAmount == 9_603.209225168388116125e18) {
            borrowAmount = 9_909.827253e6;
            swapData = hex"12aa3caf000000000000000000000000e37e799d5077682fa0a244d46e5649f71457bd090000000000000000000000009d39a5de30e57443bff2a8307a4256c8797a3497000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec7000000000000000000000000e37e799d5077682fa0a244d46e5649f71457bd090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000208974cc64ebc044e9d000000000000000000000000000000000000000000000000000000012755fb5a0000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000001600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000026900000000000000000000000000000000000000000000024b00021d0001d300a007e5c0d20000000000000000000000000000000000000000000001af0001600000b05120167478921b907422f8e88b43c4af2b8bea278d3a9d39a5de30e57443bff2a8307a4256c8797a349700443df021240000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fc52e061c7123e92f05120ce6431d21e3fb1036ce9973a3312368ed96f5ce783f20f44975d03b1b09e64809b757c47f942beea00443df0212400000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010d40b2383acff1b1ae02a0000000000000000000000000000000000000000000000000000000012755fb5aee63c1e501c2a856c3aff2110c1171b8f942256d40e980c726853d955acef822db058eb8505911ed77f175b99e00a0f2fa6b66dac17f958d2ee523a2206206994597c13d831ec7000000000000000000000000000000000000000000000000000000024eabf6b5000000000000000000000000004c72c880a06c4eca27dac17f958d2ee523a2206206994597c13d831ec71111111254eeb25477b68fb85ed929f73a96058200000000000000000000000000000000000000000000008b1ccac8";
        } else if (reservesAmount == 301_952.391867708703011149e18) {
            borrowAmount = 311_465.810818e6;
            swapData = hex"12aa3caf000000000000000000000000e37e799d5077682fa0a244d46e5649f71457bd090000000000000000000000009d39a5de30e57443bff2a8307a4256c8797a3497000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec7000000000000000000000000e37e799d5077682fa0a244d46e5649f71457bd090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003ff0df38ef581630714d0000000000000000000000000000000000000000000000000000002442678dc1000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003610000000000000000000000000000000000000003430003150002cb0002b100a007e5c0d200000000000000000000000000000000000000000000028d0001600000b05120167478921b907422f8e88b43c4af2b8bea278d3a9d39a5de30e57443bff2a8307a4256c8797a349700443df02124000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001efd5059cb8f4dbc396b5120ce6431d21e3fb1036ce9973a3312368ed96f5ce783f20f44975d03b1b09e64809b757c47f942beea00443df0212400000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000211185443bca664f0ea000a0c9e75c48000000000000000029090000000000000000000000000000000000000000000000000000ff00004f02a000000000000000000000000000000000000000000000000000000006869f2029ee63c1e501c2a856c3aff2110c1171b8f942256d40e980c726853d955acef822db058eb8505911ed77f175b99e5120d632f22692fac7611d2aa1c0d552930d43caed3b853d955acef822db058eb8505911ed77f175b99e0044a6417ed60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dbbc86d970020d6bdbf78dac17f958d2ee523a2206206994597c13d831ec700a0f2fa6b66dac17f958d2ee523a2206206994597c13d831ec70000000000000000000000000000000000000000000000000000004884cf1b82000000000000000000000000004c582680a06c4eca27dac17f958d2ee523a2206206994597c13d831ec71111111254eeb25477b68fb85ed929f73a960582000000000000000000000000000000000000000000000000000000000000008b1ccac8";
        } else {
            revert UnknownSwapAmount_ReserveToBorrow(reservesAmount);
        }
    }
}
