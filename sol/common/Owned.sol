import './Object.sol';

/**
 * @title Contract for object that have an owner
 */
contract Owned is Object {
    /**
     * Contract owner address
     */
    address public owner;

    /**
     * @dev Store owner on creation
     */
    function Owned() { owner = msg.sender; }

    /**
     * @dev Delegate contract to another person
     * @param _owner another person address
     */
    function delegate(address _owner) onlyOwner
    { owner = _owner; }

    /**
     * @dev Owner check modifier
     */
    modifier onlyOwner { if (msg.sender == owner) _ }
}
