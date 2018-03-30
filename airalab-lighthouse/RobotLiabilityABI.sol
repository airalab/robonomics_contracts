pragma solidity ^0.4.18;

contract RobotLiabilityABI {
    function setDecision(bool _agree, uint8 _v, bytes32 _r, bytes32 _s) external;
    function setResult(bytes32 _result, uint8 _v, bytes32 _r, bytes32 _s) external;
}
