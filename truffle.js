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
            network_id: '*' // Match any network id
        },
        mainnet: {
            host: '127.0.0.1',
            port: 8545,
            network_id: '1' // Only mainnet
        }
	
    },
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    }
};
