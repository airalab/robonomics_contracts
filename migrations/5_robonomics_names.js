const LiabilityFactory = artifacts.require("LiabilityFactory");
const PublicResolver = artifacts.require("PublicResolver");
const DutchAuction = artifacts.require("DutchAuction");
const Ambix = artifacts.require("Ambix");
const XRT = artifacts.require("XRT");
const ENS = artifacts.require("ENS");

const namehash = require('eth-ens-namehash').hash;
const sha3 = require('web3-utils').sha3;

const robonomicsGen  = "2";
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
        ens.setSubnodeOwner(namehash(robonomicsRoot), sha3("ambix"), accounts[0]),
        ens.setSubnodeOwner(namehash(robonomicsRoot), sha3("auction"), accounts[0]),
        ens.setSubnodeOwner(namehash(robonomicsRoot), sha3("factory"), accounts[0]),
        ens.setSubnodeOwner(namehash(robonomicsRoot), sha3("lighthouse"), accounts[0])
      ]);
    }).then(() => { return Promise.all([
        ens.setResolver(namehash(robonomicsRoot), resolver.address),
        ens.setResolver(namehash("xrt."+robonomicsRoot), resolver.address),
        ens.setResolver(namehash("ambix."+robonomicsRoot), resolver.address),
        ens.setResolver(namehash("auction."+robonomicsRoot), resolver.address),
        ens.setResolver(namehash("factory."+robonomicsRoot), resolver.address),
        ens.setResolver(namehash("lighthouse."+robonomicsRoot), resolver.address),
        resolver.setAddr(namehash("xrt."+robonomicsRoot), XRT.address),
        resolver.setAddr(namehash("ambix."+robonomicsRoot), Ambix.address),
        resolver.setAddr(namehash("auction."+robonomicsRoot), DutchAuction.address),
        resolver.setAddr(namehash("factory."+robonomicsRoot), LiabilityFactory.address)
      ]);
    }).then(() => {
      return ens.setSubnodeOwner(namehash(robonomicsRoot), sha3("lighthouse"), LiabilityFactory.address);
    });
}

module.exports = function(deployer, network, accounts) {

  if (network === 'development' || network === 'testing') {
    regNames(deployer, ENS.at(ENS.address), accounts);
  } else {
	regNames(deployer, ENS.at('0x314159265dD8dbb310642f98f50C066173C1259b'), accounts);
   };

};
