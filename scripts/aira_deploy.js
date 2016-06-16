var aira = require('../index');
var Web3 = require('web3');
var path = require('path');
var web3 = new Web3();

var version = require('../package.json').version;
require('child_process').exec('git rev-parse HEAD', function (err, result) {
    if (!result.toString().match('fatal'))
        version += ' (' + result.toString().slice(0, 8) + ')';
});

const mainsol  = __dirname + '/../sol';
const cachedir = __dirname + '/../.cache';
const libsfile = __dirname + '/../.libs.json';

var argv = require('optimist')
    .usage('AIRA Deploy :: version '+version+'\n\nUsage: $0 -I [DIRS] -C [NAME] -A [ARGUMENTS] [-O] [--rpc URI] [--library] [--creator] [--abi] [--bytecode]')
    .default({I: '', A: '[]', rpc: 'http://localhost:8545'})
    .boolean(['library', 'creator', 'abi', 'O'])
    .describe('I', 'Append source file dirs')
    .describe('C', 'Contract name')
    .describe('A', 'Contract constructor arguments [JSON]')
    .describe('O', 'Enable compiler optimization')
    .describe('rpc', 'Web3 RPC provider')
    .describe('library', 'Store deployed library address after deploy')
    .describe('creator', 'Generate contract creator library and exit')
    .describe('bytecode', 'Print compiled and linked bytecode')
    .describe('abi', 'Print contract ABI and exit')
    .demand(['C'])
    .argv;

var soldirs = argv.I.split(':').filter(function (e) {return e.length > 0});
soldirs.push(mainsol); 
var args = JSON.parse(argv.A); 
var contract = argv.C;
web3.setProvider(new web3.providers.HttpProvider(argv.rpc));

aira.compiler.compile(soldirs, cachedir, argv.O, function (compiled) {
    console.log('\nContract:\t' + contract);

    if (typeof(compiled.errors) != 'undefined') {
        console.log('An error occured:');
        // Print errors
        for (var i in compiled.errors)
            console.log(compiled.errors[i]);
        return;
    }

    var bytecode = compiled.contracts[contract].bytecode;
    var linked_bytecode = aira.compiler.link(libsfile, bytecode);
    var interface = compiled.contracts[contract].interface.replace("\n", "");

    console.log('Binary size:\t' + linked_bytecode.length / 2 / 1024 + "K\n");
    if (argv.bytecode) console.log('Bytecode: '+linked_bytecode);

    if (argv.abi) {
        // Print contract ABI
        console.log('var '+contract+' = '+interface+';');
    } else if (argv.creator) {
        // Generate creator library
        aira.codegen.creator(compiled, contract, soldirs[0], version); 
    } else {
        // Deploy contract
        aira.deploy(JSON.parse(interface), linked_bytecode, args, web3,
                    function (contract_address) {
            if (argv.library)
                aira.compiler.reglib(libsfile, contract, contract_address);
            
            console.log('Deployed: ' + contract_address);
        });
    }
});
