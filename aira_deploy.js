#!/usr/bin/env node

var aira = require('./index');
var Git = require("nodegit");
var Web3 = require('web3');
var path = require('path');
var web3 = new Web3();

var version = require('./package.json').version;
Git.Repository.open(path.resolve(__dirname, ".git"))
    .then((repo) => {return repo.getHeadCommit();})
    .then((commit) => {
        var gitsha = commit.sha().slice(0,6);
        if (gitsha.length > 0)
            version += ' ('+gitsha+')';
    })
    .catch((e) => {console.log('This directory is not seems as git repository');});

var mainsol  = __dirname + '/sol';
var cachedir = __dirname + '/.cache';
var libsfile = __dirname + '/.libs.json';

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

var soldirs = argv.I.split(':').filter((e) => {return e.length > 0});
soldirs.push(mainsol); 
var args = JSON.parse(argv.A); 
var contract = argv.C;
web3.setProvider(new web3.providers.HttpProvider(argv.rpc));

aira.compiler.compile(soldirs, cachedir, argv.O, (compiled) => {
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

    if (argv.bytecode) console.log('Bytecode: '+linked_bytecode);
    console.log('Binary size:\t' + linked_bytecode.length / 2 / 1024 + "K");

    if (argv.abi) {
        // Print contract ABI
        console.log('var '+contract+' = '+interface+';');
    } else if (argv.creator) {
        // Generate creator library
        aira.codegen.creator(compiled, contract, soldirs[0], version); 
    } else {
        // Deploy contract
        aira.deploy(JSON.parse(interface), linked_bytecode, args, web3, (contract_address) => {
            if (argv.library)
                aira.compiler.reglib(libsfile, contract, contract_address);
            
            console.log('Deployed: ' + contract_address);
        });
    }
});
