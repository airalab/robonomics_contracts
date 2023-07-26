require("@nomiclabs/hardhat-waffle");
require('hardhat-deploy');
require('hardhat-deploy-ethers');

module.exports = {
  networks: {
    neonlabs: {
      // url: 'https://proxy.devnet.neonlabs.org/solana',
      url: 'http://127.0.0.1:9090/solana',
      accounts: [
        '0x7efe7d68906dd6fb3487f411aafb8e558863bf1d2f60372a47186d151eae625a',
        '0x09fb68d632c2b227cc6da77696de362fa38cb94e1c62d8a07db82e7d5e754f10',
        '0x9b6007319e21225003fe120b4d7be1ee447d0fb29f52ca72914dad41fb47ddb9',
      ],
      deployer: '0x1823085af38c56f080922f19d8E34e87e70DD63c',
      // gas: DEFAULT_BLOCK_GAS_LIMIT,
      // network_id: 245022926,
      // chainId: 245022926,
      chainId: 111,
      allowUnlimitedContractSize: true,
      throwOnTransactionFailures: true,
      throwOnCallFailures: true,
      timeout: 100000000,
      // gasPrice: 5e9,
      // blockGasLimit: 8000000,
      // gas: 8000000,
      // gasPrice: 6e10,
      // gasMultiplier: 7,
      gas: 150000000,
      gasPrice: 'auto',
      isFork: true,
    }
  },
  solidity: {
    version: "0.5.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      }
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 600000,
  },
};
