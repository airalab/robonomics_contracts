/* Load libs */
var fs = require('fs');
var solc = require('solc');
var path = require('path');
var Promise = require('promise');
var recursive = require('recursive-readdir');
var hashFiles = require('hash-files');

function sol_files(dirs, cb) {
    var files = dirs.map(function(dir) {
        return new Promise(function(resolve, reject) {
            // Recursive read all contracts
            recursive(dir, function(err, files) {
                if (err) { reject(err); }

                var res = [];
                for (var i in files) {
                    var v = files[i];
                    // Skip when is no Solidity sources
                    if (path.extname(v) != ".sol") continue;
                    res.push(v);
                }
                resolve(res);
            });
        });
    });
    Promise.all(files).then(function (files_array) {
        cb(Array.prototype.concat.apply([], files_array))
    }).catch(function(e){console.log(e);});
}

function take_source(filename) {
    var file = path.basename(path.dirname(filename))
             + "/"
             + path.basename(filename);
    return {file: file, source: fs.readFileSync(filename).toString('utf8')};
}

function load_libs(libsfile) {
    try { return JSON.parse(fs.readFileSync(libsfile).toString("utf8")); }
    catch(e) { console.log("WARN: No libs loaded!"); return {}; }
}

function save_libs(libsfile, libs) {
    fs.writeFileSync(libsfile, JSON.stringify(libs));
}

module.exports = {
    compile: function (dirs, cachedir, optimize, cb) {
        console.log('Compile...');
        sol_files(dirs, function (files) {
            hashFiles({files: files}, function (err, files_hash) {
                if (err) throw (err);

                var filename = cachedir+'/'+files_hash+'_O'+optimize+'.json'; 
                var compiled = {};
                try {
                    compiled = JSON.parse(fs.readFileSync(filename));
                    console.log('(cache)');
                } catch (e) {
                    var file_sources = files.map(take_source);
                    var sources = {};
                    for (var i in file_sources)
                        sources[file_sources[i].file] = file_sources[i].source;
                    compiled = solc.compile({sources: sources}, optimize);
                    fs.writeFile(filename, JSON.stringify(compiled));
                    console.log('(compiled)');
                }

                cb(compiled);
            });
        });
    },

    link: function (libsfile, unlinked_binary) {
        var libs = load_libs(libsfile);
        for (var name in libs) {
            var re = new RegExp("__" + name + "_+", "g");
            var bin_address = libs[name].replace("0x", ""); 
            unlinked_binary = unlinked_binary.replace(re, bin_address);
        }
        return unlinked_binary;
    },

    reglib: function (libsfile, name, address) {
        var libs = load_libs(libsfile);
        libs[name] = address;
        save_libs(libsfile, libs);
    }
}
