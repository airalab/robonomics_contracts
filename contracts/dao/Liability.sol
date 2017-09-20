pragma solidity ^0.4.16;

import './LiabilityStandard.sol';
import 'common/Object.sol';

contract Liability is LiabilityStandard, Object {
    /**
     * @dev Liability constructor.
     * @param _promisee A person to whom a promise is made.
     * @param _promisor A person who makes a promise.
     * @param _beneficiary A person who derives advantage from promise.
     */
    function Liability(address _promisee, address _promisor, address _beneficiary) payable {
        promisee    = _promisee;
        promisor    = _promisor;
        beneficiary = _beneficiary;
    }

    /**
     * @dev I can receive payments.
     */
    function () payable {}

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
     * @param _v Signature V param.
     * @param _r Signature R param.
     * @param _s Signature S param.
     * @notice Signature is eth.sign(address, sha3(objective, cost))
     */
    function signObjective(
        bytes   _objective,
        uint256 _cost,
        uint8   _v,
        bytes32 _r,
        bytes32 _s
    )
      payable
      returns
    (
        bool success
    ) {
        // Objective notification
        Objective(_objective, _cost);

        // Signature processing
        var _hash   = sha3(_objective, _cost);
        var _sender = ecrecover(_hash, _v, _r, _s);
        hashSigned[_hash][_sender] = true;

        // Provision guard
        require(_sender != promisee || this.balance >= cost);

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
     * @param _v Signature V param.
     * @param _r Signature R param.
     * @param _s Signature S param.
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

            beneficiary.transfer(cost);
            if (this.balance > 0)
                promisee.transfer(this.balance);
        }

        return true;
    }
}
