pragma solidity ^0.4.25;

/**
 * @title Robonomics lighthouse contract interface
 */
contract ILighthouse {
    /**
     * @dev Provider going online
     */
    event Online(address indexed provider);

    /**
     * @dev Provider going offline
     */
    event Offline(address indexed provider);

    /**
     * @dev Active robonomics provider
     */
    event Current(address indexed provider, uint256 indexed quota);

    /**
     * @dev Robonomics providers list
     */
    address[] public providers;

    /**
     * @dev Count of robonomics providers on this lighthouse
     */
    function providersLength() public view returns (uint256)
    { return providers.length; }

    /**
     * @dev Provider stake distribution
     */
    mapping(address => uint256) public stakes;

    /**
     * @dev Minimal stake to get one quota
     */
    uint256 public minimalStake;

    /**
     * @dev Silence timeout for provider in blocks
     */
    uint256 public timeoutInBlocks;

    /**
     * @dev Block number of last transaction from current provider
     */
    uint256 public keepAliveBlock;

    /**
     * @dev Round robin provider list marker
     */
    uint256 public marker;

    /**
     * @dev Current provider quota
     */
    uint256 public quota;

    /**
     * @dev Get quota of provider
     */
    function quotaOf(address _provider) public view returns (uint256)
    { return stakes[_provider] / minimalStake; }

    /**
     * @dev Increase stake and get more quota,
     *      one quota - one transaction in round
     * @param _value in wn
     * @notice XRT should be approved before call this 
     */
    function refill(uint256 _value) external returns (bool);

    /**
     * @dev Decrease stake and get XRT back
     * @param _value in wn
     */
    function withdraw(uint256 _value) external returns (bool);

    /**
     * @dev Create liability smart contract assigned to this lighthouse
     * @param _demand ABI-encoded demand message
     * @param _offer ABI-encoded offer message
     * @notice Only current provider can call it
     */
    function createLiability(bytes _demand, bytes _offer) external returns (bool);

    /**
     * @dev Finalize liability smart contract assigned to this lighthouse
     * @param _liability smart contract address
     * @param _result report of work
     * @param _success work success flag
     * @param _signature work signature
     */
    function finalizeLiability(address _liability, bytes _result, bool _success, bytes _signature) external returns (bool);
}
