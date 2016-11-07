pragma solidity ^0.4.2;

import 'dao/CoreModify.sol';

library CreatorCoreModify {
    function create(address _target) returns (CoreModify)
    { return new CoreModify(_target); }

    function version() constant returns (string)
    { return "v0.5.0 (041be4cf)"; }

    function abi() constant returns (string)
    { return '[{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"}],"name":"removeModule","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"run","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"target","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_module","type":"address"},{"name":"_abi","type":"string"},{"name":"_constant","type":"bool"}],"name":"setModule","outputs":[],"payable":false,"type":"function"},{"inputs":[{"name":"_target","type":"address"}],"type":"constructor"}]'; }
}
