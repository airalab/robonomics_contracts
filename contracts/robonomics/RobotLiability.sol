pragma solidity ^0.4.24;

import './RobotLiabilityAPI.sol';
import './LightContract.sol';

// Standard robot liability light contract
contract RobotLiability is RobotLiabilityAPI, LightContract {
    constructor(
        address    _lib,
        bytes      _model,
        bytes      _objective,
        ERC20      _token,
        uint256[3] _expenses,
        address[3] _parties
    )
        public
        LightContract(_lib)
    {
        factory   = LiabilityFactory(msg.sender);
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
}
