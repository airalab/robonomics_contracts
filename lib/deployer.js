module.exports = function(params) {
    var format = require("string-template");
    return format("var {contract} = web3.eth.contract({interface});\n{contract}.new({args},\n\t{data: '{data}',\n\tgas: 3000000,\n\tfrom: web3.eth.accounts[0]},\n\tfunction(err, c){\n\tif(!err){\n\tif(!c.address) { console.log('Tx: '+c.transactionHash)} \n\telse {console.log('Deployed: '+c.address)}\n}});", params);
}
