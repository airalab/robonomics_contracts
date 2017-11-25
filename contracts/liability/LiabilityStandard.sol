pragma solidity ^0.4.18;

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
    event Objective(bytes objective);

    /**
     * @dev Broadcast new production multihash of liability.
     */
    event Result(bytes result); 
}
