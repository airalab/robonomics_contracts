/**
 * @title The root contract
 * @dev This contract is used as base of all contracts,
 *      e.g. it change default behaviour of fallback function 
 */
contract Object {
    /**
     * @dev Default fallback behaviour will throw sended ethers
     */
    function() { throw; }
}
