require("@nomiclabs/hardhat-waffle");
require('hardhat-deploy');
require('hardhat-deploy-ethers');

const proxyUrl = process.env.NEON_PROXY_URL || "";
const accounts = process.env.NEON_ACCOUNTS;
const chainId = parseInt(process.env.NEON_CHAIN_ID) || 111;

module.exports = {
  networks: {
    neonlabs: {
      url: proxyUrl,
      accounts: accounts,
      // accounts: [
      //   '0x7efe7d68906dd6fb3487f411aafb8e558863bf1d2f60372a47186d151eae625a',
      //   '0x09fb68d632c2b227cc6da77696de362fa38cb94e1c62d8a07db82e7d5e754f10',
      //   '0x9b6007319e21225003fe120b4d7be1ee447d0fb29f52ca72914dad41fb47ddb9',
      // ],
      chainId: chainId,
      allowUnlimitedContractSize: true,
      throwOnTransactionFailures: true,
      throwOnCallFailures: true,
      timeout: 100000000,
      gas: 150000000,
      gasPrice: 'auto',
      isFork: true,
    }
  },
  solidity: {
    version: "0.5.17",
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
