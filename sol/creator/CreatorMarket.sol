import 'market/Market.sol';

library CreatorMarket {
    event Created(address indexed sender, address indexed instance);

    function create() returns (Market) {
        var inst = new Market();
        Created(msg.sender, inst);
        return inst;
    }

    function version() constant returns (string)
    { return "v0.4.0 (075857)"; }

    function abi() constant returns (string)
    { return '[{"constant":false,"inputs":[{"name":"_lot","type":"address"}],"name":"remove","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"first","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_lot","type":"address"}],"name":"contains","outputs":[{"name":"","type":"bool"}],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"size","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[{"name":"_current","type":"address"}],"name":"next","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_lot","type":"address"}],"name":"append","outputs":[],"type":"function"}]'; }
}
