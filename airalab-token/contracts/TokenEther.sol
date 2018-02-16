pragma solidity ^0.4.18;

import './Token.sol';

/**
 * @title Ethereum crypto currency extention for Token contract
 */
contract TokenEther is Token {
    function TokenEther(
        string _name,
        string _symbol
    ) public Token(_name, _symbol, 18, 0) {}

    /**
     * @dev This is the way to withdraw money from token
     * @param _value how many tokens withdraw from balance
     */
    function withdraw(uint _value) public {
        if (balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            totalSupply          -= _value;
            msg.sender.transfer(_value);
        }
    }

    /**
     * @dev This is the way to refill your token balance by ethers
     */
    function refill() public payable returns (bool) {
        balances[msg.sender] += msg.value;
        totalSupply          += msg.value;
        return true;
    }

    /**
     * @dev This method is called when money sended to contract address,
     *      a synonym for refill()
     */
    function () public payable {
        balances[msg.sender] += msg.value;
        totalSupply          += msg.value;
    }
}
