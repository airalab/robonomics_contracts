pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/drafts/SignatureBouncer.sol';

import './AbstractAmbix.sol';

contract KycAmbix is AbstractAmbix, SignatureBouncer {
    /**
     * @dev Run distillation process
     * @param _ix Source alternative index
     * @param _signature KYC indulgence (KYC signature of concatenated sender and contract address)
     */
    function run(uint256 _ix, bytes calldata _signature) external onlyValidSignature(_signature)
    { _run(_ix); }
}
