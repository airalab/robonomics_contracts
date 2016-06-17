import './Token.sol';

/**
 * @title Ethereum crypto currency extention for Token contract
 */
contract TokenEther is Token {
    function TokenEther(string _name, string _symbol)
             Token(_name, _symbol, 18, 0)
    {}

    /**
     * @dev This is the way to withdraw money from token
     * @param _value how many tokens withdraw from balance
     */
    function withdraw(uint _value) {
        if (balanceOf[msg.sender] >= _value) {
            balanceOf[msg.sender] -= _value;
            totalSupply           -= _value;
            if(!msg.sender.send(_value)) throw;
        }
    }

    /**
     * @dev This is the way to refill your token balance by ethers
     */
    function refill() {
        balanceOf[msg.sender] += msg.value;
        totalSupply           += msg.value;
    }

    /**
     * @dev This method is called when money sended to contract address,
     *      a synonym for refill()
     */
    function () {
        balanceOf[msg.sender] += msg.value;
        totalSupply           += msg.value;
    }
}
