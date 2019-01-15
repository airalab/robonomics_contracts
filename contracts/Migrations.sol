pragma solidity ^0.5.0;

contract Migrations {
  address public owner;
  uint256 public last_completed_migration;

  constructor() public {
    owner = msg.sender;
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  function setCompleted(uint256 _completed) public restricted {
    last_completed_migration = _completed;
  }

  function upgrade(address _new_address) public restricted {
    Migrations upgraded = Migrations(_new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
