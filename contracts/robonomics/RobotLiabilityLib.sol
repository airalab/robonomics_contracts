pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/cryptography/ECDSA.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol';
import './RobotLiabilityABI.sol';
import './RobotLiabilityAPI.sol';

contract RobotLiabilityLib is RobotLiabilityABI
                            , RobotLiabilityAPI {
    using ECDSA for bytes32;
    using SafeERC20 for XRT;
    using SafeERC20 for ERC20;

    function demand(
        bytes   _model,
        bytes   _objective,

        ERC20   _token,
        uint256 _cost,

        address _lighthouse,

        address _validator,
        uint256 _validator_fee,

        uint256 _deadline,
        bytes32 _nonce,
        bytes   _signature
    )
        external
        returns (bool)
    {
        require(msg.sender == address(factory));
        require(block.number < _deadline);
        require(factory.isLighthouse(_lighthouse));

        model        = _model;
        objective    = _objective;
        token        = _token;
        cost         = _cost;
        lighthouse   = _lighthouse;
        validator    = _validator;
        validatorFee = _validator_fee;

        demandHash = keccak256(abi.encodePacked(
            _model
          , _objective
          , _token
          , _cost
          , _lighthouse
          , _validator
          , _validator_fee
          , _deadline
          , _nonce
        ));

        promisee = demandHash
            .toEthSignedMessageHash()
            .recover(_signature);
        return true;
    }

    function offer(
        bytes   _model,
        bytes   _objective,
        
        ERC20   _token,
        uint256 _cost,

        address _validator,

        address _lighthouse,
        uint256 _lighthouse_fee,

        uint256 _deadline,
        bytes32 _nonce,
        bytes   _signature
    )
        external
        returns (bool)
    {
        require(msg.sender == address(factory));
        require(block.number < _deadline);
        require(keccak256(model) == keccak256(_model));
        require(keccak256(objective) == keccak256(_objective));
        require(_token == token);
        require(_cost == cost);
        require(_lighthouse == lighthouse);
        require(_validator == validator);

        lighthouseFee = _lighthouse_fee;

        offerHash = keccak256(abi.encodePacked(
            _model
          , _objective
          , _token
          , _cost
          , _validator
          , _lighthouse
          , _lighthouse_fee
          , _deadline
          , _nonce
        ));

        promisor = offerHash
            .toEthSignedMessageHash()
            .recover(_signature);
        return true;
    }

    /**
     * @dev Finalize this liability
     * @param _result Result data hash
     * @param _success Set 'true' when liability has success result
     * @param _signature Result signature: liability address, result and success flag signed by promisor
     * @param _agree Validator decision around liability
     */
    function finalize(
        bytes _result,
        bool  _success,
        bytes _signature,
        bool  _agree
    )
        external
        returns (bool)
    {
        uint256 gasinit = gasleft();

        require(!isFinalized);

        address resultSender = keccak256(abi.encodePacked(this, _result, _success))
            .toEthSignedMessageHash()
            .recover(_signature);
        require(resultSender == promisor);

        result      = _result;
        isSuccess   = validator == 0 ? _success : _success && _agree;

        isFinalized = true;
        emit Finalized(isSuccess, result);

        if (validator == 0) {
            require(msg.sender == lighthouse);
        } else {
            require(msg.sender == validator);
            if (validatorFee > 0)
                factory.xrt().safeTransfer(validator, validatorFee);
        }

        if (cost > 0)
            token.safeTransfer(_success ? promisor : promisee, cost);

        require(factory.liabilityFinalized(gasinit));
        return true;
    }
}
