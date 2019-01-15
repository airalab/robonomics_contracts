/*
const HDWalletProvider = require("truffle-hdwallet-provider");
const privateKey = "<PRIVATE>";
*/

module.exports = {
    networks: {
        testing: {
            host: '127.0.0.1',
            port: 10545,
            network_id: 420123
        },
        development: {
            host: '127.0.0.1',
            port: 9545,
            network_id: 420123
        },
        /*
        kovan: {
            provider: new HDWalletProvider(privateKey, "https://kovan.infura.io/v3/<API_KEY>"),
            network_id: 42,
            skipDryRun: true
        },
        mainnet: {
            provider: new HDWalletProvider(privateKey, "https://mainnet.infura.io/v3/<API_KEY>"),
            network_id: 1,
            gasPrice: 10000000000,
            skipDryRun: true
        }
        */
    },
    compilers: {
        solc: {
            version: "0.5.2",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                },
                evmVersion: "byzantium"
            }
        }
    },
    mocha: {
        reporter: 'eth-gas-reporter',
        reporterOptions: {
            currency: 'USD',
            gasPrice: 10
        }
    },
};
