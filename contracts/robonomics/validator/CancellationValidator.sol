pragma solidity ^0.5.0;

import '../interface/IValidator.sol';
import '../interface/ILiability.sol';

/**
 * @dev Autonomous validator that helps cancel liabilities when promisor was gone.
 */
contract CancellationValidator is IValidator {
    event CancellationRequest(address indexed liability);

    mapping(address => uint256) public cancellationRequest;
    uint256 public waitingPeriod;

    /**
     * @param _waitingPeriod Waiting period in blocks
     */
    constructor(uint256 _waitingPeriod) public {
        waitingPeriod = _waitingPeriod;
    }

    /**
     * @dev Request to cancel liability
     * @param _liability Contract address
     * @notice For promisee only
     */
    function cancel(address _liability) external {
        require(ILiability(_liability).promisee() == msg.sender);
        cancellationRequest[_liability] = block.number;
        emit CancellationRequest(_liability);
    }

    function isValidator(address _validator) external returns (bool) {
        uint256 requestStartBlock = cancellationRequest[msg.sender];
        bool waitingDone = requestStartBlock > 0
                        && block.number - requestStartBlock > waitingPeriod;

        ILiability liability = ILiability(msg.sender);
        if (_validator == liability.promisee() && waitingDone) {
            return true;
        } else {
            return false;
        }
    }
}
