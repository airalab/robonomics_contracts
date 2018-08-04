const LiabilityFactory = artifacts.require("LiabilityFactory");
const ENSRegistry = artifacts.require("ENSRegistry");
const RobotLiabilityLib = artifacts.require("RobotLiabilityLib");
const LighthouseLib = artifacts.require("LighthouseLib");
const XRT = artifacts.require("XRT");

const ethereum_ens = require("ethereum-ens");
const ens = new ethereum_ens(web3, ENSRegistry.address);
const namehash = require('eth-ens-namehash');

contract("LiabilityFactory", () => {
  const factory = LiabilityFactory.at(LiabilityFactory.address);

  it("shoudl be resolved via ENS", async () => {
    const addr = await ens.resolver("factory.1.robonomics.eth").addr();
    assert.equal(addr, LiabilityFactory.address);
  });

  it("should point to XRT", async () => {
    const xrt = await factory.xrt.call();
    assert.equal(xrt, XRT.address);
  });

  it("should point to ENS", async () => {
    const ens = await factory.ens.call();
    assert.equal(ens, ENSRegistry.address);
  });

  it("should point to RobotLiability binary", async () => {
    const rl = await factory.robotLiabilityLib.call();
    assert.equal(rl, RobotLiabilityLib.address);
  });

  it("should point to Lighthouse binary", async () => {
    const ll = await factory.lighthouseLib.call();
    assert.equal(ll, LighthouseLib.address);
  });

});
