pragma solidity ^0.4.18;

/**
 * @title Contract for object that have an owner
 */
contract Owned {
    /**
     * Contract owner address
     */
    address public owner;

    /**
     * @dev Delegate contract to another person
     * @param _owner New owner address 
     */
    function setOwner(address _owner) public onlyOwner
    { owner = _owner; }

    /**
     * @dev Owner check modifier
     */
    modifier onlyOwner { require(msg.sender == owner); _; }
}
