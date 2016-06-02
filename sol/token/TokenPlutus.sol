import './TokenFixEmission.sol';

contract TokenPlutus is TokenFixEmission {
    uint public pointPosition;

    function TokenPlutus(string _name, string _symbol, uint _total_max, uint _point_position)
        TokenFixEmission(_name, _symbol, _total_max)
    { pointPosition = _point_position; }
}
