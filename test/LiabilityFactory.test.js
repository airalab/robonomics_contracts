const LiabilityFactory = artifacts.require("LiabilityFactory");
const ENSRegistry = artifacts.require("ENSRegistry");

const ethereum_ens = require("ethereum-ens");
const ens = new ethereum_ens(web3, ENSRegistry.address);
const namehash = require('eth-ens-namehash');

contract("LiabilityFactory", () => {

  it("should be resolved via ENS", async () => {
    let addr = await ens.resolver("factory.0.robonomics.eth").addr();
    assert.equal(addr, LiabilityFactory.address);
  });

});
