pragma solidity ^0.4.4;

import 'dao/Splitter.sol';

library CreatorSplitter {
    function create() returns (Splitter)
    { return new Splitter(); }

    function version() constant returns (string)
    { return "v0.5.0 (89f18671)"; }

    function abi() constant returns (string)
    { return '[{"constant":false,"inputs":[{"name":"_destination","type":"address"}],"name":"remove","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_destination","type":"address"},{"name":"_percent","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"withdraw","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"first","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_current","type":"address"}],"name":"next","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"summary","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"percent","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"token","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"inputs":[{"name":"_token_ether","type":"address"}],"type":"constructor"},{"payable":false,"type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"sender","type":"address"},{"indexed":true,"name":"value","type":"uint256"}],"name":"Received","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"to","type":"address"},{"indexed":true,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]'; }
}
