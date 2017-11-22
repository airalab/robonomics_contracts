pragma solidity ^0.4.18;

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
    ) public payable {
        promisee = _promisee;
        promisor = _promisor;
        model    = _model;
    }

    /**
     * @dev Contract can receive payments.
     */
    function () public payable {}

    /**
     * @dev Set objective of this liability 
     * @param _objective Objective data hash
     */
    function setObjective(bytes _objective) public payable returns (bool success) {
        require (msg.sender == promisee);
        require (objective.length == 0);

        Objective(_objective);
        objective = _objective;

        return true;
    }

    /**
     * @dev Set result of this liability
     * @param _result Result data hash
     */
    function setResult(bytes _result) public returns (bool success) {
        require (msg.sender == promisor);
        require (objective.length > 0);
        require (result.length == 0);
        
        Result(_result);
        result = _result;

        ValidationReady();

        return true;
    }

    function confirmed() internal
    { require (promisor.send(this.balance)); }

    function rejected() internal
    { require (promisee.send(this.balance)); }

}
