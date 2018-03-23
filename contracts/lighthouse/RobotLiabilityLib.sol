pragma solidity ^0.4.20;

import './ERC20.sol';
import './RobotLiabilityABI.sol';
import './RobotLiabilityAPI.sol';
import './RobotLiabilityEvents.sol';

contract RobotLiabilityLib is RobotLiabilityABI
                            , RobotLiabilityAPI
                            , RobotLiabilityEvents {
    /**
     * @dev Processing token.
     */
    ERC20 public constant token = ERC20(0xC00Fd9820Cd2898cC4C054B7bF142De637ad129A); 

    /**
     * @dev Robonomics token.
     */
    ERC20 public constant xrt = ERC20(0x5DF531240f97049ee8d28A8E51030A3b5a8e8CE4);

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
            require(xrt.transfer(lighthouse, xrt.balanceOf(this)));
            require(token.transfer(promisor, token.balanceOf(this)));
            finalized = true;
        } else {
            ValidationReady();
        }
    }

    /**
     * @dev Set result of this liability checking by observer
     * @param _agree if true the observer confirm this execution of this liability
     */
    function setDecision(bool _agree) external {
        require(!finalized);
        require(msg.sender == validator);

        if (validatorFee > 0)
            require(xrt.transfer(validator, validatorFee));
        require(xrt.transfer(lighthouse, xrt.balanceOf(this)));

        if (_agree)
            require(token.transfer(promisor, token.balanceOf(this)));
        else
            require(token.transfer(promisee, token.balanceOf(this)));

        finalized = true;
    }
}
