pragma solidity ^0.5.0;

/**
 * @title Standard liability smart contract interface
 */
contract ILiability {
    /**
     * @dev Liability termination signal
     */
    event Finalized(bool indexed success, bytes result);

    /**
     * @dev Behaviour model multihash
     */
    bytes public model;

    /**
     * @dev Objective ROSBAG multihash
     * @notice ROSBAGv2 is used: http://wiki.ros.org/Bags/Format/2.0 
     */
    bytes public objective;

    /**
     * @dev Report ROSBAG multihash 
     * @notice ROSBAGv2 is used: http://wiki.ros.org/Bags/Format/2.0 
     */
    bytes public result;

    /**
     * @dev Payment token address
     */
    address public token;

    /**
     * @dev Liability cost
     */
    uint256 public cost;

    /**
     * @dev Lighthouse fee in wn
     */
    uint256 public lighthouseFee;

    /**
     * @dev Validator fee in wn
     */
    uint256 public validatorFee;

    /**
     * @dev Robonomics demand message hash
     */
    bytes32 public demandHash;

    /**
     * @dev Robonomics offer message hash
     */
    bytes32 public offerHash;

    /**
     * @dev Liability promisor address
     */
    address public promisor;

    /**
     * @dev Liability promisee address
     */
    address public promisee;

    /**
     * @dev Lighthouse assigned to this liability
     */
    address public lighthouse;

    /**
     * @dev Liability validator address
     */
    address public validator;

    /**
     * @dev Liability success flag
     */
    bool public isSuccess;

    /**
     * @dev Liability finalization status flag
     */
    bool public isFinalized;

    /**
     * @dev Deserialize robonomics demand message
     * @notice It can be called by factory only
     */
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
    ) external returns (bool);

    /**
     * @dev Deserialize robonomics offer message
     * @notice It can be called by factory only
     */
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
    ) external returns (bool);

    /**
     * @dev Finalize liability contract
     * @param _result Result data hash
     * @param _success Set 'true' when liability has success result
     * @param _signature Result signature: liability address, result and success flag signed by promisor
     * @notice It can be called by assigned lighthouse only
     */
    function finalize(
        bytes calldata _result,
        bool  _success,
        bytes calldata _signature
    ) external returns (bool);
}
