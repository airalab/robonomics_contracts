pragma solidity ^0.5.0;

/**
 * @dev Observing network contract interface
 */
contract IValidator {
    /**
     * @dev Be sure than address is really validator
     * @return true when validator address in argument
     */
    function isValidator(address _validator) external returns (bool);
}
