const LiabilityFactory = artifacts.require("LiabilityFactory");
const XRT = artifacts.require("XRT");
const ENSRegistry = artifacts.require("ENSRegistry");

const ethereum_ens = require("ethereum-ens");
const ens = new ethereum_ens(web3, ENSRegistry.address);

contract("XRT", () => {

  it("Can be resolved via ENS", () => {
    return ens.resolver("xrt.0.robonomics.eth").addr()
      .then(addr => {
        assert.equal(addr, XRT.address, "ENS has broken reference to factory");
      });
  });

  it("Owned by factory", () => {
    return XRT.deployed()
      .then(xrt => {
        return xrt.owner.call(); 
      })
      .then(owner => {
        assert.equal(owner, LiabilityFactory.address, "Owner address has no point to factory");
      });
  });

});
