pragma solidity ^0.4.18;

import 'liability/LiabilityValidator.sol';

contract MinerLiabilityValidator is LiabilityValidator {
    function isValidator(address _sender) internal view returns (bool)
    { return _sender == block.coinbase; }
}
