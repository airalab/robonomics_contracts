import 'dao/Shareholder.sol';

library CreatorShareholder {
    function create(string _description, address _shares, uint256 _count, address _recipient) returns (Shareholder)
    { return new Shareholder(_description, _shares, _count, _recipient); }

    function version() constant returns (string)
    { return "v0.4.9 (7b7a3ce5)"; }

    function interface() constant returns (string)
    { return '[{"constant":true,"inputs":[],"name":"shares","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"count","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[],"name":"sign","outputs":[],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"complete","outputs":[{"name":"","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"recipient","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"inputs":[{"name":"_shares","type":"address"},{"name":"_count","type":"uint256"},{"name":"_recipient","type":"address"}],"type":"constructor"}]'; }
}
