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
        bytes   _validation_model,
        uint256 _confirmation_count,
        address _promisee,
        address _promisor
    ) payable {
        promisee = _promisee;
        promisor = _promisor;
        validationModel   = _validation_model;
        confirmationCount = _confirmation_count;
    }

    /**
     * @dev Contract can receive payments.
     */
    function () payable {}

    modifier onlyPromisee { if (msg.sender != promisee) throw; _; }
    modifier onlyPromisor { if (msg.sender != promisor) throw; _; }

    /**
     * @dev Set objective of this liability 
     * @param _objective Objective data hash
     */
    function setObjective(bytes _objective) payable onlyPromisee returns (bool success) {
        if (objective.length > 0) throw;

        Objective(_objective);
        objective = _objective;

        return true;
    }

    /**
     * @dev Set result of this liability
     * @param _result Result data hash
     */
    function setResult(bytes _result) onlyPromisor returns (bool success) {
        if (result.length > 0) throw;
        
        Result(_result);
        result = _result;

        validationReady();

        return true;
    }

    function confirmed() internal
    { if (!promisor.send(this.balance)) throw; }

    function rejected() internal
    { if (!promisee.send(this.balance)) throw; }

}
