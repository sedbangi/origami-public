import { ContractAddresses } from "./types";

export const CONTRACTS: ContractAddresses = {
  CORE: {
    MULTISIG: '0xF8Ab0fF572e48059c45eF3fa804e5A369d2b9b2B',
    FEE_COLLECTOR: '0xF8Ab0fF572e48059c45eF3fa804e5A369d2b9b2B',
    OVERLORD: '0xe8840056fb0f1cb7f5645578bf37ab16ed8b8e4b',
    CIRCUIT_BREAKER_PROXY: '0x5dFA74E2D478f58d58f1847aB96AFcE7EFE0550A',
    TOKEN_PRICES: '0x9Fd18877aD6F966f92Dd7597ae27c535f169A296',
    SWAPPER_1INCH: '0xE885aA4b7c76960e260E328aB0702908792B94D9',
  },
  OV_USDC: {
    TOKENS: {
      OV_USDC_TOKEN: '0x95583D669f5b42A96799fB9BC3b3392977BA76aA',
      O_USDC_TOKEN: '0xF8F54Be1ec2089b98F9A3E51022d690173dF796c',
      IUSDC_DEBT_TOKEN: '0x60b776291496d4e7CD1391CD5C7084E95A2B628b',
    },
    SUPPLY: {
      SUPPLY_MANAGER: '0x9aAbB47337C71B8fDB53F54D13A2748854C472d9',
      REWARDS_MINTER: '0xC77184185ecD2d03a929113C45Ec3Ea1Dd2838cD',
      IDLE_STRATEGY_MANAGER: '0x27e0a24dB7976c680e7153Db791128c5db358210',
      AAVE_V3_IDLE_STRATEGY: '0x70a627727a165B97Df4A82083baE3A21034D47C8',
    },
    BORROW: {
      LENDING_CLERK: '0x84f10bEdd835F879f10CfbBa23530fA4694D8288',
      CIRCUIT_BREAKER_USDC_BORROW: '0x48812ee31AF518e56E47ED86A44E1533894803EE',
      CIRCUIT_BREAKER_OUSDC_EXIT: '0x6C4fee764fB22bC4d7e798FdA4Fd710c6De3CEC2',
      GLOBAL_INTEREST_RATE_MODEL: '0x35220E6541786Ec1E05B5a860dB36d6D708311A6',
    },
  },
  LOV_DSR: {
    LOV_DSR_TOKEN: '0x874153adCABc9e44583eeF1a428B4EbDB2E2EaFF',
    LOV_DSR_MANAGER: '0xff651915F9F9C0a902b1EfD29FC19fe3f9255c43',
    LOV_DSR_IR_MODEL: '0x97074a7B946C842Dc21A93892228d53AeD2c8c04',
  },
  ORACLES: {
    DAI_USD: '0x2117ACfE78fac4Bf58021dC73AF60a1997EEBD8b',
    IUSDC_USD: '0x1a99647503407faF552774074D9315aE6Ef7c3fa',
    DAI_IUSDC: '0x0500e7CD588dD08C91DFdCE3E6B4D3aE3525E572',
  },
  EXTERNAL: {
    MAKER_DAO: {
      DAI_TOKEN: '0x50B44A8e5f299A453Fc7d8862Ffa09A248274817',
      SDAI_TOKEN: '0xF934FD27B7120d0ec32695fa1E92b25404558b37',
    },
    CIRCLE: {
      USDC_TOKEN: '0x2B412AE45D95BDDdB7b9B15f5aadfaE883b1fF43',
    },
    CHAINLINK: {
      DAI_USD_ORACLE: '0x3c978bA11E9ff892334F65bAbAe26321f84C5EF3',
      USDC_USD_ORACLE: '0x712841C85E296Eb3e52e5b935bA9C6F038b58De4',
      ETH_USD_ORACLE: '0x67E1C43325D1d27FA60f4D580171C0334688C581',
    },
  },
}

