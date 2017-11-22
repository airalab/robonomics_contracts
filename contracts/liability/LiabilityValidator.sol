pragma solidity ^0.4.18;

import 'liability/LiabilityStandard.sol';
import 'token/ERC20.sol';

contract LiabilityValidator is LiabilityStandard {
    /**
     * @dev Utility token.
     */
    ERC20 public constant utility = ERC20(0);

    /**
     * @dev Validator fee in utility token.
     */
    uint256 public fee;

    /**
     * @dev Behaviour model for validation.
     */
    bytes public model;

    /**
     * @dev Liability ready to validation.
     */
    event ValidationReady();

    /**
     * @dev Liability execution confirmed.
     */
    event Confirmed();

    /**
     * @dev Liability execution rejected.
     */
    event Rejected();

    /**
     * @dev Check validation rights of given address
     * @param _sender Address to check
     * @return Sender has validation right
     */
    function isValidator(address _sender) internal view returns (bool);

    /**
     * @dev Confirm liability execution
     */
    function confirm() public {
        require(isValidator(msg.sender));
        require(utility.transfer(msg.sender, fee));

        confirmed();
        Confirmed();
    }

    /**
     * @dev Confirmation callback
     */
    function confirmed() internal;

    /**
     * @dev Reject liability execution
     */
    function reject() public {
        require(isValidator(msg.sender));
        require(utility.transfer(msg.sender, fee));

        rejected();
        Rejected();
    }

    /**
     * @dev Rejection callback
     */
    function rejected() internal;
}
