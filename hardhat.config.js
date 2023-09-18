require("@nomiclabs/hardhat-waffle");
require('hardhat-deploy');
require('hardhat-deploy-ethers');

const proxyUrl = process.env.NEON_PROXY_URL || "http://127.0.0.1:9090/solana";
const accounts = process.env.NEON_ACCOUNTS.split(",");
const chainId = parseInt(process.env.NEON_CHAIN_ID) || 111;

module.exports = {
  networks: {
    neonlabs: {
      url: proxyUrl,
      accounts: accounts,
      chainId: chainId,
      allowUnlimitedContractSize: true,
      throwOnTransactionFailures: true,
      throwOnCallFailures: true,
      timeout: 100000000,
      gas: 200000000,
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
