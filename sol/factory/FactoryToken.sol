import 'token/Token.sol';

library FactoryToken {
    function create(string _name, string _symbol) returns (Token)
    { return new Token(_name, _symbol); }
}
