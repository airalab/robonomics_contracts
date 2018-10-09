const LiabilityFactory = artifacts.require("LiabilityFactory");
const ENS = artifacts.require("ENS");
const Lighthouse = artifacts.require("LighthouseLib");
const Liability = artifacts.require("RobotLiabilityLib");
const XRT = artifacts.require("XRT");

const ethereum_ens = require("ethereum-ens");
const ens = new ethereum_ens(web3, ENS.address);
const namehash = require("eth-ens-namehash");
const utils = require("web3-utils");
const abi = require("web3-eth-abi");

function randomDemand(account) {
  let demand = { model:        utils.randomHex(34)
            , objective:    utils.randomHex(34)
            , token:        XRT.address
            , cost:         1
            , validator:    "0x0000000000000000000000000000000000000000"
            , validatorFee: 0
            , deadline:     web3.eth.blockNumber + 1000
            , nonce:        utils.randomHex(32)
            };
            
  const hash = utils.soliditySha3(
      {t: "bytes",   v: demand.model}
    , {t: "bytes",   v: demand.objective}
    , {t: "address", v: demand.token}
    , {t: "uint256", v: demand.cost}
    , {t: "address", v: demand.validator}
    , {t: "uint256", v: demand.validatorFee}
    , {t: "uint256", v: demand.deadline}
    , {t: "bytes32", v: demand.nonce}
  );
  demand.signature = web3.eth.sign(account, hash);

  return demand;
}

function pairOffer(demand, account) {
  let offer = Object.assign({}, demand);
  offer.nonce = utils.randomHex(32); 
  offer.lighthouseFee = 42;

  const hash = utils.soliditySha3(
      {t: "bytes",   v: offer.model}
    , {t: "bytes",   v: offer.objective}
    , {t: "address", v: offer.token}
    , {t: "uint256", v: offer.cost}
    , {t: "address", v: offer.validator}
    , {t: "uint256", v: offer.lighthouseFee}
    , {t: "uint256", v: offer.deadline}
    , {t: "bytes32", v: offer.nonce}
  );
  offer.signature = web3.eth.sign(account, hash);

  return offer;
}

function encodeDemand(demand) {
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
    [ demand.model
    , demand.objective
    , demand.token
    , demand.cost
    , demand.validator
    , demand.validatorFee
    , demand.deadline
    , demand.nonce
    , demand.signature
    ]
  );
}

function encodeOffer(offer) {
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
    [ offer.model
    , offer.objective
    , offer.token
    , offer.cost
    , offer.validator
    , offer.lighthouseFee
    , offer.deadline
    , offer.nonce
    , offer.signature
    ]
  );
}

function finalize(liability, account) {
  const finalizeAbi = Liability.abi.find((e) => { return e.name == "finalize"; });

  const result = utils.randomHex(34);
  const hash = utils.soliditySha3(
      {t: "address",   v: liability}
    , {t: "bytes",     v: result}
    , {t: "bool",      v: true}
  );

  return abi.encodeFunctionCall(finalizeAbi, [result, true, web3.eth.sign(account, hash), true]); 
}

async function liabilityCreation(lighthouse, account, promisee, promisor) {
  const factory = LiabilityFactory.at(LiabilityFactory.address);
  const xrt = XRT.at(XRT.address);

  const builder = LiabilityFactory.at(lighthouse.address);

  const demand = randomDemand(promisee);
  const offer = pairOffer(demand, promisor);

  await xrt.increaseAllowance(LiabilityFactory.address, demand.cost, {from: promisee});
  await xrt.increaseAllowance(LiabilityFactory.address, offer.lighthouseFee, {from: promisor});

  const result = await builder.createLiability(encodeDemand(demand), encodeOffer(offer), {from: account});
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
    const result = await factory.createLighthouse(1000, 10, "test");
    assert.equal(result.logs[0].event, "NewLighthouse");

    lighthouse = Lighthouse.at(result.logs[0].args.lighthouse);

    const registered = await factory.isLighthouse(lighthouse.address);
    assert.equal(registered, true);
  });

  it("should be resolved via ENS", async () => {
    const addr = await ens.resolver("test.lighthouse.2.robonomics.eth").addr();
    assert.equal(addr, lighthouse.address);
  });

  it("security placement", async () => {
    await xrt.increaseAllowance(lighthouse.address, 2000);
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
    await xrt.increaseAllowance(lighthouse.address, 1000);
    await lighthouse.refill(1000);

    liability = await liabilityCreation(lighthouse, accounts[0], accounts[0], accounts[0]);
  });

  it("liability finalization", async () => {
    const originBalance = (await xrt.balanceOf(accounts[0])).toNumber();

    await liabilityFinalization(liability, lighthouse, accounts[0], accounts[0]);

    const currentBalance = (await xrt.balanceOf(accounts[0])).toNumber();
    const deltaB = currentBalance - originBalance;
    console.log("emission: " + (deltaB - 1) + " wn");

    const gas = await factory.gasUtilizing.call(liability.address);
    const wn = await factory.wnFromGas.call(gas);
    assert.equal(deltaB - 1, wn);
  });

  it("marker marathon", async () => {
    await xrt.transfer(accounts[1], 1000);
    await xrt.increaseAllowance(lighthouse.address, 1000, {from: accounts[1]});
    await lighthouse.refill(1000, {from: accounts[1]});

    await xrt.transfer(accounts[2], 2000);
    await xrt.increaseAllowance(lighthouse.address, 2000, {from: accounts[2]});
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
      console.log('waiting for block ' + blockNumber + '...');
      while (web3.eth.blockNumber < blockNumber) {}
    }

    const timeout = await lighthouse.timeoutBlocks.call();

    liability = await liabilityCreation(lighthouse, accounts[1], accounts[0], accounts[0]);
    await markerLog();
    waitFor(web3.eth.blockNumber + timeout.toNumber());
    await liabilityFinalization(liability, lighthouse, accounts[0], accounts[0]);
    await markerLog();

    liability = await liabilityCreation(lighthouse, accounts[1], accounts[0], accounts[0]);
    await markerLog();
    waitFor(web3.eth.blockNumber + timeout.toNumber());
    await liabilityFinalization(liability, lighthouse, accounts[0], accounts[0]);
    await markerLog();

    liability = await liabilityCreation(lighthouse, accounts[1], accounts[0], accounts[0]);
    await markerLog();
    waitFor(web3.eth.blockNumber + timeout.toNumber());
    await liabilityFinalization(liability, lighthouse, accounts[0], accounts[0]);
    await markerLog();

    liability = await liabilityCreation(lighthouse, accounts[1], accounts[0], accounts[0]);
    await markerLog();
    waitFor(web3.eth.blockNumber + timeout.toNumber());
    await liabilityFinalization(liability, lighthouse, accounts[0], accounts[0]);
    await markerLog();

  });

});
