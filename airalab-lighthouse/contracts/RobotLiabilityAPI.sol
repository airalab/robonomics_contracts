pragma solidity ^0.4.18;

import {ERC20} from 'airalab-token/contracts/ERC20.sol';
import './Factory.sol';

contract RobotLiabilityAPI {
    /* Constants */
    bytes constant MSGPREFIX = "\x19Ethereum Signed Message:\n32";

    /* State variables */
    Factory public factory;

    address public promisor;
    address public promisee;

    ERC20   public xrt;
    ERC20   public token;
    uint256 public cost;

    bytes32 public model;
    bytes32 public objective;
    bytes32 public result;

    bool    public finalized;

    address public validator;
    uint256 public validatorFee;
}
