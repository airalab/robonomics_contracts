const PrivateKeyProvider = require("truffle-privatekey-provider");
const privateKey = "62537136911bca3a7e2b....";

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
        mainnet: {
            provider: new PrivateKeyProvider(privateKey, "http://localhost:8545"),
            network_id: 1,
            confirmations: 2,
            timeoutBlocks: 200,
            gasPrice: 10000000000
        }
	
    },
    compilers: {
        solc: {
            version: "0.4.25",
            optimizer: {
                enabled: true,
                runs: 1000
            }
        }
    },
    mocha: {
        reporter: 'eth-gas-reporter',
        reporterOptions: {
            currency: 'USD',
            gasPrice: 10
        }
    }
};
