const fs = require('fs');
const files = fs.readdirSync('./reports/');

let report = {
    "name": "Robonomics",
    "actions": []
  }

for (var i in files) {
    var data = JSON.parse(fs.readFileSync('./reports/' + files[i]));
    for (var j in data){
        report['actions'].push(data[j]);
    }
}

fs.writeFile("./reports/report.json", JSON.stringify(report), function(err) {
    if(err) {
        return console.log(err);
    }
    console.log("The report was saved!");
}); 