pragma solidity ^0.4.4;
import 'token/Token.sol';
import 'common/Object.sol';

contract TokenSelling is Object {
    Token public token;
    uint  public price_wei;

    /**
     * @dev Price setter
     * @param _price_wei New price
     */
    function setPrice(uint _price_wei) onlyOwner
    { price_wei = _price_wei; }

    /**
     * @dev Contract constructor
     * @param _token Sale token
     * @param _price_wei Static price
     */
    function TokenSelling(address _token, uint _price_wei) {
        token = Token(_token);
        price_wei = _price_wei;
    }

    /**
     * @dev Sale token by static price
     */
    function buy() payable returns (bool) {
        // Check self balance
        var value_token = msg.value / price_wei;
        if (value_token > token.balanceOf(this)) throw;

        // Transfer tokens
        if (!token.transfer(msg.sender, value_token)) throw;
        return true;
    }
}
