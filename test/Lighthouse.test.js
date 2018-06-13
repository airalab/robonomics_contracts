const LiabilityFactory = artifacts.require("LiabilityFactory");
const ENSRegistry = artifacts.require("ENSRegistry");
const Lighthouse = artifacts.require("LighthouseLib");
const Liability = artifacts.require("RobotLiabilityLib");
const XRT = artifacts.require("XRT");

const ethereum_ens = require("ethereum-ens");
const ens = new ethereum_ens(web3, ENSRegistry.address);
const namehash = require("eth-ens-namehash");
const utils = require("web3-utils");
const abi = require("web3-eth-abi");

function randomAsk(account) {
  let ask = { model:        utils.randomHex(34)
            , objective:    utils.randomHex(34)
            , token:        XRT.address
            , cost:         1
            , validator:    "0x0000000000000000000000000000000000000000"
            , validatorFee: 0
            , deadline:     web3.eth.blockNumber + 1000
            , nonce:        utils.randomHex(32)
            };
            
  const hash = utils.soliditySha3(
      {t: "bytes",   v: ask.model}
    , {t: "bytes",   v: ask.objective}
    , {t: "address", v: ask.token}
    , {t: "uint256", v: ask.cost}
    , {t: "address", v: ask.validator}
    , {t: "uint256", v: ask.validatorFee}
    , {t: "uint256", v: ask.deadline}
    , {t: "bytes32", v: ask.nonce}
  );
  ask.signature = web3.eth.sign(account, hash);

  return ask;
}

function pairBid(ask, account) {
  let bid = Object.assign({}, ask);
  bid.nonce = utils.randomHex(32); 
  bid.lighthouseFee = 1;

  const hash = utils.soliditySha3(
      {t: "bytes",   v: bid.model}
    , {t: "bytes",   v: bid.objective}
    , {t: "address", v: bid.token}
    , {t: "uint256", v: bid.cost}
    , {t: "uint256", v: bid.lighthouseFee}
    , {t: "uint256", v: bid.deadline}
    , {t: "bytes32", v: bid.nonce}
  );
  bid.signature = web3.eth.sign(account, hash);

  return bid;
}

function encodeAsk(ask) {
  return abi.encodeParameters(
    [ "bytes"
    , "bytes"
    , "address"
    , "uint256"
    , "address"
    , "uint256"
    , "uint256"
    , "bytes32"
    , "bytes"
    ],
    [ ask.model
    , ask.objective
    , ask.token
    , ask.cost
    , ask.validator
    , ask.validatorFee
    , ask.deadline
    , ask.nonce
    , ask.signature
    ]
  );
}

function encodeBid(bid) {
  return abi.encodeParameters(
    [ "bytes"
    , "bytes"
    , "address"
    , "uint256"
    , "uint256"
    , "uint256"
    , "bytes32"
    , "bytes"
    ],
    [ bid.model
    , bid.objective
    , bid.token
    , bid.cost
    , bid.lighthouseFee
    , bid.deadline
    , bid.nonce
    , bid.signature
    ]
  );
}

function finalize(liability, account) {
  const finalizeAbi = Liability.abi.find((e) => { return e.name == "finalize"; });

  const result = utils.randomHex(34);
  const hash = utils.soliditySha3(
      {t: "address",   v: liability}
    , {t: "bytes",     v: result}
  );

  return abi.encodeFunctionCall(finalizeAbi, [result, web3.eth.sign(account, hash)]); 
}

async function liabilityCreation(lighthouse, account, promisee, promisor) {
  const factory = LiabilityFactory.at(LiabilityFactory.address);
  const xrt = XRT.at(XRT.address);

  const builder = LiabilityFactory.at(lighthouse.address);

  const ask = randomAsk(promisee);
  const bid = pairBid(ask, promisor);

  await xrt.increaseApproval(LiabilityFactory.address, ask.cost, {from: promisee});
  await xrt.increaseApproval(LiabilityFactory.address, bid.lighthouseFee, {from: promisor});

  const result = await builder.createLiability(encodeAsk(ask), encodeBid(bid), {from: account});
  assert.equal(result.logs[0].event, "NewLiability");

  const liability = Liability.at(result.logs[0].args.liability);

  const txgas = result.receipt.gasUsed;
  const gas = await factory.gasUtilizing.call(liability.address);
  const delta = txgas - gas.toNumber();
  console.log("gas:" + " tx = " + txgas + ", factory = " + gas.toNumber() + ", delta = " + delta); 
//  assert.equal(delta, 0);

  return liability;
}

async function liabilityFinalization(liability, lighthouse, account, promisor) {
  const factory = LiabilityFactory.at(LiabilityFactory.address);
  const xrt = XRT.at(XRT.address);
  let gas = await factory.gasUtilizing.call(liability.address);

  const result = await lighthouse.to(liability.address, finalize(liability.address, promisor), {from: account}); 

  const txgas = result.receipt.gasUsed;
  gas = (await factory.gasUtilizing.call(liability.address)).toNumber() - gas.toNumber();
  
  const delta = txgas - gas;
  console.log("gas:" + " tx = " + txgas + ", factory = " + gas + ", delta = " + delta); 

  const totalgas = await factory.totalGasUtilizing.call();
  console.log("total gas: " + totalgas.toNumber());

//  assert.equal(delta, 0);
}

