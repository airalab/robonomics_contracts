import './TokenEmission.sol';

/**
 * @dev The Token contract with fixed emission value
 */
contract TokenFixEmission is Token {
    uint public totalSupplyMax;

    function TokenFixEmission(string _name, string _symbol, uint _supply_max)
            Token(_name, _symbol)
    { totalSupplyMax = _supply_max; }

    function emission(uint _value) onlyOwner {
        if (totalSupply + _value <= totalSupplyMax)
            super.emission(_value);
    }
}
