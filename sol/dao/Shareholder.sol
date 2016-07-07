import 'common/Mortal.sol';
import 'token/Token.sol';

contract Shareholder is Mortal {
    Token   public shares;
    uint    public count;
    address public recipient;
    bool    public complete = false;

    /**
     * @dev Shareholder contract constructor
     * @param _shares is a shares token address
     * @param _count is a count of shares for transfer
     * @param _recipient is a shares recipient
     */
    function Shareholder(address _shares, uint _count, address _recipient) {
        shares    = Token(_shares);
        count     = _count;
        recipient = _recipient;
    }

    /**
     * @dev Both agree shares transfer
     * @notice Call to this method you agree to get shares from my owner
     */
    function sign() {
        if (msg.sender != recipient
         || complete
         || !shares.transferFrom(owner, recipient, count)) throw;
        complete = true;
    }
}