contract("Lighthouse", (accounts) => {
  const factory = LiabilityFactory.at(LiabilityFactory.address);
  const xrt = XRT.at(XRT.address);

  let lighthouse;
  let liability;

  it("should be created via factory", async () => {
    const result = await factory.createLighthouse(1000, 3, "test");
    assert.equal(result.logs[0].event, "NewLighthouse");

    lighthouse = Lighthouse.at(result.logs[0].args.lighthouse);

    const registered = await factory.isLighthouse.call(lighthouse.address);
    assert.equal(registered, true);
  });

  it("should be resolved via ENS", async () => {
    const addr = await ens.resolver("test.lighthouse.0.robonomics.eth").addr();
    assert.equal(addr, lighthouse.address);
  });

  it("security placement", async () => {
    await xrt.approve(lighthouse.address, 2000);
    await lighthouse.refill(2000);
    const balance = await lighthouse.balances.call(accounts[0]);
    assert.equal(balance, 2000);
  });

  it("partial withdraw", async () => {
    await lighthouse.withdraw(900);
    const balance = await lighthouse.balances.call(accounts[0]);
    assert.equal(balance, 1100);
  });

  it("full withdraw", async () => {
    await lighthouse.withdraw(200);
    const balance = await lighthouse.balances.call(accounts[0]);
    assert.equal(balance, 0);
  });

  it("liability creation", async () => {
    await xrt.approve(lighthouse.address, 1000);
    await lighthouse.refill(1000);

    liability = await liabilityCreation(lighthouse, accounts[0], accounts[0], accounts[0]);
  });

  it("liability finalization", async () => {
    const originBalance = (await xrt.balanceOf(accounts[0])).toNumber();

    await liabilityFinalization(liability, lighthouse, accounts[0], accounts[0]);

    const currentBalance = (await xrt.balanceOf(accounts[0])).toNumber();
    const deltaB = currentBalance - originBalance;
    console.log("emission: " + deltaB + " wn");

    assert.equal(deltaB - 1, (await factory.gasUtilizing.call(liability.address)).toNumber() * 6);
  });

  it("marker marathon", async () => {
    await xrt.transfer(accounts[1], 1000);
    await xrt.approve(lighthouse.address, 1000, {from: accounts[1]});
    await lighthouse.refill(1000, {from: accounts[1]});

    await xrt.transfer(accounts[2], 2000);
    await xrt.approve(lighthouse.address, 2000, {from: accounts[2]});
    await lighthouse.refill(2000, {from: accounts[2]});

    async function markerLog() {
        const marker = await lighthouse.marker.call();
        const quota  = await lighthouse.quota.call();
        const member = await lighthouse.members.call(marker);
        console.log("m: " + marker + " q: " + quota + " a: " + member);
    }

    liability = await liabilityCreation(lighthouse, accounts[1], accounts[0], accounts[0]);
    await markerLog();

    await liabilityFinalization(liability, lighthouse, accounts[2], accounts[0]);
    await markerLog();

    liability = await liabilityCreation(lighthouse, accounts[2], accounts[0], accounts[0]);
    await markerLog();

    await liabilityFinalization(liability, lighthouse, accounts[0], accounts[0]);
    await markerLog();

    liability = await liabilityCreation(lighthouse, accounts[1], accounts[0], accounts[0]);
    await markerLog();

    await liabilityFinalization(liability, lighthouse, accounts[2], accounts[0]);
    await markerLog();

    liability = await liabilityCreation(lighthouse, accounts[2], accounts[0], accounts[0]);
    await markerLog();

    await liabilityFinalization(liability, lighthouse, accounts[0], accounts[0]);
    await markerLog();

  });

  it("keepalive marathon", async () => {
    async function markerLog() {
      const marker = await lighthouse.marker.call();
      const quota  = await lighthouse.quota.call();
      const member = await lighthouse.members.call(marker);
      console.log("m: " + marker + " q: " + quota + " a: " + member);
    }

    function waitFor(blockNumber) {
      console.log('waiting for block ' + blockNumber);
      while (web3.eth.blockNumber < blockNumber)
        console.log('.');
    }

    liability = await liabilityCreation(lighthouse, accounts[1], accounts[0], accounts[0]);
    await markerLog();
    waitFor(web3.eth.blockNumber + 3);
    await liabilityFinalization(liability, lighthouse, accounts[0], accounts[0]);
    await markerLog();

    liability = await liabilityCreation(lighthouse, accounts[1], accounts[0], accounts[0]);
    await markerLog();
    waitFor(web3.eth.blockNumber + 3);
    await liabilityFinalization(liability, lighthouse, accounts[0], accounts[0]);
    await markerLog();

    liability = await liabilityCreation(lighthouse, accounts[1], accounts[0], accounts[0]);
    await markerLog();
    waitFor(web3.eth.blockNumber + 3);
    await liabilityFinalization(liability, lighthouse, accounts[0], accounts[0]);
    await markerLog();

  });

});
