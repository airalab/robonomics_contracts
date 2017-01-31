pragma solidity ^0.4.4;
import 'token/Token.sol';
import 'common/Object.sol';

contract TokenSelling is Object {
    mapping(address => uint) public priceWei;

    /**
     * @dev Price setter
     * @param _token Token selector
     * @param _price New price
     */
    function setPrice(Token _token, uint _price) onlyOwner
    { priceWei[_token] = _price; }

    /**
     * @dev Withraw trade balance
     */
    function withdraw() onlyOwner
    { if (!msg.sender.send(this.balance)) throw; }

    /**
     * @dev Sale token by static price
     */
    function buy(Token _token) payable returns (bool) {
        // Check self balance
        var value_token = msg.value / priceWei[_token];
        if (value_token > _token.balanceOf(this)) throw;

        // Transfer tokens
        if (!_token.transfer(msg.sender, value_token)) throw;
        return true;
    }
}
