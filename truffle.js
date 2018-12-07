module.exports = {
    networks: {
        testing: {
            host: '127.0.0.1',
            port: 10545,
            network_id: '*' // Match any network id
        },
        development: {
            host: '127.0.0.1',
            port: 9545,
            network_id: '420123',
            websockets: true
        },
        mainnet: {
            host: '127.0.0.1',
            port: 8545,
            network_id: '1',
            websockets: true,
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
