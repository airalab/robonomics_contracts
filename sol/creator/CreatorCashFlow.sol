import 'cashflow/CashFlow.sol';

library CreatorCashFlow {

    function create(address _credits, address _shares) returns (CashFlow)
    { return new CashFlow(_credits, _shares); }

    function version() constant returns (string)
    { return "v0.4.0 (53f6eb)"; }

    function abi() constant returns (string)
    { return '[{"constant":true,"inputs":[],"name":"shares","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[{"name":"_target","type":"address"},{"name":"_current","type":"address"}],"name":"nextFunder","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"credits","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_target","type":"address"},{"name":"_total","type":"uint256"}],"name":"init","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_target","type":"address"},{"name":"_value","type":"uint256"}],"name":"refund","outputs":[],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_target","type":"address"},{"name":"_voter","type":"address"}],"name":"getValueOf","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_current","type":"address"}],"name":"nextTarget","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[{"name":"_target","type":"address"}],"name":"firstFunder","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_target","type":"address"},{"name":"_value","type":"uint256"}],"name":"fund","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[{"name":"_target","type":"address"}],"name":"get","outputs":[{"name":"","type":"bool"},{"name":"","type":"uint256"},{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[],"name":"firstTarget","outputs":[{"name":"","type":"address"}],"type":"function"},{"inputs":[{"name":"_credits","type":"address"},{"name":"_shares","type":"address"}],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"target","type":"address"},{"indexed":true,"name":"closed","type":"bool"}],"name":"TargetUpdated","type":"event"}]'; }
}
