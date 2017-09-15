pragma solidity ^0.4.9;

import './LiabilityStandard.sol';
import 'token/Recipient.sol';
import 'common/Object.sol';

contract Liability is LiabilityStandard, Recipient, Object {
    /**
     * @dev Liability constructor
     */
    function Liability(address _promisee, address _promisor, address _beneficiary) {
        promisee    = _promisee;
        promisor    = _promisor;
        beneficiary = _beneficiary;
    }

    /**
     * @dev Turn off fallback
     */
    function () payable { throw; }

    /**
     * @dev Receive approved ERC20 tokens
     * @param _from Spender address
     * @param _value Transaction value
     * @param _token ERC20 token contract address
     * @param _extraData Custom additional data
     */
    function receiveApproval(address _from, uint256 _value,
                             ERC20 _token, bytes _extraData) {
        if (_token != token) throw;
        super.receiveApproval(_from, _value, _token, _extraData);
    }

    /**
     * @dev Signature storage.
     *      It is boolean flag mapping from signed hash and signer address.
     */
    mapping(bytes32 => mapping(address => bool)) public hashSigned;

    /**
     * @dev Simple hash signatures checker.
     * @param _hash Signed hash.
     * @return Verification status.
     */
    function isSigned(bytes32 _hash) constant returns (bool)
    { return hashSigned[_hash][promisee] && hashSigned[_hash][promisor]; }

    /**
     * @dev Sign objective multihash with execution cost. 
     * @param _objective Production objective multihash.
     * @param _cost Promise execution cost in protocol token.
     * @param _v Signature V param
     * @param _r Signature R param
     * @param _s Signature S param
     * @notice Signature is eth.sign(address, sha3(objective, cost))
     */
    function signObjective(
        bytes   _objective,
        uint256 _cost,
        uint8   _v,
        bytes32 _r,
        bytes32 _s
    ) returns (
        bool success
    ) {
        // Objective notification
        Objective(_objective, _cost);

        // Signature processing
        var _hash   = sha3(_objective, _cost);
        var _sender = ecrecover(_hash, _v, _r, _s);
        hashSigned[_hash][_sender] = true;

        // Provision guard
        if (_sender == promisee && token.balanceOf(this) < cost)
            throw;

        // Objectivisation of proposals
        if (isSigned(_hash)) {
            objective = _objective;
            cost      = _cost;
        }

        return true;
    }

    /**
     * @dev Sign result multihash.
     * @param _result Production result multihash.
     * @param _v Signature V param
     * @param _r Signature R param
     * @param _s Signature S param
     * @notice Signature is eth.sign(address, sha3(sha3(objective, cost), result))
     */
    function signResult(
        bytes   _result,
        uint8   _v,
        bytes32 _r,
        bytes32 _s
    ) returns (
        bool success
    ) {
        // Result notification
        Result(_result);

        // Signature processing
        var _hash   = sha3(sha3(objective, cost), _result);
        var _sender = ecrecover(_hash, _v, _r, _s);
        hashSigned[_hash][_sender] = true;

        // Result handling
        if (isSigned(_hash)) {
            result = _result;

            if (!token.transfer(beneficiary, cost)) throw;

            var refund = token.balanceOf(this) - cost;
            if (!token.transfer(promisee, refund)) throw;
        }

        return true;
    }
}
