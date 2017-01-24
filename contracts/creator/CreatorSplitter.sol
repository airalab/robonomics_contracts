pragma solidity ^0.4.4;

import 'dao/Splitter.sol';

library CreatorSplitter {
    function create(address[] _accounts, uint8[] _parts) returns (Splitter)
    { return new Splitter(_accounts, _parts); }

    function version() constant returns (string)
    { return "v0.6.0 (1b4435b8)"; }

    function abi() constant returns (string)
    { return '[{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"setOwner","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"withdraw","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"hammer","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"destroy","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalReceived","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_hammer","type":"address"}],"name":"setHammer","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_index","type":"uint256"}],"name":"getHolder","outputs":[{"name":"","type":"address"},{"name":"","type":"uint8"},{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"_accounts","type":"address[]"},{"name":"_parts","type":"uint8[]"}],"type":"constructor"},{"payable":true,"type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"sender","type":"address"},{"indexed":true,"name":"value","type":"uint256"}],"name":"Received","type":"event"}]'; }
}
