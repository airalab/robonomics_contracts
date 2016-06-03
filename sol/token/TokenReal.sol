import './Token.sol';

contract TokenReal is Token {
    uint8 public decimals;

    function TokenReal(string _name, string _symbol, uint _count, uint8 _decimals)
        Token(_name, _symbol, _count)
    { decimals = _decimals; }
}
