pragma solidity ^0.4.2;

import 'market/DAOMarketAgent.sol';

library CreatorDAOMarketAgent {
    function create(address _regulator) returns (DAOMarketAgent)
    { return new DAOMarketAgent(_regulator); }

    function version() constant returns (string)
    { return "v0.4.9 (b6490d28)"; }

    function abi() constant returns (string)
    { return '[{"constant":false,"inputs":[{"name":"_lot","type":"address"}],"name":"deal","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"regulator","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"inputs":[{"name":"_regulator","type":"address"}],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_lot","type":"address"}],"name":"LotDeal","type":"event"}]'; }
}
