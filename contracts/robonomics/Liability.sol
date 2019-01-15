pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/cryptography/ECDSA.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol';

import './interface/ILiability.sol';
import './interface/IValidator.sol';
import './XRT.sol';

contract Liability is ILiability {
    using ECDSA for bytes32;
    using SafeERC20 for XRT;
    using SafeERC20 for ERC20;

    address public factory;
    XRT     public xrt;

    function setup(XRT _xrt) external returns (bool) {
        require(factory == address(0));

        factory = msg.sender;
        xrt     = _xrt;

        return true;
    }

    function demand(
        bytes   calldata _model,
        bytes   calldata _objective,

        address _token,
        uint256 _cost,

        address _lighthouse,

        address _validator,
        uint256 _validator_fee,

        uint256 _deadline,
        bytes32 _nonce,
        bytes   calldata _signature
    )
        external
        returns (bool)
    {
        require(msg.sender == factory);
        require(block.number < _deadline);

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
        bytes   calldata _model,
        bytes   calldata _objective,
        
        address _token,
        uint256 _cost,

        address _validator,

        address _lighthouse,
        uint256 _lighthouse_fee,

        uint256 _deadline,
        bytes32 _nonce,
        bytes   calldata _signature
    )
        external
        returns (bool)
    {
        require(msg.sender == factory);
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

    function finalize(
        bytes calldata _result,
        bool  _success,
        bytes calldata _signature
    )
        external
        returns (bool)
    {
        require(msg.sender == lighthouse);
        require(!isFinalized);

        address resultSender = keccak256(abi.encodePacked(this, _result, _success))
            .toEthSignedMessageHash()
            .recover(_signature);
        require(resultSender == promisor);

        isFinalized = true;
        result      = _result;

        if (validator == address(0)) {
            // Set state of liability according promisor report only
            isSuccess = _success;
        } else {
            // Validator can take a fee for decision
            xrt.safeApprove(validator, validatorFee);
            // Set state of liability considering validator decision
            isSuccess = _success && IValidator(validator).decision();
        }

        if (cost > 0)
            ERC20(token).safeTransfer(isSuccess ? promisor : promisee, cost);

        emit Finalized(isSuccess, result);
        return true;
    }
}
