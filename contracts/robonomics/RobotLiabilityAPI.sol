pragma solidity ^0.4.24;

import './LiabilityFactory.sol';
import './XRT.sol';

contract RobotLiabilityAPI {
    bytes   public model;
    bytes   public objective;
    bytes   public result;

    ERC20   public token;
    uint256 public cost;
    uint256 public lighthouseFee;
    uint256 public validatorFee;

    bytes32 public demandHash;
    bytes32 public offerHash;

    address public promisor;
    address public promisee;
    address public validator;

    bool    public isSuccess;
    bool    public isFinalized;

    LiabilityFactory public factory;

    event Finalized(bool indexed success, bytes result);
}
