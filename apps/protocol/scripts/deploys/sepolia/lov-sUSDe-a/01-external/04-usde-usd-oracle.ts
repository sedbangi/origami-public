import '@nomiclabs/hardhat-ethers';
import { ethers } from 'hardhat';
import { RelayedOracle, RelayedOracle__factory } from '../../../../../typechain';
import {
  blockTimestamp,
  deployAndMine,
  ensureExpectedEnvvars,
} from '../../../helpers';

async function main() {
  ensureExpectedEnvvars();
  const [owner] = await ethers.getSigners();

  const answer: RelayedOracle.AnswerStruct = {
    roundId: 1,
    answer: ethers.utils.parseUnits("1.00159255", 8),
    startedAt: 0,
    updatedAt: await blockTimestamp(),
    answeredInRound: 1
  };

  const factory = new RelayedOracle__factory(owner);
  await deployAndMine(
    'EXTERNAL.REDSTONE.USDE_USD_ORACLE',
    factory,
    factory.deploy,
    "USDe/USD",
    answer,
    8,
  );
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });