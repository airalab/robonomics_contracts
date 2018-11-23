const ENS = artifacts.require('ENS');

const namehash = require('eth-ens-namehash').hash;
const sha3 = web3.utils.sha3;

module.exports = async (deployer, network, accounts) => {

    if (network !== 'mainnet') {
        await deployer.deploy(ENS);

        const ens = await ENS.deployed();
        await ens.setSubnodeOwner('0x00', sha3('eth'), accounts[0]);
        await ens.setSubnodeOwner(namehash('eth'), sha3('robonomics'), accounts[0]);
    }

};
