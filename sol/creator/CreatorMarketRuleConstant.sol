import 'market/MarketRuleConstant.sol';

library CreatorMarketRuleConstant {
    function create(uint256 _emission) returns (MarketRuleConstant)
    { return new MarketRuleConstant(_emission); }

    function version() constant returns (string)
    { return "v0.4.0 (1b19fffb)"; }

    function interface() constant returns (string)
    { return '[{"constant":true,"inputs":[],"name":"emission","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_deal","type":"address"}],"name":"getEmission","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"inputs":[{"name":"_emission","type":"uint256"}],"type":"constructor"}]'; }
}
