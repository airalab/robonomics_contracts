const DutchAuction = artifacts.require("DutchAuction");
const ENS = artifacts.require("ENS");
const Ambix = artifacts.require("Ambix");
const XRT = artifacts.require("XRT");

const ethereum_ens = require("ethereum-ens");
const ens = new ethereum_ens(web3, ENS.address);
const initialBalance = 800 * 10**9;

contract("DutchAuction", (accounts) => {

  it("should be resolved via ENS", async () => {
    const addr = await ens.resolver("auction.2.robonomics.eth").addr();
    assert.equal(addr, DutchAuction.address);
  });

  it("should have XRT on balance", async () => {
    const xrt = await XRT.deployed();
    const balance = await xrt.balanceOf.call(DutchAuction.address); 
    assert.equal(balance.toNumber(), initialBalance); 
  });

  it("should have reference to XRT and Ambix contracts", async () => {
    const auction = await DutchAuction.deployed();
    const xrt = await auction.xrt.call();
    const ambix = await auction.ambix.call();
    assert.equal(xrt, XRT.address);
    assert.equal(ambix, Ambix.address);
  });

  it("auction start", async () => {
    const auction = await DutchAuction.deployed();
    await auction.startAuction();
    const stage = await auction.stage.call();
    assert.equal(stage, 2);
  });

  it("simple bid", async () => {
    const auction = await DutchAuction.deployed();
    await auction.bid(accounts[0], {value: web3.toWei(1, 'ether')});
    const bid = await auction.bids.call(accounts[0]);
    assert.equal(bid, web3.toWei(1, 'ether'));
  });

  it("bid to another account", async () => {
    const auction = await DutchAuction.deployed();
    await auction.bid(accounts[1], {value: web3.toWei(1, 'ether')});
    const bid = await auction.bids.call(accounts[1]);
    assert.equal(bid, web3.toWei(1, 'ether'));
  });

  it("auction finalize bid", async () => {
    const auction = await DutchAuction.deployed();
    await auction.bid(accounts[2], {value: web3.toWei(2, 'ether')});
    const bid = await auction.bids.call(accounts[2]);
    assert.equal(bid, web3.toWei(2, 'ether'));

    const stage = await auction.stage.call();
    assert.equal(stage, 3);
  });

  it("should update to trading stage", async () => {
    const auction = await DutchAuction.deployed();
    await auction.updateStage();

    const stage = await auction.stage.call();
    assert.equal(stage, 4);
  });

  it("claim tokens", async () => {
    const auction = await DutchAuction.deployed();
    const bid = await auction.bids.call(accounts[1]);
    await auction.claimTokens(accounts[1]);

    const finalPrice = await auction.finalPrice.call();
    const balance = await XRT.at(XRT.address).balanceOf.call(accounts[1]);
    assert.equal(Math.round(balance / 10**9), Math.round(bid / finalPrice));
  });

});
