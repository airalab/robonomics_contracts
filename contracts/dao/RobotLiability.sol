pragma solidity ^0.4.9;

import './MinerLiabilityValidator.sol';
import 'common/Object.sol';

contract RobotLiability is MinerLiabilityValidator, Object {
    /**
     * @dev Liability constructor.
     * @param _promisee A person to whom a promise is made.
     * @param _promisor A person who makes a promise.
     */
    function RobotLiability(
        bytes   _model,
        address _promisee,
        address _promisor
    ) payable {
        promisee = _promisee;
        promisor = _promisor;
        model    = _model;
    }

    /**
     * @dev Contract can receive payments.
     */
    function () payable {}

    /**
     * @dev Set objective of this liability 
     * @param _objective Objective data hash
     */
    function setObjective(bytes _objective) payable returns (bool success) {
        if (msg.sender != promisee) throw;
        if (objective.length > 0) throw;

        Objective(_objective);
        objective = _objective;

        return true;
    }

    /**
     * @dev Set result of this liability
     * @param _result Result data hash
     */
    function setResult(bytes _result) returns (bool success) {
        if (msg.sender != promisor) throw;
        if (objective.length == 0) throw;
        if (result.length > 0) throw;
        
        Result(_result);
        result = _result;

        ValidationReady();

        return true;
    }

    function confirmed() internal
    { if (!promisor.send(this.balance)) throw; }

    function rejected() internal
    { if (!promisee.send(this.balance)) throw; }

}
