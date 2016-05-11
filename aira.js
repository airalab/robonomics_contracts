#!/usr/bin/env node

var soldir   = __dirname + "/sol";
var libsfile = __dirname + "/.libs.json";

var aira = require('./index');
var fs   = require('fs');

var libs = {};
try { libs = JSON.parse(fs.readFileSync(libsfile).toString("utf8")); }
catch(e) {console.log("WARN: No libs file found!");}

var contract = process.argv[2];

aira.compiler(soldir, function(out){
    var interface = out.contracts[contract].interface.replace("\n", "");
    var bytecode = out.contracts[contract].bytecode;
    var linked_bytecode = aira.linker(libs, bytecode);
    var result = aira.deployer({contract: contract,
                                interface: interface,
                                data: linked_bytecode,
                                args: [1,2,3]});
    console.log(result);
});
