pragma solidity ^0.4.25;

import './ILiability.sol';
import './ILighthouse.sol';

/**
 * @title Robonomics liability factory interface
 */
contract IFactory {
    /**
     * @dev New liability created 
     */
    event NewLiability(address indexed liability);

    /**
     * @dev New lighthouse created
     */
    event NewLighthouse(address indexed lighthouse, string name);

    /**
     * @dev Lighthouse address mapping
     */
    mapping(address => bool) public isLighthouse;

    /**
     * @dev Total GAS utilized by Robonomics network
     */
    uint256 public totalGasConsumed = 0;

    /**
     * @dev GAS utilized by liability contracts
     */
    mapping(address => uint256) public gasConsumedOf;

    /**
     * @dev The count of consumed gas for switch to next epoch 
     */
    uint256 public constant gasEpoch = 347 * 10**10;

    /**
     * @dev Current gas price in wei
     */
    uint256 public gasPrice = 10 * 10**9;

    /**
     * @dev XRT emission value for consumed gas
     * @param _gas Gas consumed by robonomics program
     */
    function wnFromGas(uint256 _gas) public view returns (uint256);

    /**
     * @dev Create lighthouse smart contract
     * @param _minimalStake Minimal stake value of XRT token (one quota price)
     * @param _timeoutInBlocks Max time of lighthouse silence in blocks
     * @param _name Lighthouse name,
     *              example: 'my-name' will create 'my-name.lighthouse.4.robonomics.eth' domain
     */
    function createLighthouse(uint256 _minimalStake, uint256 _timeoutInBlocks, string _name) external returns (ILighthouse);

    /**
     * @dev Create robot liability smart contract
     * @param _demand ABI-encoded demand message
     * @param _offer ABI-encoded offer message
     * @notice This method is for lighthouse contract use only
     */
    function createLiability(bytes _demand, bytes _offer) external returns (ILiability);

    /**
     * @dev Is called after liability creation
     * @param _liability Liability contract address
     * @param _start_gas Transaction start gas level
     * @notice This method is for lighthouse contract use only
     */
    function liabilityCreated(ILiability _liability, uint256 _start_gas) external returns (bool);

    /**
     * @dev Is called after liability finalization
     * @param _liability Liability contract address
     * @param _start_gas Transaction start gas level
     * @notice This method is for lighthouse contract use only
     */
    function liabilityFinalized(ILiability _liability, uint256 _start_gas) external returns (bool);
}
