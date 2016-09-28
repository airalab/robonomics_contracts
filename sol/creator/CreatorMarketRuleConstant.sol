pragma solidity ^0.4.2;

import 'market/MarketRuleConstant.sol';

library CreatorMarketRuleConstant {
    function create(uint256 _emission) returns (MarketRuleConstant)
    { return new MarketRuleConstant(_emission); }

    function version() constant returns (string)
    { return "v0.4.9 (b6490d28)"; }

    function abi() constant returns (string)
    { return '[{"constant":true,"inputs":[],"name":"emission","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_deal","type":"address"}],"name":"getEmission","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"_emission","type":"uint256"}],"type":"constructor"}]'; }
}
