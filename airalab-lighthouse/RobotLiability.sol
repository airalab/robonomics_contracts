pragma solidity ^0.4.18;

import './RobotLiabilityAPI.sol';

// Standard robot liability light contract
contract RobotLiability is RobotLiabilityAPI {
    function RobotLiability(
        bytes32 _model,
        bytes32 _objective,
        ERC20   _token,
        uint256[3] _expenses,
        address[3] _parties
    ) public {
        factory   = Factory(msg.sender);
        model     = _model;
        objective = _objective;
        token     = _token;
        cost      = _expenses[0];
        xrt       = factory.xrt(); 
        promisee   = _parties[0];
        promisor   = _parties[1];
        validator  = _parties[2];
        validatorFee = _expenses[2];
    }

    function() public {
        require(lib.delegatecall(msg.data));
    }

    address constant lib = 0xa0B2Eb4fBdD4fF8c8eaf1B3060F04d79488b0156;
}
