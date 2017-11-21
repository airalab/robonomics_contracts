pragma solidity 0.4.18;

/**
 * @title Common pattern for destroyable contracts 
 */
contract Destroyable {
    address public hammer;

    /**
     * @dev Hammer setter
     * @param _hammer New hammer address
     */
    function setHammer(address _hammer) onlyHammer
    { hammer = _hammer; }

    /**
     * @dev Destroy contract and scrub a data
     * @notice Only hammer can call it 
     */
    function destroy() onlyHammer
    { selfdestroy(msg.sender); }

    /**
     * @dev Hammer check modifier
     */
    modifier onlyHammer { require(msg.sender == hammer); _; }
}
