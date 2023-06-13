
const HDWalletProvider = require("truffle-hdwallet-provider");
const privateKey = "0x618e90bb05c847d0be7158fb3420e6f74c0a99195db496d41aec554825d43862";


module.exports = {
    networks: {
        neon: {
            provider: new HDWalletProvider(privateKey, "https://devnet.neonevm.org/solana "),
            network_id: 245022926,
            skipDryRun: true
        },
    },
    compilers: {
        solc: {
            version: "0.5.7",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                },
                evmVersion: "petersburg"
            }
        }
    },
    mocha: {
        timeout: 180000
    },
};
