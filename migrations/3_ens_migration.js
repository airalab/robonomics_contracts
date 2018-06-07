const XRT = artifacts.require("XRT");
const ENSRegistry = artifacts.require("ENSRegistry");
const PublicResolver = artifacts.require("PublicResolver");
const LiabilityFactory = artifacts.require("LiabilityFactory");

const namehash = require('eth-ens-namehash');
const sha3 = require('web3-utils').sha3;

const robonomicsGen  = "0";
const robonomicsRoot = robonomicsGen+".robonomics.eth";

function regNames(deployer, ens, accounts) {
  let resolver
  return deployer.deploy(PublicResolver, ens.address)
   .then((r) => {
      resolver = r
      return ens.setSubnodeOwner(namehash("robonomics.eth"), sha3(robonomicsGen), accounts[0])
   })
   .then(() => {
      return Promise.all([
        ens.setSubnodeOwner(namehash(robonomicsRoot), sha3("xrt"), accounts[0]),
        ens.setSubnodeOwner(namehash(robonomicsRoot), sha3("factory"), accounts[0]),
        ens.setSubnodeOwner(namehash(robonomicsRoot), sha3("lighthouse"), accounts[0])
      ]);
    }).then(() => { return Promise.all([
        ens.setResolver(namehash(robonomicsRoot), resolver.address),
        ens.setResolver(namehash("xrt."+robonomicsRoot), resolver.address),
        ens.setResolver(namehash("factory."+robonomicsRoot), resolver.address),
        ens.setResolver(namehash("lighthouse."+robonomicsRoot), resolver.address),
        resolver.setAddr(namehash("xrt."+robonomicsRoot), XRT.address),
        resolver.setAddr(namehash("factory."+robonomicsRoot), LiabilityFactory.address)
      ]);
    }).then(() => {
      return ens.setSubnodeOwner(namehash(robonomicsRoot), sha3("lighthouse"), LiabilityFactory.address);
    }).then(() => {
      return LiabilityFactory.at(LiabilityFactory.address).setENS(ens.address);
    });
}

module.exports = function(deployer, network, accounts) {

  if (network === 'development') {
      deployer.deploy(ENSRegistry).then(ens => {
      return ens.setSubnodeOwner('0x0', sha3("eth"), accounts[0]).then(() => {
        return ens.setSubnodeOwner(namehash("eth"), sha3("robonomics"), accounts[0]).then(() => {
          return regNames(deployer, ens, accounts);
        });
      });
    }).catch(e => {
      console.log("Error: "+e);
    });
  } else {
	regNames(deployer, ENSRegistry.at('0x314159265dD8dbb310642f98f50C066173C1259b'), accounts);
   };

};
