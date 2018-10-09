const LiabilityFactory = artifacts.require("LiabilityFactory");
const ENS = artifacts.require("ENS");
const XRT = artifacts.require("XRT");

const ethereum_ens = require("ethereum-ens");
const ens = new ethereum_ens(web3, ENS.address);

contract("XRT", () => {

  it("should be resolved via ENS", async () => {
    const addr = await ens.resolver("xrt.2.robonomics.eth").addr();
    assert.equal(addr, XRT.address);
  });

  it("factory should be a minter", async () => {
    const xrt = await XRT.deployed();
    const isMinter = await xrt.isMinter(LiabilityFactory.address); 
    assert.equal(isMinter, true);
  });

});
