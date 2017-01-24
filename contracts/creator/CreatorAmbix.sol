pragma solidity ^0.4.4;

import 'token/Ambix.sol';

library CreatorAmbix {
    function create() returns (Ambix)
    { return new Ambix(); }

    function version() constant returns (string)
    { return "v0.6.0 (1b4435b8)"; }

    function abi() constant returns (string)
    { return '[{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"setOwner","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_index","type":"uint256"},{"name":"_source","type":"address[]"},{"name":"_coef","type":"uint256[]"}],"name":"setSource","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"},{"name":"","type":"uint256"}],"name":"rSource","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"hammer","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_sink","type":"address[]"},{"name":"_coef","type":"uint256[]"}],"name":"setSink","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"destroy","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"rSink","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"run","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"},{"name":"","type":"uint256"}],"name":"rSourceCoef","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_hammer","type":"address"}],"name":"setHammer","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"rSinkCoef","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"}]'; }
}
