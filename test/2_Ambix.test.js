const ENS = artifacts.require("ENS");
const Ambix = artifacts.require("Ambix");
const XRT = artifacts.require("XRT");

const ethereum_ens = require("ethereum-ens");
const ens = new ethereum_ens(web3, ENS.address);

contract("Ambix", (accounts) => {
  it("should be resolved via ENS", async () => {
    const addr = await ens.resolver("ambix.2.robonomics.eth").addr();
    assert.equal(addr, Ambix.address);
  });

  it("static recipe", async () => {
    const ambix = await Ambix.new();
    const source = await XRT.new();
    const sink = await XRT.new();

    await ambix.appendSource([source.address], [10]);
    await ambix.setSink([sink.address], [1]);

    await source.transfer(accounts[1], 1000);
    await sink.transfer(ambix.address, 1000);

    await source.approve(ambix.address, 1000, {from: accounts[1]});
    await ambix.run(0, {from: accounts[1]});

    const balance = await sink.balanceOf(accounts[1]);
    assert.equal(balance.toNumber(), 100);
  });

  it("dynamic recipe", async () => {
    const ambix = await Ambix.new();
    const source = await XRT.new();
    const sink = await XRT.new();

    await ambix.setSink([sink.address], [0]);
    await ambix.appendSource([source.address], [0]);

    await source.transfer(accounts[1], 100 * 10**9);
    await sink.transfer(ambix.address, 1000 * 10**9);

    await source.approve(ambix.address, 100 * 10**9, {from: accounts[1]});
    await ambix.run(0, {from: accounts[1]});

    const balance = await sink.balanceOf(accounts[1]);
    assert.equal(balance.toNumber(), 100 * 10**9);
  });

});
