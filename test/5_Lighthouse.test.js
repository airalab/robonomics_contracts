const { ensCheck, waiter } = require('./helpers/helpers')
const hardhat = require('hardhat');
const namehash = require('eth-ens-namehash').hash;
const Web3 = require('web3');
const fs = require('fs');

const provider = new Web3.providers.HttpProvider(
    hardhat.network.config.url
);
const web3 = new Web3(provider);

const sha3 = Web3.utils.sha3;
const config = require('../config');
const networkName = hardhat.network.name

const chai = require('chai');
chai.use(require('chai-as-promised'))
chai.use(require("bn-chai")(Web3.utils.BN));
chai.should();

let liability;
let lighthouse;
let accounts;
let tx;
const retryCounter = 100;
let report = [];

before(async function () {
    accounts = await hardhat.ethers.getSigners();
    const gasPrice = await hardhat.ethers.provider.getGasPrice();
    await deployments.fixture();
    contracts = {
        XRT: (await ethers.getContract('XRT')),
        ENS: (await ethers.getContract('ENS')),
        Liability: (await ethers.getContract('Liability')),
        Lighthouse: (await ethers.getContract('Lighthouse')),
        Factory: (await ethers.getContract('Factory')),
        PublicAmbix: (await ethers.getContract('PublicAmbix')),
        DutchAuction: (await ethers.getContract('DutchAuction')),
        Resolver: (await ethers.getContract('PublicResolver')),
    };

    await contracts.ENS.setSubnodeOwner(namehash(0), web3.utils.sha3('eth'), accounts[0].address);
    let result = await waiter({ func: contracts.ENS.owner, args: [namehash('eth')], value: accounts[0].address, retries: retryCounter });
    chai.expect(result).equal(accounts[0].address);

    await contracts.ENS.setSubnodeOwner(namehash('eth'), web3.utils.sha3('robonomics'), accounts[0].address);
    result = await waiter({ func: contracts.ENS.owner, args: [namehash('robonomics.eth')], value: accounts[0].address, retries: retryCounter });
    chai.expect(result).equal(accounts[0].address);

    const foundation = networkName.startsWith('mainnet')
        ? config['foundation']
        : accounts[0].address;

    contracts.XRT.network = networkName;
    const maxTokenSold = config['xrt']['genesis']['auction'];
    await contracts.XRT.addMinter(contracts.Factory.address);
    await contracts.XRT.transfer(foundation, config['xrt']['genesis']['foundation']);
    await contracts.XRT.transfer(contracts.PublicAmbix.address, config['xrt']['genesis']['ambix']);
    tx = await contracts.XRT.transfer(contracts.DutchAuction.address, maxTokenSold);
    const transferTx = await tx.wait(1);
    report.push({
        "name": "XRT transfer",
        "usedGas": transferTx["gasUsed"].toString(),
        "gasPrice": gasPrice.toString(),
        "tx": transferTx["transactionHash"]
    });

    result = await waiter({ func: contracts.XRT.balanceOf, args: [contracts.DutchAuction.address], value: maxTokenSold, retries: retryCounter });
    chai.expect(result).equal(config['xrt']['genesis']['auction']);

    await contracts.XRT.renounceMinter();

    await contracts.DutchAuction.setup(contracts.XRT.address, contracts.PublicAmbix.address);

    const generation = config['generation'];
    const robonomicsRoot = generation + '.robonomics.eth';

    await contracts.ENS.setSubnodeOwner(namehash('robonomics.eth'), sha3(generation), accounts[0].address);
    result = await waiter({ func: contracts.ENS.owner, args: [namehash(robonomicsRoot)], value: accounts[0].address, retries: retryCounter });
    chai.expect(result).equal(accounts[0].address);

    await contracts.ENS.setSubnodeOwner(namehash(robonomicsRoot), sha3('xrt'), accounts[0].address);
    await contracts.ENS.setSubnodeOwner(namehash(robonomicsRoot), sha3('ambix'), accounts[0].address);
    await contracts.ENS.setSubnodeOwner(namehash(robonomicsRoot), sha3('auction'), accounts[0].address);
    await contracts.ENS.setSubnodeOwner(namehash(robonomicsRoot), sha3('factory'), accounts[0].address);
    await contracts.ENS.setSubnodeOwner(namehash(robonomicsRoot), sha3('lighthouse'), accounts[0].address);
    result = await waiter({ func: contracts.ENS.owner, args: [namehash('lighthouse.' + robonomicsRoot)], value: accounts[0].address, retries: retryCounter });
    chai.expect(result).equal(accounts[0].address);


    await contracts.ENS.setResolver(namehash(robonomicsRoot), contracts.Resolver.address);
    result = await waiter({ func: contracts.ENS.resolver, args: [namehash(robonomicsRoot)], value: contracts.Resolver.address, retries: retryCounter });
    chai.expect(result).equal(contracts.Resolver.address);

    await contracts.ENS.setResolver(namehash('xrt.' + robonomicsRoot), contracts.Resolver.address);
    result = await waiter({ func: contracts.ENS.resolver, args: [namehash('xrt.' + robonomicsRoot)], value: contracts.Resolver.address, retries: retryCounter });
    chai.expect(result).equal(contracts.Resolver.address);

    await contracts.ENS.setResolver(namehash('ambix.' + robonomicsRoot), contracts.Resolver.address);
    result = await waiter({ func: contracts.ENS.resolver, args: [namehash('ambix.' + robonomicsRoot)], value: contracts.Resolver.address, retries: retryCounter });
    chai.expect(result).equal(contracts.Resolver.address);

    await contracts.ENS.setResolver(namehash('auction.' + robonomicsRoot), contracts.Resolver.address);
    result = await waiter({ func: contracts.ENS.resolver, args: [namehash('auction.' + robonomicsRoot)], value: contracts.Resolver.address, retries: retryCounter });
    chai.expect(result).equal(contracts.Resolver.address);

    await contracts.ENS.setResolver(namehash('factory.' + robonomicsRoot), contracts.Resolver.address);
    result = await waiter({ func: contracts.ENS.resolver, args: [namehash('factory.' + robonomicsRoot)], value: contracts.Resolver.address, retries: retryCounter });
    chai.expect(result).equal(contracts.Resolver.address);

    await contracts.ENS.setResolver(namehash('lighthouse.' + robonomicsRoot), contracts.Resolver.address);
    result = await waiter({ func: contracts.ENS.resolver, args: [namehash('lighthouse.' + robonomicsRoot)], value: contracts.Resolver.address, retries: retryCounter });
    chai.expect(result).equal(contracts.Resolver.address);

    await contracts.Resolver.setAddr(namehash('xrt.' + robonomicsRoot), contracts.XRT.address);
    await contracts.Resolver.setAddr(namehash('ambix.' + robonomicsRoot), contracts.PublicAmbix.address);
    await contracts.Resolver.setAddr(namehash('auction.' + robonomicsRoot), contracts.DutchAuction.address);
    await contracts.Resolver.setAddr(namehash('factory.' + robonomicsRoot), contracts.Factory.address);

    await contracts.ENS.setSubnodeOwner(namehash(robonomicsRoot), sha3('lighthouse'), contracts.Factory.address);
    result = await waiter({ func: contracts.ENS.owner, args: [namehash('lighthouse.' + robonomicsRoot)], value: contracts.Factory.address, retries: retryCounter });
    chai.expect(result).equal(contracts.Factory.address);
});

