pragma solidity ^0.4.18;

contract RobotLiabilityABI {
    function setDecision(bool _agree) external;
    function setResult(bytes32 _result) external;
}
