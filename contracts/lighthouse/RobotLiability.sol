pragma solidity ^0.4.18;

import './RobotLiabilityAPI.sol';
import './Factory.sol';

// Standard robot liability light contract
contract RobotLiability is RobotLiabilityAPI {
    function RobotLiability(
        bytes32 _model,
        bytes32 _objective,
        ERC20   _token,
        uint256[3] _expenses,
        address[4] _parties
    ) public {
        model     = _model;
        objective = _objective;
        token     = _token;
        cost      = _expenses[0];
        xrt       = Factory(msg.sender).xrt(); 
        promisee   = _parties[0];
        promisor   = _parties[1];
        lighthouse = _parties[2];
        validator  = _parties[3];
        validatorFee = _expenses[2];
    }

    function() public {
        require(lib.delegatecall(msg.data));
    }

    address constant lib = 0xC6B8e21FB240741475ce3602B9a8E17d88bAA768;
}
