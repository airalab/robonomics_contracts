pragma solidity ^0.4.18;

import './LighthouseAPI.sol';

contract Lighthouse is LighthouseAPI {
    function Lighthouse(uint256 _minimalFreeze) public {
        minimalFreeze = _minimalFreeze;
        factory = msg.sender;
    }

    function() public {
        require(lib.delegatecall(msg.data));
    }

    address constant lib = 0x06C0AC0fB1EC037F98F94287c40EdBD05c1583E9;
}
