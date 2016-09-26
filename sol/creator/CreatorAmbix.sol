import 'token/Ambix.sol';

library CreatorAmbix {
    function create() returns (Ambix)
    { return new Ambix(); }

    function version() constant returns (string)
    { return "v0.4.9 (c84ea47d)"; }

    function interface() constant returns (string)
    { return '[{"constant":false,"inputs":[{"name":"_index","type":"uint256"},{"name":"_source","type":"address[]"},{"name":"_coef","type":"uint256[]"}],"name":"setSource","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"getSink","outputs":[{"name":"","type":"address[]"},{"name":"","type":"uint256[]"}],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_sink","type":"address[]"},{"name":"_coef","type":"uint256[]"}],"name":"setSink","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"run","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_index","type":"uint256"}],"name":"getSource","outputs":[{"name":"","type":"address[]"},{"name":"","type":"uint256[]"}],"type":"function"}]'; }
}
