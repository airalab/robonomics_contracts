import 'dao/CoreModify.sol';

library CreatorCoreModify {
    function create(address _target) returns (CoreModify)
    { return new CoreModify(_target); }

    function version() constant returns (string)
    { return "v0.4.9 (922689d1)"; }

    function interface() constant returns (string)
    { return '[{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"}],"name":"removeModule","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"run","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"target","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_module","type":"address"},{"name":"_interface","type":"string"},{"name":"_constant","type":"bool"}],"name":"setModule","outputs":[],"type":"function"},{"inputs":[{"name":"_target","type":"address"}],"type":"constructor"}]'; }
}
