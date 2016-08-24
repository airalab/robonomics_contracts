var Lib = "0x20d0e368d9820b441ca72c2d5a26392e169ad1d3";

function iterate(first, next, printer) {
    for (var it = first(); it != 0; it = next(it))
        printer(it);
}

var Web3 = require('web3');
var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));

var LibAddressList = [{"constant":false,"inputs":[{"name":"_item","type":"address"}],"name":"remove","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"first","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_item","type":"address"}],"name":"prev","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"last","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"m","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_item","type":"address"}],"name":"contains","outputs":[{"name":"","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"}],"name":"replace","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_a","type":"address"},{"name":"_b","type":"address"}],"name":"swap","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_item","type":"address"},{"name":"_to","type":"address"}],"name":"appendTo","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_item","type":"address"}],"name":"next","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_item","type":"address"}],"name":"append","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_item","type":"address"}],"name":"prepend","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_item","type":"address"},{"name":"_to","type":"address"}],"name":"prependTo","outputs":[],"type":"function"}];
var liba = web3.eth.contract(LibAddressList).at(Lib);

function print_state() {
    console.log("first: " + liba.first() + " last: " + liba.last());

    console.log("\nForward:");
    iterate(liba.first, liba.next, console.log);
    
    console.log("\nBackward:");
    iterate(liba.last, liba.prev, console.log);
}

var ctx    = require("repl").start("> ").context;
ctx.web3   = web3;
ctx.liba   = liba;
ctx.state  = print_state;
