pragma solidity ^0.4.9;

import 'token/ERC20.sol';

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
     * @dev A person who derives advantage from promise.
     */
    address public beneficiary;

    /**
     * @dev Protocol token address. 
     */
    ERC20   public token;

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

    /**
     * @dev Sign objective multihash with execution cost.
     * @param objective Production objective multihash.
     * @param cost Promise execution cost in protocol token.
     * @param v Signature V param
     * @param r Signature R param
     * @param s Signature S param
     * @notice Signature is eth.sign(address, sha3(objective, cost))
     */
    function signObjective(bytes objective, uint256 cost, uint8 v, bytes32 r, bytes32 s) returns (bool success);

    /**
     * @dev Sign result multihash.
     * @param result Production result multihash.
     * @param v Signature V param
     * @param r Signature R param
     * @param s Signature S param
     * @notice Signature is eth.sign(address, sha3(sha3(objective, cost), result))
     */
    function signResult(bytes result, uint8 v, bytes32 r, bytes32 s) returns (bool success);
}