after(async function () {
    try {
        fs.appendFileSync("reports/Lighthouse_report.json", JSON.stringify(report));
    } catch (err) {
        console.log(err);
    }
});

async function randomDemand(account, lighthouse, factory) {
    blockNumber = await hardhat.network.provider.send("eth_blockNumber", []);
    let demand =
    {
        model: web3.utils.randomHex(34)
        , objective: web3.utils.randomHex(34)
        , token: contracts.XRT.address
        , cost: 1
        , lighthouse: lighthouse.address
        , validator: '0x0000000000000000000000000000000000000000'
        , validatorFee: 0
        , deadline: blockNumber + 1000
        , nonce: (await factory.nonceOf(account)).toNumber()
        , sender: account
    };

    const hash = web3.utils.soliditySha3(
        { t: 'bytes', v: demand.model },
        { t: 'bytes', v: demand.objective },
        { t: 'address', v: demand.token },
        { t: 'uint256', v: demand.cost },
        { t: 'address', v: demand.lighthouse },
        { t: 'address', v: demand.validator },
        { t: 'uint256', v: demand.validatorFee },
        { t: 'uint256', v: demand.deadline },
        { t: 'uint256', v: demand.nonce },
        { t: 'address', v: demand.sender }
    );
    demand.signature = await hardhat.network.provider.send("eth_sign", [account, hash]);

    return demand;
}

