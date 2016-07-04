import 'market/DAOMarketAgent.sol';

library CreatorDAOMarketAgent {
    function create(address _regulator) returns (DAOMarketAgent)
    { return new DAOMarketAgent(_regulator); }

    function version() constant returns (string)
    { return "v0.4.0 (1b19fffb)"; }

    function interface() constant returns (string)
    { return '[{"constant":false,"inputs":[{"name":"_lot","type":"address"}],"name":"deal","outputs":[{"name":"","type":"bool"}],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"regulator","outputs":[{"name":"","type":"address"}],"type":"function"},{"inputs":[{"name":"_regulator","type":"address"}],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_lot","type":"address"}],"name":"LotDeal","type":"event"}]'; }
}
