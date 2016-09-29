pragma solidity ^0.4.2;

import 'token/SupplyChain.sol';

library CreatorSupplyChain {
    function create(address[] _parent, uint256 _value) returns (SupplyChain)
    { return new SupplyChain(_parent, _value); }

    function version() constant returns (string)
    { return "v0.4.9 (6024902c)"; }

    function abi() constant returns (string)
    { return '[{"constant":true,"inputs":[],"name":"value","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"parent","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_index","type":"uint256"}],"name":"txAt","outputs":[{"name":"","type":"uint256"},{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_comment","type":"string"}],"name":"txPush","outputs":[],"payable":false,"type":"function"},{"inputs":[{"name":"_parent","type":"address[]"},{"name":"_value","type":"uint256"}],"type":"constructor"}]'; }
}
