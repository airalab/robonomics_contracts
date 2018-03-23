pragma solidity ^0.4.20;

contract RobotLiabilityABI {
    function setDecision(bool _agree) external;
    function setResult(bytes32 _result) external;
}
