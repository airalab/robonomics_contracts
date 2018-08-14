const RobotLiabilityLib = artifacts.require("RobotLiabilityLib");
const LighthouseLib = artifacts.require("LighthouseLib");
const ENSRegistry = artifacts.require("ENSRegistry");
const LiabilityFactory = artifacts.require("LiabilityFactory");
const XRT = artifacts.require("XRT");
const Ambix = artifacts.require("Ambix");
const DutchAuction = artifacts.require("DutchAuction");

const foundation = "";

function deployFactory(deployer, ens, foundation_address) {
  deployer.deploy(XRT).then(xrt => {
    return Promise.all([
      deployer.deploy(RobotLiabilityLib),
      deployer.deploy(LighthouseLib),
      deployer.deploy(Ambix)
    ]).then(() => {
      return deployer.deploy(LiabilityFactory,
                             RobotLiabilityLib.address,
                             LighthouseLib.address,
                             DutchAuction.address,
                             xrt.address,
                             ens.address);
    }).then(factory => {
      return Promise.all([
        xrt.transferOwnership(factory.address),

        xrt.transfer(foundation_address, 1000 * 10**9),

        xrt.transfer(Ambix.address, 1000 * 10**9),

        xrt.transfer(DutchAuction.address, 8000 * 10**9).then(() => {
          return DutchAuction.at(DutchAuction.address).setup(xrt.address, Ambix.address);
        })
      ]);
    });
  });
}

module.exports = (deployer, network, accounts) => {

  if (network === 'development') {
    return deployFactory(deployer, ENSRegistry.at(ENSRegistry.address), accounts[0]);
  } else {
	return deployFactory(deployer, ENSRegistry.at('0x314159265dD8dbb310642f98f50C066173C1259b'), foundation);
  }

};
