const LiabilityFactory = artifacts.require("LiabilityFactory");
const ENSRegistry = artifacts.require("ENSRegistry");

const ethereum_ens = require("ethereum-ens");
const ens = new ethereum_ens(web3, ENSRegistry.address);

contract("LiabilityFactory", () => {

  it("Can be resolved via ENS", () => {
    return ens.resolver("factory.0.robonomics.eth").addr()
      .then(addr => {
        assert.equal(addr, LiabilityFactory.address, "ENS has broken reference to factory");
      });
  });

  it("Can create lighthouse contract", () => {
    return LiabilityFactory.deployed()
      .then(factory => {
        return factory.createLighthouse.sendTransaction(1000, 10, "lighthouse");
      })
      .then(result => {
        console.log("Result");
      });
  });

});
