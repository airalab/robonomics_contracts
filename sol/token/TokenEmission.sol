import './Token.sol';

contract TokenEmission is Token {
    function TokenEmission(string _name, string _symbol, uint8 _decimals,
                           uint _start_count)
             Token(_name, _symbol, _decimals, _start_count)
    {}

    /**
     * @dev Token emission
     * @param _value amount of token values to emit
     * @notice owner balance will be increased by `_value`
     */
    function emission(uint _value) onlyOwner {
        // Overflow check
        if (_value + totalSupply < totalSupply) throw;

        totalSupply      += _value;
        balanceOf[owner] += _value;
    }
 
    /**
     * @dev Burn the token values from owner balance and from total
     * @param _value amount of token values for burn 
     * @notice owner balance will be decreased by `_value`
     */
    function burn(uint _value) onlyOwner {
        if (balanceOf[owner] >= _value) {
            balanceOf[owner] -= _value;
            totalSupply      -= _value;
        }
    }
}
