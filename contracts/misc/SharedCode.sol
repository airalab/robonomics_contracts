pragma solidity ^0.5.0;

// Inspired by https://github.com/GNSPS/2DProxy
library SharedCode {
    /**
     * @dev Create tiny proxy without constructor
     * @param _shared Shared code contract address
     */
    function proxy(address _shared) internal returns (address instance) {
        bytes memory code = abi.encodePacked(
            hex"603160008181600b9039f3600080808080368092803773",
            _shared, hex"5af43d828181803e808314603057f35bfd"
        );
        assembly {
            instance := create(0, add(code, 0x20), 60)
            if iszero(extcodesize(instance)) {
                revert(0, 0)
            }
        }
    }
}
