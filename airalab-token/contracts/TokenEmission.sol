pragma solidity ^0.4.18;

import './Token.sol';

contract TokenEmission is Token {
    function TokenEmission(
        string _name,
        string _symbol,
        uint8 _decimals,
        uint _start_count
    ) public Token(_name, _symbol, _decimals, _start_count) {}

    /**
     * @dev Token emission
     * @param _value amount of token values to emit
     * @notice owner balance will be increased by `_value`
     */
    function emission(uint _value) public onlyOwner {
        // Overflow check
        require(_value + totalSupply > totalSupply);

        totalSupply     += _value;
        balances[owner] += _value;
    }
 
    /**
     * @dev Burn the token values from sender balance and from total
     * @param _value amount of token values for burn 
     * @notice sender balance will be decreased by `_value`
     */
    function burn(uint _value) public {
        if (balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            totalSupply          -= _value;
        }
    }
}
