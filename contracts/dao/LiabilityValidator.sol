pragma solidity 0.4.18;

import './LiabilityStandard.sol';

contract LiabilityValidator is LiabilityStandard {
    bytes public model;

    event ValidationReady();
    event Confirmed();
    event Rejected();

    /**
     * @dev Check validation rights of given address
     * @param _sender Address to check
     * @return Sender has validation right
     */
    function isValidator(address _sender) internal constant returns (bool);

    /**
     * @dev Confirm liability execution
     */
    function confirm() {
        if (!isValidator(msg.sender)) throw;
        confirmed();
        Confirmed();
    }

    /**
     * @dev Confirmation callback
     */
    function confirmed() internal {}

    /**
     * @dev Reject liability execution
     */
    function reject() {
        if (!isValidator(msg.sender)) throw;
        rejected();
        Rejected();
    }

    /**
     * @dev Rejection callback
     */
    function rejected() internal {}
}
