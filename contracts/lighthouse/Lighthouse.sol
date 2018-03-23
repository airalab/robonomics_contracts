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

    address constant lib = 0;
}
