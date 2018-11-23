const PublicResolver = artifacts.require("PublicResolver");
const DutchAuction = artifacts.require("DutchAuction");
const Lighthouse = artifacts.require("Lighthouse");
const Factory = artifacts.require("Factory");
const ENS = artifacts.require("ENS");
const XRT = artifacts.require("XRT");

const namehash = require('eth-ens-namehash');
const sha3 = web3.utils.sha3;

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
    l = await Lighthouse.at(laddress);
    await xrt.approve(l.address,1000);
    await xrt.allowance(accounts[0],l.address);
    await l.refill(1000);
    await xrt.approve(factory.address, 1000);
  });
}

module.exports = (deployer, network, accounts) => {

  if (network === 'testing') {
    deployer.then(async () =>
      await createTestLighthouse(await Factory.deployed(), await XRT.deployed(), accounts)
    );
  } 

};