async function pairOffer(demand, factory, account) {
    let offer = Object.assign({}, demand);
    offer.nonce = (await factory.nonceOf(account)).toNumber();
    offer.lighthouseFee = 42;
    offer.sender = account;

    const hash = web3.utils.soliditySha3(
        { t: 'bytes', v: offer.model },
        { t: 'bytes', v: offer.objective },
        { t: 'address', v: offer.token },
        { t: 'uint256', v: offer.cost },
        { t: 'address', v: offer.validator },
        { t: 'address', v: offer.lighthouse },
        { t: 'uint256', v: offer.lighthouseFee },
        { t: 'uint256', v: offer.deadline },
        { t: 'uint256', v: offer.nonce },
        { t: 'address', v: offer.sender }
    );
    offer.signature = await hardhat.network.provider.send("eth_sign", [account, hash]);

    return offer;
}

function encodeDemand(demand) {
    return web3.eth.abi.encodeParameters(
        ['bytes'
            , 'bytes'
            , 'address'
            , 'uint256'
            , 'address'
            , 'address'
            , 'uint256'
            , 'uint256'
            , 'address'
            , 'bytes'
        ],
        [demand.model
            , demand.objective
            , demand.token
            , demand.cost
            , demand.lighthouse
            , demand.validator
            , demand.validatorFee
            , demand.deadline
            , demand.sender
            , demand.signature
        ]
    );
}

function encodeOffer(offer) {
    return web3.eth.abi.encodeParameters(
        ['bytes'
            , 'bytes'
            , 'address'
            , 'uint256'
            , 'address'
            , 'address'
            , 'uint256'
            , 'uint256'
            , 'address'
            , 'bytes'
        ],
        [offer.model
            , offer.objective
            , offer.token
            , offer.cost
            , offer.validator
            , offer.lighthouse
            , offer.lighthouseFee
            , offer.deadline
            , offer.sender
            , offer.signature
        ]
    );
}

async function liabilityCreation(lighthouse, account, promisee, promisor) {
    const demand = await randomDemand(promisee.address, lighthouse, contracts.Factory);
    const offer = await pairOffer(demand, contracts.Factory, promisor.address);

    await contracts.XRT.connect(promisee).increaseAllowance(contracts.Factory.address, demand.cost, { from: promisee.address });
    let allowance = await waiter({ func: contracts.XRT.allowance, args: [promisee.address, contracts.Factory.address], value: demand.cost, retries: retryCounter });
    chai.expect(allowance).equal(demand.cost);

    await contracts.XRT.connect(promisor).increaseAllowance(contracts.Factory.address, offer.lighthouseFee, { from: promisor.address });
    allowance = await waiter({ func: contracts.XRT.allowance, args: [promisor.address, contracts.Factory.address], value: offer.lighthouseFee, retries: retryCounter });
    chai.expect(allowance).equal(offer.lighthouseFee);

    const builder = await contracts.Factory.attach(lighthouse.address);
    const interfaceLiability = await builder.connect(account).createLiability(
        encodeDemand(demand),
        encodeOffer(offer),
        { from: account.address }
    );

    await new Promise((resolve) => { setTimeout(resolve, 60000); });
    const liabilityAddress = await builder.getLastCreatedLiabilityAddress();
    const liabilitInstanse = await contracts.Liability.attach(liabilityAddress);

    return liabilitInstanse;
}

async function liabilityFinalization(liability, lighthouse, account, promisor) {
    const result = web3.utils.randomHex(34);
    const hash = web3.utils.soliditySha3(
        { t: 'address', v: liability.address },
        { t: 'bytes', v: result },
        { t: 'bool', v: true }
    );
    const signature = await hardhat.network.provider.send("eth_sign", [promisor.address, hash]);

    await lighthouse.connect(account).finalizeLiability(
        liability.address,
        result,
        true,
        signature,
        { from: account.address }
    );

    const totalgas = await contracts.Factory.totalGasConsumed();
    console.log('total gas: ' + totalgas.toNumber());
}

describe('Factory interface', () => {
    it('should be able to create lighthouse', async () => {
        const gasPrice = await hardhat.ethers.provider.getGasPrice();
        const result = await contracts.Factory.createLighthouse(1000, 10, 'test');
        chai.expect(result.to).equal(contracts.Factory.address);
        const receipt = await result.wait(1);
        report.push({
            "name": "Factory create lighthouse",
            "usedGas": receipt["gasUsed"].toString(),
            "gasPrice": gasPrice.toString(),
            "tx": receipt["transactionHash"]
        });
        let node = await waiter({
            func: contracts.ENS.owner,
            args: [namehash('test.lighthouse.5.robonomics.eth')],
            value: contracts.Factory.address,
            retries: retryCounter
        });
        chai.expect(node).equal(contracts.Factory.address);

        const lighthouseAddress = await contracts.Factory.getLastCreatedLighthouseAddress();
        lighthouse = await contracts.Lighthouse.attach(lighthouseAddress);
        chai.expect((await contracts.Factory.isLighthouse(lighthouse.address))).equal(true);
    });


    it('should register lighthouse in ENS', async () => {
        await ensCheck('test.lighthouse', contracts.ENS.address);
    });
});

