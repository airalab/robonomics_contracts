pragma solidity ^0.4.18;

contract LighthouseAPI {
    address[] public members;
    mapping(address => uint256) indexOf;

    mapping(address => uint256) public balances;

    uint256 public minimalFreeze;
    uint256 public timeoutBlocks;
    address public factory;

    uint256 public keepaliveBlock = 0;
    uint256 public marker = 0;
    uint256 public quota = 0;
}
