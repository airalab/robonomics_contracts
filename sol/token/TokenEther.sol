import './Token.sol';

/**
 * @title Ethereum crypto currency extention for Token contract
 */
contract TokenEther is Token {
    function TokenEther() Token("Wei", "EthContractWallet", 0) {}

    /**
     * @dev This methods increse your balance according to sended money
     */
    function loadBalance() {
        balanceOf[msg.sender] += msg.value;
        totalSupply           += msg.value;
    }

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

    function () {
        // This function gets executed if a
        // transaction with invalid data is sent to
        // the contract or just ether without data.
        // We revert the send so that no-one
        // accidentally loses money when using the
        // contract.
        throw;
    }
}
