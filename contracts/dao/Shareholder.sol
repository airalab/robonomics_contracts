pragma solidity ^0.4.4;
import './Offer.sol';

contract Shareholder is Offer {
    /**
     * @dev Shareholder contract constructor
     * @param _description is a short description
     * @param _token is a shares token
     * @param _value is a count of shares for transfer
     * @param _beneficiary is a shares recipient
     */
    function Shareholder(string _description,
                         address _token, uint _value,
                         address _beneficiary) Offer(_description,
                                                     _token, _value,
                                                     _beneficiary, 0) {}

    /**
     * @dev Both agree shares transfer
     * @notice Call to this method you agree to get shares from my owner
     */
    function accept() {
        if (msg.sender != beneficiary
         || closed > 0
         || !token.transferFrom(owner, beneficiary, value)) throw;
        closed = now;
    }
}
