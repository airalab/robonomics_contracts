/* Load libs */
var fs = require('fs');
var solc = require('solc');
var path = require('path');
var Promise = require('promise');
var recursive = require('recursive-readdir');

/* Merge the array of dicts */
function merge(dicts) {
    var res = {};
    for (var i in dicts)
        for (var k in dicts[i])
            res[k] = dicts[i][k];
    return res;
}

function load_libs(libsfile) {
    try { return JSON.parse(fs.readFileSync(libsfile).toString("utf8")); }
    catch(e) { console.log("WARN: No libs loaded!"); return {}; }
}

function save_libs(libsfile, libs) {
    fs.writeFileSync(libsfile, JSON.stringify(libs));
}

module.exports = {
    compile: function(dirs, cb) {
        var sources = dirs.map(function(dir) {
            return new Promise(function(resolve, reject) {
                // Recursive read all contracts
                recursive(dir, function(err, files) {
                    if (err) { reject(err); }

                    var sources = {};
                    for (var i in files) {
                        var v = files[i];
                        // Skip when is no Solidity sources
                        if (path.extname(v) != ".sol") continue;
                        var key = path.basename(path.dirname(v))
                                + "/"
                                + path.basename(v);
                        sources[key] = fs.readFileSync(v).toString('utf8');
                    }
                    resolve(sources);
                });
            });
        });
        Promise.all(sources).then(function (sources_array) {
            var compiled = solc.compile({sources: merge(sources_array)}, 1);
            cb(compiled.contracts);
        }).catch(function(e){console.log(e);});
    },

    link: function(libsfile, unlinked_binary) {
        var libs = load_libs(libsfile);
        for (var name in libs) {
            var re = new RegExp("__" + name + "_*", "g"); 
            var bin_address = libs[name].replace("0x", ""); 
            unlinked_binary = unlinked_binary.replace(re, bin_address);
        }
        return unlinked_binary;
    },

    reglib: function(libsfile, name, address) {
        var libs = load_libs(libsfile);
        libs[name] = address;
        save_libs(libsfile, libs);
    }
}
