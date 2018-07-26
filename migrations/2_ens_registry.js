const ENSRegistry = artifacts.require("ENSRegistry");
const namehash = require('eth-ens-namehash');
const sha3 = require('web3-utils').sha3;

module.exports = (deployer, network, accounts) => {

  if (network === 'development') {
    deployer.deploy(ENSRegistry).then(ens => {
      return ens.setSubnodeOwner('0x0', sha3("eth"), accounts[0]).then(() => {
        return ens.setSubnodeOwner(namehash("eth"), sha3("robonomics"), accounts[0]);
      });
    });
  }

};
