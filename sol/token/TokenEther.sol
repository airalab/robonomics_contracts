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
            msg.sender.send(_value);
        }
    }

    /**
     * @dev This method is called when money sended to contract address,
     *      it increse your balance according to sended money
     */
    function () {
        balanceOf[msg.sender] += msg.value;
        totalSupply           += msg.value;
    }
}
