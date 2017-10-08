pragma solidity ^0.4.9;

import './LiabilityStandard.sol';

contract LiabilityValidator is LiabilityStandard {
    bytes   public validationModel;
    uint256 public confirmationCount;

    bool public isValidationReady = false;
    event ValidationReady();

    event Confirmed();
    event Rejected();

    /**
     * @dev Set liability to validation ready
     */
    function validationReady() internal {
        isValidationReady = true;
        ValidationReady();
    }

    /**
     * @dev Check validation rights of given address
     * @param _sender Address to check
     * @return Sender has validation right
     */
    function isValidator(address _sender) internal constant returns (bool);

    /**
     * @dev Support for multiple validators
     */
    modifier multiValidator {
        if (!isValidationReady) throw;
        if (!isValidator(msg.sender)) throw;

        if (participant[msg.sender]) throw;
        participant[msg.sender] = true;
 
        _;
    }

    /**
     * @dev Validator participation value
     */
    mapping(address => bool) public participant;

    /**
     * @dev Validator in support position
     */
    address[] public support;

    /**
     * @dev Validator in resistance position
     */
    address[] public resistance;

    /**
     * @dev Confirm liability execution
     */
    function confirm() multiValidator {
        support.push(msg.sender);

        if (support.length >= confirmationCount) {
            isValidationReady = false;
            confirmed();
            Confirmed();
        }
    }

    /**
     * @dev Confirmation callback
     */
    function confirmed() internal {}

    /**
     * @dev Reject liability execution
     */
    function reject() multiValidator {
        resistance.push(msg.sender);

        if (resistance.length >= confirmationCount) {
            isValidationReady = false;
            rejected();
            Rejected();
        }
    }

    /**
     * @dev Rejection callback
     */
    function rejected() internal {}
}
