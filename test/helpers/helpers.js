async function ensCheck(subdomain) {
    // TODO
    return true;
}

function kyc(web3, signer, contract, sender) {
    const hash = web3.utils.soliditySha3(
        {t: 'address', v: contract},
        {t: 'address', v: sender}
    );
    return web3.eth.sign(hash, signer);
}

module.exports = {
    ensCheck,
    kyc
}
