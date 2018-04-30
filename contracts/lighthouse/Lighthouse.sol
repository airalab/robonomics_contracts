pragma solidity ^0.4.18;

import './LighthouseAPI.sol';

contract Lighthouse is LighthouseAPI {
    function Lighthouse(uint256 _minimalFreeze, uint256 _timeoutBlocks) public {
        minimalFreeze = _minimalFreeze;
        timeoutBlocks = _timeoutBlocks;
        factory = msg.sender;
    }

    function() public {
        require(lib.delegatecall(msg.data));
    }

    address constant lib = 0x83cC2A3E6B76fD704d7E5bfedfA9ba8D95BE0ac4;
}
