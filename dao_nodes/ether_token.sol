import 'token.sol';

/**
 * Ethereum crypto currency extention for Token contract
 */
contract EtherToken is Token {
    function EtherToken() Token("Wei", "EthContractWallet") {}

    /**
     * This methods increse your balance according to sended money
     */
    function loadBalance() {
        token.balanceOf[msg.sender] += msg.value;
        token.total                 += msg.value;
    }

    /**
     * This is the way to withdraw money from token
     */
    function withdraw(uint _value) {
        if (token.balanceOf[msg.sender] >= _value) {
            token.balanceOf[msg.sender] -= _value;
            token.total                 -= _value;
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
