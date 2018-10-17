const XRT = artifacts.require("XRT");
const Ambix = artifacts.require("Ambix");
const DutchAuction = artifacts.require("DutchAuction");
const ENS = artifacts.require("ENS");
const PublicResolver = artifacts.require("PublicResolver");
const LiabilityFactory = artifacts.require("LiabilityFactory");
const LighthouseLib = artifacts.require("LighthouseLib");

const namehash = require('eth-ens-namehash');
const sha3 = require('web3-utils').sha3;


const robonomicsGen  = "2";
const robonomicsRoot = robonomicsGen+".robonomics.eth";

function createTestLighthouse(factory, xrt, accounts) {
  var fs = require('fs');

  fs.writeFile('ENS.address', web3.toChecksumAddress(ENS.address), function (err) {
    if (err) throw err;
    console.log('Saved ENS.address!');
  }); 

  fs.writeFile('XRT.address', web3.toChecksumAddress(XRT.address), function (err) {
    if (err) throw err;
    console.log('Saved XRT.address!');
  }); 

  return factory.createLighthouse(1000, 10, "test").then(async (tx) => {
    laddress = tx.logs[0].args.lighthouse;
    l = LighthouseLib.at(laddress);
    await xrt.approve(l.address,1000);
    await xrt.allowance(accounts[0],l.address);
    await l.refill(1000);
    await xrt.approve(factory.address, 1000);
  });
}

module.exports = function(deployer, network, accounts) {
  if (network === 'testing') {
    deployer.then(function() {
      return createTestLighthouse(LiabilityFactory.at(LiabilityFactory.address), XRT.at(XRT.address), accounts);
    });
  } 
  else {
    console.log("Skip...")
  }
};
