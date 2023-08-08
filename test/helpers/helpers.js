const hardhat = require('hardhat');
const web3 = require('web3');

async function ensCheck(subdomain) {
    // TODO
    return true;
}

async function kyc(signer, contract, sender) {
    const hash = web3.utils.soliditySha3(
        { t: 'address', v: contract },
        { t: 'address', v: sender }
    );

    const signature = await hardhat.network.provider.send("eth_sign", [signer, hash]);
    return signature;
}

async function waiter({ func, args, value, retries = 10 }) {
    let result;
    let counter = 0;
    while (result != value && counter < retries) {
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
}
