import { ContractAddresses } from "./types";

export const CONTRACTS: ContractAddresses = {
  CORE: {
    MULTISIG: '0x781B4c57100738095222bd92D37B07ed034AB696',
    FEE_COLLECTOR: '0x781B4c57100738095222bd92D37B07ed034AB696',
    TOKEN_PRICES: '0x76Cf788606F3d968B93B8A243D0e185C974EE407',
  },
  ORACLES: {
    USDE_DAI: '0x39CfDbEfe1e7ccF0665675a3c3f6469b61dD32F5',
    SUSDE_DAI: '0x784f75C39bD7D3EBC377e64991e99178341c831D',
    WEETH_WETH: '0xE0Db69920e90CA56E29F71b7F566655De923c32B',
    EZETH_WETH: '0x28c26e682e26486F311134e5102723c0F1342215',
    STETH_WETH: '0x1B184454E6C02370927789A3564f9D16368d55E4',
    WSTETH_WETH: '0x2848d944EAB78C3ABf02C89fF97f1652A0FBaD77',
  },
  SWAPPERS: {
    ERC4626_AND_1INCH_SWAPPER: '0xe488A643E4b0Aaae60E4bdC02045a10d8a323bae',
    DIRECT_1INCH_SWAPPER: '0x5bf1030503107Db67c3047a4f05439BcFBb40234',
  },
  FLASHLOAN_PROVIDERS: {
    SPARK: '0x88469316c5f828b4Dfd11C4d8529CD9F96b2E006',
  },
  LOV_SUSDE_A: {
    OVERLORD_WALLET: '0xd42c38b2cebb59e77fc985d0cb0d340f15053bcd',
    MORPHO_BORROW_LEND: '0xb48aC9c5585e5F3c88c63CF9bcbAEdC921F76Df2',
    TOKEN: '0x7FC862A47BBCDe3812CA772Ae851d0A9D1619eDa',
    MANAGER: '0x0b53Afe5de9f9df65C3Fe8A9DA81dC410d14d4d4',
  },
  LOV_SUSDE_B: {
    OVERLORD_WALLET: '0xca0678c3a9b1acb50276245ddda06c91ab072fdd',
    MORPHO_BORROW_LEND: '0xEfc8eDaA7cFd0Cf272a0f55de37d62F0ADFb7e93',
    TOKEN: '0xE567DCf433F97d787dF2359bDBF95dFd2B7aBF4E',
    MANAGER: '0x7D7609bF7c3A3c91D524C718FcBfD93398C76603',
  },
  LOV_USDE_A: {
    OVERLORD_WALLET: '0xebf8629d589d5c6ef1ec055c1fa41ecb5c6e5c4f',
    MORPHO_BORROW_LEND: '0x550433C439f92C2f8068b375D8a4ec8d2Dc98299',
    TOKEN: '0xC65a88A7b7752873a3106BD864BBCd717e35d2e5',
    MANAGER: '0x2eC7777838A49E2C83152d455B3CA753c6d08b79',
  },
  LOV_USDE_B: {
    OVERLORD_WALLET: '0xcd745c7eb39472c804db981b1829c99ce0b26ce0',
    MORPHO_BORROW_LEND: '0xC8a26A2ddC176E02A8FD67cB3c8548aA6c8bE32C',
    TOKEN: '0x9fA6D162E32A08B323ADEaE2560F0E44D6dBE53c',
    MANAGER: '0x5383bfABbfCF670cEAC0C7cAd0e5E0a141B23b79',
  },
  LOV_WEETH_A: {
    OVERLORD_WALLET: '0x40557e20e0ffb01849782a09fcb681d5e8d9d229',
    MORPHO_BORROW_LEND: '0xF919e7a09d6c9dC2db9c3DdD9c667ed5949C322c',
    TOKEN: '0x9C1F7237480c030Cb14375Ff6b650606248A5247',
    MANAGER: '0x43947Fe908C9C1F9F64857C2429bF2bb1DD0D111',
  },
  LOV_EZETH_A: {
    OVERLORD_WALLET: '0xd9a1febccb928e6205952a167808d867567d5c92',
    MORPHO_BORROW_LEND: '0xc766e69258408d77967f9a9eB9065B69700D0DeC',
    TOKEN: '0xFbd65E8c1C191F697598307d4E907CDA3CffE33f',
    MANAGER: '0x86142891d70910DceC62c3aBd3c0b5eAD43A02F2',
  },
  LOV_WSTETH_A: {
    OVERLORD_WALLET: '0x46167be270f2b44fbfa8b22d7226c520b943d037',
    TOKEN: '0x117b36e79aDadD8ea81fbc53Bfc9CD33270d845D',
    SPARK_BORROW_LEND: '0xAeDddb1e7be3b22f328456479Eb8321E3eff212E',
    MANAGER: '0xC9632e9CBdEE643Bc490572DD0750EA394E8e3a9',
  },
  EXTERNAL: {
    WETH_TOKEN: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
    MAKER_DAO: {
      DAI_TOKEN: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
      SDAI_TOKEN: '0x83F20F44975D03b1b09e64809B757c47f942BEeA',
    },
    ETHENA: {
      USDE_TOKEN: '0x4c9EDD5852cd905f086C759E8383e09bff1E68B3',
      SUSDE_TOKEN: '0x9D39A5DE30e57443BfF2A8307A4256c8797A3497',
    },
    ETHERFI: {
      WEETH_TOKEN: '0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee',
      LIQUIDITY_POOL: '0x308861A430be4cce5502d0A12724771Fc6DaF216',
    },
    RENZO: {
      EZETH_TOKEN: '0xbf5495Efe5DB9ce00f80364C8B423567e58d2110',
      RESTAKE_MANAGER: '0x74a09653A083691711cF8215a6ab074BB4e99ef5',
    },
    LIDO: {
      STETH_TOKEN: '0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84',
      WSTETH_TOKEN: '0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0',
    },
    REDSTONE: {
      USDE_USD_ORACLE: '0xbC5FBcf58CeAEa19D523aBc76515b9AEFb5cfd58',
      SUSDE_USD_ORACLE: '0xb99D174ED06c83588Af997c8859F93E83dD4733f',
      WEETH_WETH_ORACLE: '0x8751F736E94F6CD167e8C5B97E245680FbD9CC36',
      WEETH_USD_ORACLE: '0xdDb6F90fFb4d3257dd666b69178e5B3c5Bf41136',
      EZETH_WETH_ORACLE: '0xF4a3e183F59D2599ee3DF213ff78b1B3b1923696',
    },
    CHAINLINK: {
      ETH_USD_ORACLE: '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419',
      STETH_ETH_ORACLE: '0x86392dC19c0b719886221c78AB11eb8Cf5c52812',
    },
    SPARK: {
      POOL_ADDRESS_PROVIDER: '0x02C3eA4e34C0cBd694D2adFa2c690EECbC1793eE',
    },
    MORPHO: {
      SINGLETON: '0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb',
      IRM: '0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC',
      ORACLE: {
        SUSDE_DAI: '0x5D916980D5Ae1737a8330Bf24dF812b2911Aae25',
        USDE_DAI: '0xaE4750d0813B5E37A51f7629beedd72AF1f9cA35',
        WEETH_WETH: '0x3fa58b74e9a8eA8768eb33c8453e9C2Ed089A40a',
        EZETH_WETH: '0x61025e2B0122ac8bE4e37365A4003d87ad888Cc3',
      },
    },
    ONE_INCH: {
      ROUTER_V6: '0x111111125421cA6dc452d289314280a0f8842A65',
    },
  },
}
