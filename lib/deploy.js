module.exports = function (abi, binary, args, web3, cb) {
    var contract = web3.eth.contract(abi); 
    var args = args.concat([
            { from: web3.eth.accounts[0],
              data: binary,
              gas:  3000000 }, function(e, contract) {
                  if (typeof contract != 'undefined' && typeof contract.address != 'undefined') 
                      cb(contract.address);
                  else if (e) console.log(e);
              }]);
    //console.log(args);
    contract.new.apply(contract, args);
}
