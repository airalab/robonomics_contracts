pragma solidity ^0.4.9;

import './LiabilityValidator.sol';

contract MinerLiabilityValidator is LiabilityValidator {
    function isValidator(address _sender) internal constant returns (bool)
    { return _sender == block.coinbase; }
}
