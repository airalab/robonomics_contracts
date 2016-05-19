import 'token/TokenSpec.sol';

library FabricTokenSpec {
    function create(string _name, string _symbol, Knowledge _spec) returns (TokenSpec)
    { return new TokenSpec(_name, _symbol, _spec); } 
}
