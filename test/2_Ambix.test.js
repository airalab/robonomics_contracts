const ENSRegistry = artifacts.require("ENSRegistry");
const Ambix = artifacts.require("Ambix");
const XRT = artifacts.require("XRT");

const ethereum_ens = require("ethereum-ens");
const ens = new ethereum_ens(web3, ENSRegistry.address);

contract("Ambix", (accounts) => {
  var staticAmbix;
  var dynamicAmbix;
  var source;
  var sink;

  it("should be resolved via ENS", async () => {
    const addr = await ens.resolver("ambix.1.robonomics.eth").addr();
    assert.equal(addr, Ambix.address);
  });

  it("static recipe", async () => {
    staticAmbix = await Ambix.new();
    source = await XRT.new();
    sink = await XRT.new();
    await staticAmbix.appendSource([source.address], [10]);
    await staticAmbix.setSink([sink.address], [1]);
  });

  it("static conversion", async () => {
    await source.transfer(accounts[1], 1000);
    await sink.transfer(staticAmbix.address, 1000);

    await source.approve(staticAmbix.address, 1000, {from: accounts[1]});
    await staticAmbix.run(0, {from: accounts[1]});

    const balance = await sink.balanceOf.call(accounts[1]);
    assert.equal(balance.toNumber(), 100);
  });

  it("dynamic recipe", async () => {
    dynamicAmbix = await Ambix.new();

    await dynamicAmbix.appendSource([source.address], [0]);
    await dynamicAmbix.setSink([sink.address], [0]);
  });

  it("dynamic conversion", async () => {
    await source.transfer(accounts[2], 1000 * 10**9);
    await sink.transfer(dynamicAmbix.address, 1000000 * 10**9);

    await source.approve(dynamicAmbix.address, 1000 * 10**9, {from: accounts[2]});
    await dynamicAmbix.run(0, {from: accounts[2]});

    const balance = await sink.balanceOf.call(accounts[2]);
    assert.equal(balance.toNumber(), 100 * 10**9);
  });

});
