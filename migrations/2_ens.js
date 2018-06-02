const ENSRegistry = artifacts.require("ENSRegistry");
const FIFSRegistrar = artifacts.require('FIFSRegistrar');

const namehash = require('eth-ens-namehash');
const sha3 = require('web3-utils').sha3;

/**
 * Deploy the ENS and FIFSRegistrar
 *
 * @param {Object} deployer truffle deployer helper
 * @param {string} tld tld which the FIFS registrar takes charge of
 */
function deployFIFSRegistrar(deployer) {
  // Deploy the ENS first
  return deployer.deploy(ENSRegistry)
    .then(ens => {
      // Deploy the FIFSRegistrar and bind it with ENS
      return deployer.deploy(FIFSRegistrar, ens.address, namehash("eth"))
        .then(registrar => {
          // Transfer the owner of the `rootNode` to the FIFSRegistrar
          return ens.setSubnodeOwner.sendTransaction('0x0', sha3("eth"), registrar.address);
        });
     });
}

module.exports = function(deployer, network) {

  if (network === 'development') {
    return deployFIFSRegistrar(deployer);
  }

};
