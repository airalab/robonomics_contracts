pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/ECRecovery.sol';
import './RobotLiabilityABI.sol';
import './RobotLiabilityAPI.sol';

contract RobotLiabilityLib is RobotLiabilityABI
                            , RobotLiabilityAPI {
    using ECRecovery for bytes32;

    /**
     * @dev Finalize this liability
     * @param _result Result data hash
     * @param _agree Validation network confirmation
     * @param _signature Result sender signature
     */
    function finalize(bytes _result, bool _agree, bytes _signature) external {
        require(result.length == 0);

        address sender = keccak256(this, _result)
            .toEthSignedMessageHash()
            .recover(_signature);
        require(sender == promisor);

        if (validator == 0) {
            require(factory.isLighthouse(msg.sender));
            require(token.transfer(promisor, cost));
        } else {
            require(msg.sender == validator);

            isConfirmed = _agree;
            if (isConfirmed)
                require(token.transfer(promisor, cost));
            else
                require(token.transfer(promisee, cost));

            if (validatorFee > 0)
                require(xrt.transfer(validator, validatorFee));
        }

        require(xrt.transfer(tx.origin, xrt.balanceOf(this)));
        isFinalized = true;
        result = _result;
    }
}
