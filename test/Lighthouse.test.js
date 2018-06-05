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

contract("Lighthouse", (accounts) => {
  const factory = LiabilityFactory.at(LiabilityFactory.address);
  const xrt = XRT.at(XRT.address);

  let lighthouse;
  let liability;

  it("should be created via factory", async () => {
    const result = await factory.createLighthouse(1000, 10, "test");
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
    const builder = LiabilityFactory.at(lighthouse.address);

    await xrt.approve(lighthouse.address, 1000);
    await lighthouse.refill(1000);

    const ask = randomAsk(accounts[0]);
    const bid = pairBid(ask, accounts[0]);

    await xrt.approve(LiabilityFactory.address, ask.cost + bid.lighthouseFee);

    const result = await builder.createLiability(encodeAsk(ask), encodeBid(bid));
    assert.equal(result.logs[0].event, "NewLiability");

    liability = Liability.at(result.logs[0].args.liability);

    const txgas = result.receipt.gasUsed;
    const gas = await factory.gasUtilizing.call(liability.address);
    const delta = txgas - gas.toNumber();
    console.log("gas:" + " tx = " + txgas + ", factory = " + gas.toNumber() + ", delta = " + delta); 
    assert.equal(delta, 0);
  });

  it("liability finalization", async () => {
    let gas = await factory.gasUtilizing.call(liability.address);

    const result = await lighthouse.to(liability.address, finalize(liability.address, accounts[0])); 

    const txgas = result.receipt.gasUsed;
    gas = (await factory.gasUtilizing.call(liability.address)).toNumber() - gas.toNumber();
    const delta = txgas - gas;
    console.log("gas:" + " tx = " + txgas + ", factory = " + gas + ", delta = " + delta); 

    const totalgas = await factory.totalGasUtilizing.call();
    console.log("total gas: " + totalgas.toNumber());

    assert.equal(delta, 0);
  });

});
