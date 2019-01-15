pragma solidity ^0.5.0;

import './AbstractAmbix.sol';

contract PublicAmbix is AbstractAmbix {
    /**
     * @dev Run distillation process
     * @param _ix Source alternative index
     */
    function run(uint256 _ix) external {
        _run(_ix);
    }
}
