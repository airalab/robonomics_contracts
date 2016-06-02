import './Token.sol';

contract TokenReal is Token {
    uint public fixedPoint;

    function TokenReal(string _name, string _symbol, uint _count, uint _fixed_point)
        Token(_name, _symbol, _count)
    { fixedPoint = _fixed_point; }
}
