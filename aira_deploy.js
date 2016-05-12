#!/usr/bin/env node

var aira = require('./index');
var Web3 = require('web3');
var fs   = require('fs');
var web3 = new Web3();

var mainsol  = __dirname + "/sol";
var libsfile = __dirname + "/.libs.json";

var argv = require('optimist')
    .usage('Usage: $0 -I [DIRS] -C [NAME] -A [ARGUMENTS] [--rpc] [--library]')
    .default({I: '', A: '[]', rpc: 'http://localhost:8545'})
    .boolean('library')
    .describe('I', 'Append source file dirs')
    .describe('C', 'Contract name')
    .describe('A', 'Contract constructor arguments [JSON]')
    .describe('library', 'Store deployed library address')
    .describe('rpc', 'Web3 RPC provider')
    .demand(['C'])
    .argv;

var soldirs = argv.I.split(':').filter(function(e){return e.length > 0});
soldirs.push(mainsol); 
var args = JSON.parse(argv.A); 
var contract = argv.C;
web3.setProvider(new web3.providers.HttpProvider(argv.rpc));

aira.compiler.compile(soldirs, function(compiled){
    var bytecode = compiled[contract].bytecode;
    var linked_bytecode = aira.compiler.link(libsfile, bytecode);
    var interface = compiled[contract].interface.replace("\n", "");
    aira.deploy(JSON.parse(interface), linked_bytecode, args, web3,
            function(contract_address) {
        console.log('Deployed: ' + contract_address);
        if (argv.library) {
            aira.compiler.reglib(libsfile, contract, contract_address);
        }
    });
});
