pragma solidity ^0.4.18;

import 'token/ERC20.sol';

contract RobotLiabilityAPI {
    address public promisor;
    address public promisee;

    ERC20   public xrt;
    ERC20   public token;
    uint256 public cost;

    bytes32 public model;
    bytes32 public objective;
    bytes32 public result;

    bool    public finalized;

    address public lighthouse;
    address public validator;
    uint256 public validatorFee;
}
