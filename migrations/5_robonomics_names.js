const PublicResolver = artifacts.require('PublicResolver');
const DutchAuction = artifacts.require('DutchAuction');
const Factory = artifacts.require('Factory');
const KycAmbix = artifacts.require('KycAmbix');
const XRT = artifacts.require('XRT');
const ENS = artifacts.require('ENS');

const namehash = require('eth-ens-namehash').hash;
const sha3 = web3.utils.sha3;

module.exports = async (deployer, network, accounts) => {

    const gen = require('../config')['generation'];
    const robonomicsRoot = gen + '.robonomics.eth';
    const ens_address = network == 'mainnet'
                      ? '0x314159265dD8dbb310642f98f50C066173C1259b'
                      : ENS.address; 

    await deployer.deploy(PublicResolver, ens_address);
    const resolver = await PublicResolver.deployed(); 
    const ens = await ENS.at(ens_address);

    await ens.setSubnodeOwner(namehash('robonomics.eth'), sha3(gen), accounts[0]);

    await ens.setSubnodeOwner(namehash(robonomicsRoot), sha3('xrt'), accounts[0]);
    await ens.setSubnodeOwner(namehash(robonomicsRoot), sha3('ambix'), accounts[0]);
    await ens.setSubnodeOwner(namehash(robonomicsRoot), sha3('auction'), accounts[0]);
    await ens.setSubnodeOwner(namehash(robonomicsRoot), sha3('factory'), accounts[0]);
    await ens.setSubnodeOwner(namehash(robonomicsRoot), sha3('lighthouse'), accounts[0]);

    await ens.setResolver(namehash(robonomicsRoot), resolver.address);
    await ens.setResolver(namehash('xrt.'+robonomicsRoot), resolver.address);
    await ens.setResolver(namehash('ambix.'+robonomicsRoot), resolver.address);
    await ens.setResolver(namehash('auction.'+robonomicsRoot), resolver.address);
    await ens.setResolver(namehash('factory.'+robonomicsRoot), resolver.address);
    await ens.setResolver(namehash('lighthouse.'+robonomicsRoot), resolver.address);

    await resolver.setAddr(namehash('xrt.'+robonomicsRoot), XRT.address);
    await resolver.setAddr(namehash('ambix.'+robonomicsRoot), KycAmbix.address);
    await resolver.setAddr(namehash('auction.'+robonomicsRoot), DutchAuction.address);
    await resolver.setAddr(namehash('factory.'+robonomicsRoot), Factory.address);

    await ens.setSubnodeOwner(namehash(robonomicsRoot), sha3('lighthouse'), Factory.address);
};
