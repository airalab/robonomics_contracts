const ENSRegistry = artifacts.require("ENSRegistry");
const Ambix = artifacts.require("Ambix");
const XRT = artifacts.require("XRT");

const ethereum_ens = require("ethereum-ens");
const ens = new ethereum_ens(web3, ENSRegistry.address);

contract("Ambix", (accounts) => {
  var ambix;
  var source;
  var sink;

  it("should be resolved via ENS", async () => {
    const addr = await ens.resolver("ambix.1.robonomics.eth").addr();
    assert.equal(addr, Ambix.address);
  });

  it("static recipe", async () => {
    ambix = await Ambix.new();
    source = await XRT.new();
    sink = await XRT.new();
    await ambix.appendSource([source.address], [10]);
    await ambix.setSink([sink.address], [1]);
  });

  it("static conversion", async () => {
    await source.transfer(accounts[1], 1000);
    await sink.transfer(ambix.address, 1000);

    await source.approve(ambix.address, 1000, {from: accounts[1]});
    await ambix.run(0, {from: accounts[1]});

    const balance = await sink.balanceOf.call(accounts[1]);
    assert.equal(balance.toNumber(), 100);
  });

  it("dynamic recipe", async () => {
    ambix = await Ambix.new();
    source = await XRT.new();
    sink = await XRT.new();

    await ambix.appendSource([source.address], [0]);
    await ambix.setSink([sink.address], [0]);
  });

  it("dynamic conversion", async () => {
    await source.transfer(accounts[2], 1000 * 10**9);
    await sink.transfer(ambix.address, 1000 * 10**9);

    await source.approve(ambix.address, 1000 * 10**9, {from: accounts[2]});
    await ambix.run(0, {from: accounts[2]});

    const balance = await sink.balanceOf.call(accounts[2]);
    assert.equal(balance.toNumber(), 1000 * 10**9);
  });

});
