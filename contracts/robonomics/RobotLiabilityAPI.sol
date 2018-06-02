pragma solidity ^0.4.24;

import './LiabilityFactory.sol';
import './XRT.sol';

contract RobotLiabilityAPI {
    LiabilityFactory public factory;

    address public promisor;
    address public promisee;

    XRT     public xrt;
    ERC20   public token;
    uint256 public cost;

    bytes   public model;
    bytes   public objective;
    bytes   public result;

    bool    public isConfirmed;
    bool    public isFinalized;

    address public validator;
    uint256 public validatorFee;
}
