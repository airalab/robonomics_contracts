pragma solidity ^0.4.20;

import 'token/ERC20.sol';

contract RobotLiabilityAPI {
    address public promisor;
    address public promisee;
    bytes32 public model;
    bytes32 public objective;
    ERC20   public token;
    bytes32 public result;

    bool public finalized;

    address public lighthouse;
    address public validator;
    uint256 public validatorFee;
}
