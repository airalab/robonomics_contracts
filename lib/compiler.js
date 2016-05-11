module.exports = function(soldir, cb) {
    var fs = require('fs');
    var solc = require('solc');
    var path = require('path');
    var recursive = require('recursive-readdir');
    
    // Recursive read all contracts
    recursive(soldir, [function(name) {return name.match("swp*")}], function(err, files) {
        if (err) { console.log(err); return; }

        var sources = {};
        for (var i in files) {
            var v = files[i];
            var key = path.basename(path.dirname(v))
                    + "/"
                    + path.basename(v);
            sources[key] = fs.readFileSync(v).toString('utf8');
        }
        cb(solc.compile({sources: sources}, 0));
    });
}
