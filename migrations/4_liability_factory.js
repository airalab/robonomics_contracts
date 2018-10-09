const RobotLiabilityLib = artifacts.require("RobotLiabilityLib");
const LighthouseLib = artifacts.require("LighthouseLib");
const LiabilityFactory = artifacts.require("LiabilityFactory");
const DutchAuction = artifacts.require("DutchAuction");
const Ambix = artifacts.require("Ambix");
const XRT = artifacts.require("XRT");
const ENS = artifacts.require("ENS");

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
        xrt.addMinter(factory.address),

        xrt.transfer(foundation_address, 100 * 10**9),

        xrt.transfer(Ambix.address, 100 * 10**9),

        xrt.transfer(DutchAuction.address, 800 * 10**9).then(() => {
          return DutchAuction.at(DutchAuction.address).setup(xrt.address, Ambix.address);
        })
      ]);
    }).then(() => {
      return xrt.renounceMinter();
    });;
  });
}

module.exports = (deployer, network, accounts) => {

  if (network === 'development') {
    return deployFactory(deployer, ENS.at(ENS.address), accounts[0]);
  } else {
	return deployFactory(deployer, ENS.at('0x314159265dD8dbb310642f98f50C066173C1259b'), foundation);
  }

};
