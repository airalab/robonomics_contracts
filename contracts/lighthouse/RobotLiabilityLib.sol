pragma solidity ^0.4.18;

import './RobotLiabilityABI.sol';
import './RobotLiabilityAPI.sol';
import './RobotLiabilityEvents.sol';

contract RobotLiabilityLib is RobotLiabilityABI
                            , RobotLiabilityAPI
                            , RobotLiabilityEvents {
    /**
     * @dev IPFS multihash prefix.
     */
    bytes2 public constant hashPrefix = 0x1220;

    /**
     * @dev Set result of this liability
     * @param _result Result data hash
     */
    function setResult(bytes32 _result) external {
        require(msg.sender == promisor);
        require(result == 0);
        
        result = _result;

        if (validator == 0) {
            finalized = true;
            require(token.transfer(promisor, cost));
            require(xrt.transfer(lighthouse, xrt.balanceOf(this)));
        } else {
            emit ValidationReady();
        }
    }

    /**
     * @dev Set result of this liability checking by observer
     * @param _agree if true the observer confirm this execution of this liability
     */
    function setDecision(bool _agree) external {
        require(result != 0);
        require(!finalized); finalized = true;
        require(msg.sender == validator);

        if (_agree)
            require(token.transfer(promisor, cost));
        else
            require(token.transfer(promisee, cost));

        if (validatorFee > 0)
            require(xrt.transfer(validator, validatorFee));
        require(xrt.transfer(lighthouse, xrt.balanceOf(this)));
    }
}
