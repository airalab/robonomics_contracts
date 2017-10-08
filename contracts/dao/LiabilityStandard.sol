pragma solidity ^0.4.9;

/**
 * @title The liability standard contract.
 */
contract LiabilityStandard {
    /**
     * @dev A person who makes a promise.
     */
    address public promisor;

    /**
     * @dev A person to whom a promise is made.
     */
    address public promisee;

    /**
     * @dev Contract execution cost.
     */
    uint256 public cost;

    /**
     * @dev Current objective multihash of promise.
     */
    bytes public objective;

    /**
     * @dev Current results multihash of promise.
     */
    bytes public result;
    
    /**
     * @dev Broadcast new objective multihash of liability.
     */
    event Objective(bytes objective, uint256 indexed cost);

    /**
     * @dev Broadcast new production multihash of liability.
     */
    event Result(bytes result); 
}
