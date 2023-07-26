const hardhat = require('hardhat');
var Web3 = require('web3');
const { ethers } = require('hardhat');
var web3 = new Web3('http://localhost:9090');

// var web3 = require('web3');

async function ensCheck(subdomain) {
    // TODO
    return true;
}

async function kyc(signer, contract, sender) {
    const hash = web3.utils.soliditySha3(
        { t: 'address', v: contract },
        { t: 'address', v: sender }
    );
    console.log("hash", hash);
    console.log("signer", signer);
    // signature = await web3.eth.sign(hash, signer);
    signature = await hardhat.network.provider.send("eth_sign", [signer, hash]);
    console.log("result:", signature);
    return signature;
}

async function waiter({func, args, value, retries = 10}) {
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
