const HDWalletProvider = require("@truffle/hdwallet-provider");
const Web3 = require("web3");

Web3.providers.HttpProvider.prototype.sendAsync = Web3.providers.HttpProvider.prototype.send

const privateKeys = [
    "0x09fb68d632c2b227cc6da77696de362fa38cb94e1c62d8a07db82e7d5e754f10",
    "0x7efe7d68906dd6fb3487f411aafb8e558863bf1d2f60372a47186d151eae625a"
];
const provider = new Web3.providers.HttpProvider("https://devnet.neonevm.org");

module.exports = {
    networks: {
        neonlabs: {
            provider: () => {
                return new HDWalletProvider(
                  privateKeys,
                  provider,
                );
            },
            network_id: "*",
            skipDryRun: true,
            networkCheckTimeout: 180000,
            timeoutBlocks: 10,
            deploymentPollingInterval: 10000,
            // disableConfirmationListener: true
        },
    },
    compilers: {
        solc: {
            version: "0.5.7",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                }
            }
        }
    },
    mocha: {
        timeout: 180000
    },
};
