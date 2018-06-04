const LiabilityFactory = artifacts.require("LiabilityFactory");
const ENSRegistry = artifacts.require("ENSRegistry");

const ethereum_ens = require("ethereum-ens");
const ens = new ethereum_ens(web3, ENSRegistry.address);
const namehash = require('eth-ens-namehash');

contract("Lighthouse", () => {
  let lighthouse;

  it("should be created by factory", async () => {
    let factory = await LiabilityFactory.deployed();
    let result = await factory.createLighthouse(1000, 10, "test");
    assert.equal(result.logs[0].event, "NewLighthouse");
    lighthouse = result.logs[0].args.lighthouse;
  });

  it("should be resolved via ENS", async () => {
    const addr = await ens.resolver("test.lighthouse.0.robonomics.eth").addr();
    assert.equal(addr, lighthouse);
  });

});