describe('Lighthouse staking', () => {
    it('stake placement', async () => {
        const gasPrice = await hardhat.ethers.provider.getGasPrice();
        tx = await contracts.XRT.connect(accounts[0]).increaseAllowance(lighthouse.address, 2000, { from: accounts[0].address });
        const receipt = await tx.wait(1);
        report.push({
            "name": "XRT increase allowance",
            "usedGas": receipt["gasUsed"].toString(),
            "gasPrice": gasPrice.toString(),
            "tx": receipt["transactionHash"]
        });
        let allowance = await waiter({ func: contracts.XRT.allowance, args: [accounts[0].address, lighthouse.address], value: '2000', retries: retryCounter });
        chai.expect(allowance).equal('2000');

        await lighthouse.connect(accounts[0]).refill(2000, { from: accounts[0].address });
        let stakes = await waiter({ func: lighthouse.stakes, args: [accounts[0].address], value: '2000', retries: retryCounter });
        chai.expect(stakes).equal('2000');
    });

    it('partial withdraw', async () => {
        await lighthouse.withdraw(900);
        let stakes = await waiter({ func: lighthouse.stakes, args: [accounts[0].address], value: '1100', retries: retryCounter });
        chai.expect(stakes).equal('1100');
    });

    it('full withdraw', async () => {
        await lighthouse.withdraw(200);
        let stakes = await waiter({ func: lighthouse.stakes, args: [accounts[0].address], value: '0', retries: retryCounter });
        chai.expect(stakes).equal('0');
    });
});

