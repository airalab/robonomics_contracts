var aira = require('../index');
var fs = require('fs');

var version = require('../package.json').version;
require('child_process').exec('git rev-parse HEAD', function (err, result) {
    if (!result.toString().match('fatal'))
        version += ' (' + result.toString().slice(0, 8) + ')';
});

const mainsol  = __dirname + '/../contracts';
const cachedir = __dirname + '/../.cache';
const libsfile = __dirname + '/../.libs.json';

var argv = require('optimist')
    .usage('AIRA ABI :: version '+version+'\n\nUsage: $0 -I [DIRS] -C [NAME]')
    .default({'I': '', 'C': ''})
    .describe('I', 'Append source file dirs')
    .describe('C', 'Print only one contract ABI')
    .argv;

var soldirs = argv.I == '' ? [] : (typeof(argv.I) == 'string' ? [argv.I] : argv.I);
soldirs.push(mainsol); 

aira.compiler.compile(soldirs, cachedir, false, function (compiled) {
    if (typeof(compiled.errors) != 'undefined') {
        console.log('An error occured:');
        // Print errors
        for (var i in compiled.errors)
            console.log(compiled.errors[i]);
        return;
    }

    if (argv.C.length > 0) {
        console.log('\nContract:\t' + argv.C);
        console.log(compiled.contracts[argv.C].interface.replace("\n", ""));
    } else {
        for (var module in compiled.contracts) {
            console.log('Dumping '+module+'...');
            var abi = compiled.contracts[module].interface.replace("\n", "");

            if (module.startsWith('Builder')) {
                fs.writeFile('abi/builder/'+module+'.json', abi);
            } else if (module.startsWith('Creator')) {
                fs.writeFile('abi/creator/'+module+'.json', abi);
            } else {
                fs.writeFile('abi/modules/'+module+'.json', abi);
            }
        }
    }
});
