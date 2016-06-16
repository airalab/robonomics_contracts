import 'market/DAOMarketAgent.sol';

library CreatorDAOMarketAgent {
    function create(address _thesaurus, address _regulator) returns (DAOMarketAgent)
    { return new DAOMarketAgent(_thesaurus, _regulator); }

    function version() constant returns (string)
    { return "v0.4.0 (1f83e3ab)"; }

    function interface() constant returns (string)
    { return '[{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_token","type":"address"},{"name":"_value","type":"uint256"},{"name":"_price","type":"uint256"}],"name":"put","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_lot","type":"address"}],"name":"deal","outputs":[{"name":"","type":"bool"}],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"inputs":[{"name":"_thesaurus","type":"address"},{"name":"_regulator","type":"address"}],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_lot","type":"address"}],"name":"LotPlaced","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_lot","type":"address"}],"name":"LotDeal","type":"event"}]'; }
}
