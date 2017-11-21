pragma solidity ^0.4.18;
import 'token/Token.sol';
import 'common/Object.sol';

contract TokenSelling is Object {
    mapping(address => uint) public priceWei;

    /**
     * @dev Price setter
     * @param _token Token selector
     * @param _price New price
     */
    function setPrice(Token _token, uint _price) public onlyOwner
    { priceWei[_token] = _price; }

    /**
     * @dev Withraw trade balance
     */
    function withdraw() public onlyOwner
    { require (msg.sender.send(this.balance)); }

    /**
     * @dev Sale token by static price
     */
    function buy(Token _token) public payable returns (bool) {
        // Check self balance
        var value_token = msg.value / priceWei[_token];
        require (value_token <= _token.balanceOf(this));

        // Transfer tokens
        require (_token.transfer(msg.sender, value_token));
        return true;
    }
}
