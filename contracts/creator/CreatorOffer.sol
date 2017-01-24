pragma solidity ^0.4.4;

import 'dao/Offer.sol';

library CreatorOffer {
    function create(string _description, address _token, uint256 _value, address _beneficiary, address _hard_offer) returns (Offer)
    { return new Offer(_description, _token, _value, _beneficiary, _hard_offer); }

    function version() constant returns (string)
    { return "v0.6.0 (1b4435b8)"; }

    function abi() constant returns (string)
    { return '[{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"signer","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"setOwner","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"accept","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"beneficiary","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"value","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"close","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"hammer","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"closed","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"description","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"destroy","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"hardOffer","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_hammer","type":"address"}],"name":"setHammer","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"token","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"inputs":[{"name":"_description","type":"string"},{"name":"_token","type":"address"},{"name":"_value","type":"uint256"},{"name":"_beneficiary","type":"address"},{"name":"_hard_offer","type":"address"}],"type":"constructor"}]'; }
}
