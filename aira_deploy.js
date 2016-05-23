#!/usr/bin/env node

var aira = require('./index');
var Web3 = require('web3');
var fs   = require('fs');
var web3 = new Web3();

var mainsol  = __dirname + "/sol";
var libsfile = __dirname + "/.libs.json";

var argv = require('optimist')
    .usage('Usage: $0 -I [DIRS] -C [NAME] -A [ARGUMENTS] [-O] [--rpc] [--library] [--factory] [--abi]')
    .default({I: '', A: '[]', rpc: 'http://localhost:8545'})
    .boolean(['library', 'factory', 'abi', 'O'])
    .describe('I', 'Append source file dirs')
    .describe('C', 'Contract name')
    .describe('A', 'Contract constructor arguments [JSON]')
    .describe('O', 'Enable optimization')
    .describe('library', 'Store deployed library address after deploy')
    .describe('factory', 'Generate contract factory library and exit')
    .describe('abi', 'Print contract ABI and exit')
    .describe('rpc', 'Web3 RPC provider')
    .demand(['C'])
    .argv;

var soldirs = argv.I.split(':').filter(function(e){return e.length > 0});
soldirs.push(mainsol); 
var args = JSON.parse(argv.A); 
var contract = argv.C;
web3.setProvider(new web3.providers.HttpProvider(argv.rpc));

aira.compiler.compile(soldirs, argv.O, function(compiled){
    console.log('Contract:\t' + contract);

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
    var interface_json = JSON.parse(interface);

    //console.log('Bytecode: '+linked_bytecode);
    console.log('Binary size:\t' + linked_bytecode.length / 2 / 1024 + "K");

    if (argv.abi) {
        // Print contract ABI
        console.log('var '+contract+' = '+interface+';');
    } else if (argv.factory) {
        // Get constructor
        var constructor = {};
        for (var i in interface_json)
            if (interface_json[i].type = 'constructor'
                && typeof(interface_json[i].name) == 'undefined') {
                constructor = interface_json[i];
                break;
            }
        // Render args
        var constructor_typed_args = '';
        var constructor_args = '';
        for (var i in constructor.inputs) {
            var input = constructor.inputs[i];
            constructor_typed_args += ', '+input.type+' '+input.name; 
            constructor_args += ', '+input.name; 
        }
        constructor_typed_args = constructor_typed_args.substr(2);
        constructor_args = constructor_args.substr(2);

        // Take contract full name
        var full_name = '';
        for (var i in compiled.sources)
            if (i.match('/'+contract+'.sol')) {
                full_name = i;
                break;
            }

        var factory_source = 'import \''+full_name+'\';\n\nlibrary Factory'+contract+' {\n    function create('+constructor_typed_args+') returns ('+contract+')\n    { return new '+contract+'('+constructor_args+'); }\n}\n';
        var factory_filename = soldirs[0]+'/factory/Factory'+contract+'.sol'; 
        fs.writeFileSync(factory_filename, factory_source);
        console.log('Factory writen in `'+factory_filename+'`');

    } else {
        // Deploy contract
        aira.deploy(JSON.parse(interface), linked_bytecode, args, web3,
                function(contract_address) {
            console.log('Deployed: ' + contract_address);
            if (argv.library) {
                aira.compiler.reglib(libsfile, contract, contract_address);
            }
        });
    }
});
