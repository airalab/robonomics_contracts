pragma solidity ^0.4.24;

import './LighthouseAPI.sol';
import './LightContract.sol';

contract Lighthouse is LighthouseAPI, LightContract {
    constructor(
        address _lib,
        uint256 _minimalFreeze,
        uint256 _timeoutBlocks
    ) 
        public
        LightContract(_lib)
    {
        require(_minimalFreeze > 0 && _timeoutBlocks > 0);

        minimalFreeze = _minimalFreeze;
        timeoutBlocks = _timeoutBlocks;
        factory = LiabilityFactory(msg.sender);
        xrt = factory.xrt();
    }
}
