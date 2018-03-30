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

    address constant lib = 0x8aFDFf550db9a6938C94787037BEf375e2c38c1D;
}
