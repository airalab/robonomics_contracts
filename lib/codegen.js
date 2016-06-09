var fs   = require('fs');

module.exports = {
    creator: function(compiled, contract, dir, version) {
        var interface = compiled.contracts[contract].interface.replace("\n", "");
        var interface_json = JSON.parse(interface);
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

        var source = 'import \''+full_name+'\';\n\nlibrary Creator'+contract+' {\n    function create('+constructor_typed_args+') returns ('+contract+')\n    { return new '+contract+'('+constructor_args+'); }\n\n    function version() constant returns (string)\n    { return "v'+version+'"; }\n\n    function interface() constant returns (string)\n    { return \''+interface+'\'; }\n}\n';
        var filename = dir+'/creator/Creator'+contract+'.sol'; 
        fs.writeFileSync(filename, source);
        console.log('Creator writen in '+filename);
    }
}
