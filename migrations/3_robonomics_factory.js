const RobotLiabilityLib = artifacts.require("RobotLiabilityLib");
const LighthouseLib = artifacts.require("LighthouseLib");

const LiabilityFactory = artifacts.require("LiabilityFactory");
const XRT = artifacts.require("XRT");
const ENSRegistry = artifacts.require("ENSRegistry");

module.exports = (deployer, network, accounts) => {
  return deployer.deploy(RobotLiabilityLib).then(rl => {
    return deployer.deploy(LighthouseLib).then(ll => {
      return deployer.deploy(XRT).then(xrt => {
        return ENSRegistry.deployed().then(ens => {
          return deployer.deploy(LiabilityFactory,
                                 rl.address,
                                 ll.address,
                                 xrt.address,
                                 ens.address).then(factory => {
            return xrt.transferOwnership.sendTransaction(factory.address);
          });
        });
      });
    });
  });
};
