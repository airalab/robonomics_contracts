const LiabilityFactory = artifacts.require("LiabilityFactory");
const XRT = artifacts.require("XRT");

const ENSRegistry = artifacts.require("ENSRegistry");
const FIFSRegistrar = artifacts.require("FIFSRegistrar");
const PublicResolver = artifacts.require("PublicResolver");
const namehash = require('eth-ens-namehash');
const sha3 = require('web3-utils').sha3;

const robonomicsRoot = "0.robonomics.eth";

function setupNames(deployer, ens, me) {
  return Promise.all([
    // Create fundamental subnodes
    ens.setSubnodeOwner.sendTransaction(namehash(robonomicsRoot), sha3("xrt"), me),
    ens.setSubnodeOwner.sendTransaction(namehash(robonomicsRoot), sha3("factory"), me),
    ens.setSubnodeOwner.sendTransaction(namehash(robonomicsRoot), sha3("lighthouse"), me)
  ]).then(() => {
    return deployer.deploy(PublicResolver, ens.address);
  }).then(resolver => {
    return Promise.all([
      ens.setResolver.sendTransaction(robonomicsRoot, resolver.address),
      ens.setResolver.sendTransaction(namehash("xrt."+robonomicsRoot), resolver.address),
      ens.setResolver.sendTransaction(namehash("factory."+robonomicsRoot), resolver.address),
      ens.setResolver.sendTransaction(namehash("lighthouse."+robonomicsRoot), resolver.address)
    ]).then(() => {
      return Promise.all([
        // Set up robonomics addresses
        resolver.setAddr.sendTransaction(namehash("xrt."+robonomicsRoot), XRT.address),
        resolver.setAddr.sendTransaction(namehash("factory."+robonomicsRoot), LiabilityFactory.address),

        // Finally grant lighthouse subnode to factory
        ens.setSubnodeOwner.sendTransaction(namehash(robonomicsRoot), sha3("lighthouse"), LiabilityFactory.address)
      ]);
    });
  });
}

module.exports = (deployer, network, accounts) => {
  const me = accounts[0];

  if (network == "development") {
    return FIFSRegistrar.deployed()
      .then(registrar => {
        return registrar.register.sendTransaction(sha3("robonomics"), me);
      })
      .then(() => {
        return ENSRegistry.deployed();
      })
      .then(ens => {
        return ens.setSubnodeOwner.sendTransaction(namehash("robonomics.eth"), sha3("0"), me)
          .then(() => {
            return setupNames(deployer, ens, me);
          });
      });
  }

};
