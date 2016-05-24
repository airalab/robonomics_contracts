import 'cashflow/CashFlow.sol';

library FactoryCashFlow {
    function create(address _credits, address _shares) returns (CashFlow)
    { return new CashFlow(_credits, _shares); }
}
