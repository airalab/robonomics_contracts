const { ensCheck } = require('./helpers/helpers')
const web3 = require('web3');
const chai = require('chai');
chai.use(require('chai-as-promised'))
chai.use(require("bn-chai")(web3.utils.BN));
chai.should();

let contracts;
let lighthouse;
let liability;
const [accounts] = hre.network.config.accounts;

before(async function () {
    await deployments.fixture();
    contracts = {
        XRT: (await ethers.getContract('XRT')),
        ENS: (await ethers.getContract('ENS')),
        Liability: (await ethers.getContract('Liability')),
        Lighthouse: (await ethers.getContract('Lighthouse')),
        Factory: (await ethers.getContract('Factory')),
    };
});

async function randomDemand(account, lighthouse, factory) {
    let demand =
    {
        model: web3.utils.randomHex(34)
        , objective: web3.utils.randomHex(34)
        , token: contracts.XRT.address
        , cost: 1
        , lighthouse: lighthouse.address
        , validator: '0x0000000000000000000000000000000000000000'
        , validatorFee: 0
        , deadline: await web3.eth.getBlockNumber() + 1000
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
    demand.signature = await web3.eth.sign(hash, account);

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
    offer.signature = await web3.eth.sign(hash, account);

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
    const demand = await randomDemand(promisee, lighthouse, contracts.Factory);
    const offer = await pairOffer(demand, factory, promisor);

    await contracts.XRT.increaseAllowance(contracts.Factory.address, demand.cost, { from: promisee });
    await contracts.XRT.increaseAllowance(contracts.Factory.address, offer.lighthouseFee, { from: promisor });

    const builder = await contracts.Factory.at(lighthouse.address);
    const tx = await builder.createLiability(
        encodeDemand(demand),
        encodeOffer(offer),
        { from: account }
    );
    assert.equal(tx.logs[0].event, 'NewLiability');

    const liability = await contracts.Liability.at(tx.logs[0].args.liability);

    const txgas = tx.receipt.gasUsed;
    const gas = await contracts.Factory.gasConsumedOf(liability.address);
    const delta = txgas - gas.toNumber();
    console.log('gas:' + ' tx = ' + txgas + ', factory = ' + gas.toNumber() + ', delta = ' + delta);

    return liability;
}

async function liabilityFinalization(liability, lighthouse, account, promisor) {
    let gas = await contracts.Factory.gasConsumedOf(liability.address);

    const result = web3.utils.randomHex(34);
    const hash = web3.utils.soliditySha3(
        { t: 'address', v: liability.address },
        { t: 'bytes', v: result },
        { t: 'bool', v: true }
    );
    const signature = await web3.eth.sign(hash, promisor);

    const tx = await lighthouse.finalizeLiability(
        liability.address,
        result,
        true,
        signature,
        { from: account }
    );

    const txgas = tx.receipt.gasUsed;
    gas = (await contracts.Factory.gasConsumedOf(liability.address)).sub(gas).toNumber();

    const delta = txgas - gas;
    console.log('gas:' + ' tx = ' + txgas + ', factory = ' + gas + ', delta = ' + delta);

    const totalgas = await factory.totalGasConsumed();
    console.log('total gas: ' + totalgas.toNumber());
}

    describe('factory interface', () => {
        it('should be able to create lighthouse', async () => {
            const result = await contracts.Factory.createLighthouse(1000, 10, 'test');
            assert.equal(result.logs[0].event, 'NewLighthouse');

            lighthouse = await contracts.Lighthouse.at(result.logs[0].args.lighthouse);
            chai.expect((await contracts.Factory.isLighthouse(lighthouse.address))).equal(true);
        });


        it('should register lighthouse in ENS', async () => {
            await ensCheck('test.lighthouse', contracts.ENS.address);
        });
    });

    describe('lighthouse staking', () => {
        it('stake placement', async () => {
            await contracts.XRT.increaseAllowance(lighthouse.address, 2000, { from: accounts[0] });
            await lighthouse.refill(2000, { from: accounts[0] });
            chai.expect(await lighthouse.stakes(accounts[0])).to.eq.BN(new web3.utils.BN('2000'));
        });

        it('partial withdraw', async () => {
            await lighthouse.withdraw(900, { from: accounts[0] });
            chai.expect(await lighthouse.stakes(accounts[0])).to.eq.BN(new web3.utils.BN('1100'));
        });

        it('full withdraw', async () => {
            await lighthouse.withdraw(200, { from: accounts[0] });
            chai.expect(await lighthouse.stakes(accounts[0])).to.eq.BN(new web3.utils.BN('0'));
        });
    });

    describe('robot liability scenario', () => {
        it('liability creation', async () => {
            await contracts.XRT.increaseAllowance(lighthouse.address, 1000, { from: accounts[0] });
            await lighthouse.refill(1000, { from: accounts[0] });

            await contracts.XRT.transfer(accounts[1], 1000);
            liability = await liabilityCreation(lighthouse, accounts[0], accounts[0], accounts[1]);
        });

        it('liability finalization', async () => {
            const originBalance = await contracts.XRT.balanceOf(accounts[0]);

            await liabilityFinalization(liability, lighthouse, accounts[0], accounts[1]);

            const currentBalance = await contracts.XRT.balanceOf(accounts[0]);
            const deltaB = currentBalance.sub(originBalance);
            console.log('emission: ' + deltaB.toNumber() + ' wn');

            const gas = await contracts.Factory.gasConsumedOf(liability.address);
            chai.expect(await contracts.Factory.wnFromGas(gas)).to.eq.BN(deltaB);
        });

        async function markerLog() {
            const marker = await lighthouse.marker();
            const quota = await lighthouse.quota();
            const provider = await lighthouse.providers(marker - 1);
            const ka = await lighthouse.keepAliveBlock();
            const block = await web3.eth.getBlockNumber();
            const timeout = block - ka.toNumber();
            console.log('m: ' + marker + ' q: ' + quota + ' t: ' + timeout + ' a: ' + provider);
        }

        it('marker marathon', async () => {
            for (let i = 0; i < 15; ++i) {
                liability = await liabilityCreation(lighthouse, accounts[0], accounts[0], accounts[1]);
                await markerLog();

                await liabilityFinalization(liability, lighthouse, accounts[0], accounts[1]);
                await markerLog();
            }

            await contracts.XRT.transfer(accounts[1], 1000);
            await contracts.XRT.increaseAllowance(lighthouse.address, 1000, { from: accounts[1] });
            await lighthouse.refill(1000, { from: accounts[1] });

            for (let i = 0; i < 5; ++i) {
                liability = await liabilityCreation(lighthouse, accounts[0], accounts[0], accounts[1]);
                await markerLog();

                await liabilityFinalization(liability, lighthouse, accounts[1], accounts[1]);
                await markerLog();
            }

            await contracts.XRT.transfer(accounts[2], 2000);
            await contracts.XRT.increaseAllowance(lighthouse.address, 2000, { from: accounts[2] });
            await lighthouse.refill(2000, { from: accounts[2] });

            for (let i = 0; i < 2; ++i) {
                liability = await liabilityCreation(lighthouse, accounts[0], accounts[0], accounts[1]);
                await markerLog();

                await liabilityFinalization(liability, lighthouse, accounts[1], accounts[1]);
                await markerLog();

                liability = await liabilityCreation(lighthouse, accounts[2], accounts[0], accounts[1]);
                await markerLog();

                await liabilityFinalization(liability, lighthouse, accounts[2], accounts[1]);
                await markerLog();
            }

            await contracts.XRT.transfer(accounts[3], 1000);
            await contracts.XRT.increaseAllowance(lighthouse.address, 1000, { from: accounts[3] });
            await lighthouse.refill(1000, { from: accounts[3] });

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

        it('keepalive marathon', async () => {
            async function waitTimeoutBlocks(blocks) {
                const timeoutBlock = await web3.eth.getBlockNumber() + blocks;
                console.log('waiting for block ' + timeoutBlock + '...');
                while (await web3.eth.getBlockNumber() < timeoutBlock) { }
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
