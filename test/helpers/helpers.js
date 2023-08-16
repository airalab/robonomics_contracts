const hardhat = require('hardhat');
const web3 = require('web3');
const eth = require('web3-eth-accounts');
const accounts = new eth();


async function ensCheck(subdomain) {
    // TODO
    return true;
}

async function kyc(signer, contract, sender) {
    const hash = web3.utils.soliditySha3(
        { t: 'address', v: contract },
        { t: 'address', v: sender }
    );

    const result = await accounts.sign(hash, signer);
    return result.signature;
}

async function waiter({ func, args, value, retries = 10 }) {
    return smartWaiter({ func, args, check: (r) => r == value, retries: retries });
}

async function smartWaiter({ func, args, check, retries = 10 }) {
    let result;
    let counter = 0;
    while (!check(result) && counter < retries) {
        await new Promise(r => setTimeout(r, 200));
        if (args != undefined)
            result = await func(...args);
        else {
            result = await func();
        }
        counter++;
    }
    return result;
}

module.exports = {
    ensCheck,
    kyc,
    waiter,
    smartWaiter,
}
