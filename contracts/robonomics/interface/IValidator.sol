pragma solidity ^0.5.0;

/**
 * @dev Observing network contract interface
 */
contract IValidator {
    /**
     * @dev Final liability decision
     */
    event Decision(address indexed liability, bool indexed success);

    /**
     * @dev Decision availability marker 
     */
    mapping(address => bool) public hasDecision;

    /**
     * @dev Get decision of liability, is used by liability contract only
     * @notice Transaction will fail when have no decision
     */
    function decision() external returns (bool);
}
