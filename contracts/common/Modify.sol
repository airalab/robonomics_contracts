pragma solidity ^0.4.4;
import './Object.sol';

/**
 * @title Owned contract modificator
 * @dev   It's abstract contract is a way to make some actions with `Owned` contract delayed.
 *        The use case typically have three steps:
 *          - create modify contract with owned target
 *          - (optional) setup `Modify` contract
 *          - delegate owned contract to `Modify` and `run()` modification
 */
contract Modify is Object {
    Owned public target;

    /**
     * @dev Contract constructor
     * @param _target is a owned target of modification
     */
    function Modify(Owned _target)
    { target = _target; }

    /**
     * @dev Modification runner
     * @notice the `target` should be delegated to this first
     */
    function run() onlyOwner {
        if (target.owner() != address(this)) throw;

        modify();
        target.setOwner(msg.sender);
    }

    function modify() internal;
}
