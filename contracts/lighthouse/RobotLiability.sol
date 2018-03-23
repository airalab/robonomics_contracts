pragma solidity ^0.4.20;

import './RobotLiabilityAPI.sol';

// Standard robot liability light contract
contract RobotLiability is RobotLiabilityAPI {
    function RobotLiability(
        bytes32 _model,
        bytes32 _objective,
        ERC20   _token,
        address _promisee,
        address _promisor,
        address _validator,
        uint256 _validatorFee
    ) public {
        model     = _model;
        objective = _objective;
        token     = _token;
        promisee  = _promisee;
        promisor  = _promisor;
        validator = _validator;
        validatorFee = _validatorFee;
    }

    function() public {
        require(lib.delegatecall(msg.data));
    }

    address constant lib = 0;
}
