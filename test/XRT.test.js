const LiabilityFactory = artifacts.require("LiabilityFactory");
const ENSRegistry = artifacts.require("ENSRegistry");
const XRT = artifacts.require("XRT");

const ethereum_ens = require("ethereum-ens");
const ens = new ethereum_ens(web3, ENSRegistry.address);

contract("XRT", () => {

  it("should be resolved via ENS", async () => {
    let addr = await ens.resolver("xrt.0.robonomics.eth").addr();
    assert.equal(addr, XRT.address);
  });

  it("should be owned by factory", async () => {
    let xrt = await XRT.deployed();
    let owner = await xrt.owner.call(); 
    assert.equal(owner, LiabilityFactory.address);
  });

});
