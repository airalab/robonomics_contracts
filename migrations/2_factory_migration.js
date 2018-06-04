const RobotLiabilityLib = artifacts.require("RobotLiabilityLib");
const LighthouseLib = artifacts.require("LighthouseLib");

const LiabilityFactory = artifacts.require("LiabilityFactory");
const XRT = artifacts.require("XRT");

module.exports = (deployer, network) => {
  deployer.deploy(RobotLiabilityLib).then(a => {
    return deployer.deploy(LighthouseLib).then(b => {
      return deployer.deploy(XRT).then(c => {
        return deployer.deploy(LiabilityFactory, a.address, b.address, c.address).then(d => {
          return c.transferOwnership(d.address);
        });
      });
    });
  });
};
