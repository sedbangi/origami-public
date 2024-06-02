import { ContractAddresses } from "./types";

export const CONTRACTS: ContractAddresses = {
  CORE: {
    MULTISIG: '0xF8Ab0fF572e48059c45eF3fa804e5A369d2b9b2B',
    FEE_COLLECTOR: '0xF8Ab0fF572e48059c45eF3fa804e5A369d2b9b2B',
    OVERLORD: '0xe8840056fb0f1cb7f5645578bf37ab16ed8b8e4b',
    CIRCUIT_BREAKER_PROXY: '0x8A791620dd6260079BF849Dc5567aDC3F2FdC318',
    TOKEN_PRICES: '0x610178dA211FEF7D417bC0e6FeD39F05609AD788',
    SWAPPER_1INCH: '0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e',
  },
  OV_USDC: {
    TOKENS: {
      OV_USDC_TOKEN: '0x9A9f2CCfdE556A7E9Ff0848998Aa4a0CFD8863AE',
      O_USDC_TOKEN: '0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1',
      IUSDC_DEBT_TOKEN: '0x0B306BF915C4d645ff596e518fAf3F9669b97016',
    },
    SUPPLY: {
      SUPPLY_MANAGER: '0x68B1D87F95878fE05B998F19b66F4baba5De1aed',
      REWARDS_MINTER: '0x4ed7c70F96B99c776995fB64377f0d4aB3B0e1C1',
      IDLE_STRATEGY_MANAGER: '0x9A676e781A523b5d0C0e43731313A708CB607508',
      AAVE_V3_IDLE_STRATEGY: '0xa85233C63b9Ee964Add6F2cffe00Fd84eb32338f',
    },
    BORROW: {
      LENDING_CLERK: '0x322813Fd9A801c5507c9de605d63CEA4f2CE6c44',
      CIRCUIT_BREAKER_USDC_BORROW: '0x3Aa5ebB10DC797CAC828524e59A333d0A371443c',
      CIRCUIT_BREAKER_OUSDC_EXIT: '0xc6e7DF5E7b4f2A278906862b61205850344D4e7d',
      GLOBAL_INTEREST_RATE_MODEL: '0x59b670e9fA9D0A427751Af201D676719a970857b',
    },
  },
  LOV_DSR: {
    LOV_DSR_TOKEN: '0x4c5859f0F772848b2D91F1D83E2Fe57935348029',
    LOV_DSR_MANAGER: '0x1291Be112d480055DaFd8a610b7d1e203891C274',
    LOV_DSR_IR_MODEL: '0x5f3f1dBD7B74C6B46e8c44f98792A1dAf8d69154',
  },
  ORACLES: {
    DAI_USD: '0x5eb3Bc0a489C5A8288765d2336659EbCA68FCd00',
    IUSDC_USD: '0x36C02dA8a0983159322a80FFE9F24b1acfF8B570',
    DAI_IUSDC: '0x809d550fca64d94Bd9F66E60752A544199cfAC3D',
  },
  EXTERNAL: {
    MAKER_DAO: {
      DAI_TOKEN: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
      SDAI_TOKEN: '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',
    },
    CIRCLE: {
      USDC_TOKEN: '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0',
    },
    CHAINLINK: {
      DAI_USD_ORACLE: '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9',
      USDC_USD_ORACLE: '0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9',
      ETH_USD_ORACLE: '0x5FC8d32690cc91D4c39d9d3abcBD16989F875707',
    },
  },
}