describe('Robot liability scenario', () => {
    // skip due to NDEV-2056
    it.skip('Liability creation', async () => {
        await contracts.XRT.connect(accounts[0]).increaseAllowance(lighthouse.address, 1000, { from: accounts[0].address });
        let allowance = await waiter({ func: contracts.XRT.allowance, args: [accounts[0].address, lighthouse.address], value: '1000', retries: retryCounter });
        chai.expect(allowance).equal('1000');
        await lighthouse.connect(accounts[0]).refill(1000, { from: accounts[0].address });

        await contracts.XRT.transfer(accounts[1].address, 1000);
        const result = await waiter({ func: contracts.XRT.balanceOf, args: [accounts[1].address], value: '1000', retries: retryCounter });
        chai.expect(result).equal('1000');

        const liability1 = await liabilityCreation(lighthouse, accounts[0], accounts[0], accounts[1]);
        liability = liability1;
    });

    it.skip('Liability finalization', async () => {
        const originBalance = await contracts.XRT.balanceOf(accounts[0].address);
        await liabilityFinalization(liability, lighthouse, accounts[0], accounts[1]);
        const currentBalance = await contracts.XRT.balanceOf(accounts[0].address);
        const deltaB = currentBalance.toNumber() - originBalance.toNumber();
        console.log('emission: ' + deltaB.toNumber() + ' wn');
        const gas = await contracts.Factory.gasConsumedOf(liability.address);
        chai.expect(await contracts.Factory.wnFromGas(gas)).equal(deltaB);
    });

    async function markerLog() {
        const marker = await lighthouse.marker();
        const quota = await lighthouse.quota();
        const provider = await lighthouse.providers(marker - 1);
        const ka = await lighthouse.keepAliveBlock();
        const block = await hardhat.network.provider.send("eth_blockNumber", []);
        const timeout = block - ka.toNumber();
        console.log('m: ' + marker + ' q: ' + quota + ' t: ' + timeout + ' a: ' + provider);
    }

    it.skip('Marker marathon', async () => {
        for (let i = 0; i < 15; ++i) {
            liability = await liabilityCreation(lighthouse, accounts[0], accounts[0], accounts[1]);
            await markerLog();

            await liabilityFinalization(liability, lighthouse, accounts[0], accounts[1]);
            await markerLog();
        }

        await contracts.XRT.transfer(accounts[1].address, 1000);
        const result = await waiter({ func: contracts.XRT.balanceOf, args: [accounts[1].address], value: 1000, retries: retryCounter });
        chai.expect(result).equal(1000);
        await contracts.XRT.connect(accounts[1]).increaseAllowance(lighthouse.address, 1000, { from: accounts[1].address });
        await lighthouse.connect(accounts[1]).refill(1000, { from: accounts[1] });

        for (let i = 0; i < 5; ++i) {
            liability = await liabilityCreation(lighthouse, accounts[0], accounts[0], accounts[1]);
            await markerLog();

            await liabilityFinalization(liability, lighthouse, accounts[1], accounts[1]);
            await markerLog();
        }

        await contracts.XRT.transfer(accounts[2].address, 2000);
        result = await waiter({ func: contracts.XRT.balanceOf, args: [accounts[2].address], value: 2000, retries: retryCounter });
        chai.expect(result).equal(2000);
        await contracts.XRT.connect(accounts[2]).increaseAllowance(lighthouse.address, 2000, { from: accounts[2].address });
        await lighthouse.connect(accounts[2]).refill(2000, { from: accounts[2].address });

        for (let i = 0; i < 2; ++i) {
            liability = await liabilityCreation(lighthouse, accounts[0], accounts[0], accounts[1]);
            await markerLog();

            await liabilityFinalization(liability, lighthouse, accounts[1], accounts[1]);
            await markerLog();

            liability = await liabilityCreation(lighthouse, accounts[0], accounts[0], accounts[1]);
            await markerLog();

            await liabilityFinalization(liability, lighthouse, accounts[2], accounts[1]);
            await markerLog();
        }

        await contracts.XRT.transfer(accounts[3].address, 1000);
        result = await waiter({ func: contracts.XRT.balanceOf, args: [accounts[3].address], value: 1000, retries: retryCounter });
        chai.expect(result).equal(1000);
        await contracts.XRT.connect(accounts[3]).increaseAllowance(lighthouse.address, 1000, { from: accounts[3].address });
        await lighthouse.connect(accounts[3]).refill(1000, { from: accounts[3].address });

        for (let i = 0; i < 2; ++i) {
            liability = await liabilityCreation(lighthouse, accounts[0], accounts[0], accounts[1]);
            await markerLog();

            await liabilityFinalization(liability, lighthouse, accounts[1], accounts[1]);
            await markerLog();

            liability = await liabilityCreation(lighthouse, accounts[2], accounts[0], accounts[1]);
            await markerLog();

            await liabilityFinalization(liability, lighthouse, accounts[2], accounts[1]);
            await markerLog();

            liability = await liabilityCreation(lighthouse, accounts[3], accounts[0], accounts[1]);
            await markerLog();

            await liabilityFinalization(liability, lighthouse, accounts[0], accounts[1]);
            await markerLog();

            liability = await liabilityCreation(lighthouse, accounts[1], accounts[0], accounts[1]);
            await markerLog();

            await liabilityFinalization(liability, lighthouse, accounts[2], accounts[1]);
            await markerLog();

            liability = await liabilityCreation(lighthouse, accounts[2], accounts[0], accounts[1]);
            await markerLog();

            await liabilityFinalization(liability, lighthouse, accounts[3], accounts[1]);
            await markerLog();
        }

    });

    it.skip('Keepalive marathon', async () => {
        async function waitTimeoutBlocks(blocks) {
            const timeoutBlock = await hardhat.network.provider.send("eth_blockNumber", []) + blocks;
            console.log('waiting for block ' + timeoutBlock + '...');
            while (await hardhat.network.provider.send("eth_blockNumber", []) < timeoutBlock) { }
        }

        const timeout = (await lighthouse.timeoutInBlocks()).toNumber();
        await new Promise((resolve) => { console.log('Timeout: ', timeout); resolve(); });

        liability = await liabilityCreation(lighthouse, accounts[0], accounts[0], accounts[1]);
        await markerLog();
        await waitTimeoutBlocks(timeout);
        await liabilityFinalization(liability, lighthouse, accounts[0], accounts[1]);
        await markerLog();

        liability = await liabilityCreation(lighthouse, accounts[1], accounts[0], accounts[1]);
        await markerLog();
        await waitTimeoutBlocks(timeout);
        await liabilityFinalization(liability, lighthouse, accounts[0], accounts[1]);
        await markerLog();

        liability = await liabilityCreation(lighthouse, accounts[1], accounts[0], accounts[1]);
        await markerLog();
        await waitTimeoutBlocks(timeout);
        await liabilityFinalization(liability, lighthouse, accounts[0], accounts[1]);
        await markerLog();

        liability = await liabilityCreation(lighthouse, accounts[1], accounts[0], accounts[1]);
        await markerLog();
        await waitTimeoutBlocks(timeout);
        await liabilityFinalization(liability, lighthouse, accounts[0], accounts[1]);
        await markerLog();
    });
});
