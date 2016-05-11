module.exports = function(libs, unlinked_binary) {
    for (var name in libs) {
        var re = new RegExp("__"+name+"_*", "g"); 
        var bin_address = libs[name].replace("0x", ""); 
        unlinked_binary = unlinked_binary.replace(re, bin_address);
    }
    return unlinked_binary;
}
