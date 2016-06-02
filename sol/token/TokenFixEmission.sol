import './TokenEmission.sol';

/**
 * @dev The Token contract with fixed emission value
 */
contract TokenFixEmission is TokenEmission {
    uint public totalSupplyMax;

    function TokenFixEmission(string _name, string _symbol, uint _start_count, uint _supply_max)
            TokenEmission(_name, _symbol, _start_count)
    { totalSupplyMax = _supply_max; }

    function emission(uint _value) onlyOwner {
        if (totalSupply + _value <= totalSupplyMax)
            super.emission(_value);
    }
}
