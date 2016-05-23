import 'token/TokenSpec.sol';

library FactoryTokenSpec {
    function create(string _name, string _symbol, address _spec) returns (TokenSpec)
    { return new TokenSpec(_name, _symbol, _spec); }
}
