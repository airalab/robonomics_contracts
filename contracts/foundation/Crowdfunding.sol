pragma solidity ^0.4.4;
import 'token/TokenEmission.sol';
import 'token/Recipient.sol';

/**
 * @title Crowdfunding contract
 */
contract Crowdfunding is Object, Recipient {
    /**
     * @dev Target fund account address
     */
    address public fund;

    /**
     * @dev Bounty token address
     */
    TokenEmission public bounty;
    
    /**
     * @dev Distribution of donations
     */
    mapping(address => uint256) public donations;

    /**
     * @dev Total funded value
     */
    uint256 public totalFunded;

    /**
     * @dev Documentation reference
     */
    string public reference;

    /**
     * @dev Crowdfunding configuration
     */
    Params public config;

    struct Params {
        /* start/stop block stamps */
        uint256 startBlock;
        uint256 stopBlock;

        /* Minimal/maximal funded value */
        uint256 minValue;
        uint256 maxValue;
        
        /**
         * Bounty ratio equation:
         *   bountyValue = value * ratio / scale
         * where
         *   ratio = R - (block - B) / S * V
         *  R - start bounty ratio
         *  B - start block number
         *  S - bounty reduction step in blocks 
         *  V - bounty reduction value
         */
        uint256 bountyScale;
        uint256 startRatio;
        uint256 reductionStep;
        uint256 reductionValue;
    }

    /**
     * @dev Calculate bounty value by reduction equation
     * @param _value Input donation value
     * @param _block Input block number
     * @return Bounty value
     */
    function bountyValue(uint256 _value, uint256 _block) constant returns (uint256) {
        if (_block < config.startBlock || _block > config.stopBlock)
            return 0;

        var R = config.startRatio;
        var B = config.startBlock;
        var S = config.reductionStep;
        var V = config.reductionValue;
        uint256 ratio = R - (_block - B) / S * V; 
        return _value * ratio / config.bountyScale; 
    }

    /**
     * @dev Crowdfunding running checks
     */
    modifier onlyRunning {
        bool isRunning = totalFunded + msg.value <= config.maxValue
                      && block.number >= config.startBlock
                      && block.number <= config.stopBlock;
        if (!isRunning) throw;
        _;
    }

    /**
     * @dev Crowdfundung failure checks
     */
    modifier onlyFailure {
        bool isFailure = totalFunded  < config.minValue
                      && block.number > config.stopBlock;
        if (!isFailure) throw;
        _;
    }

    /**
     * @dev Crowdfunding success checks
     */
    modifier onlySuccess {
        bool isSuccess = totalFunded >= config.minValue
                      && block.number > config.stopBlock;
        if (!isSuccess) throw;
        _;
    }

    /**
     * @dev Crowdfunding contract initial 
     * @param _fund Destination account address
     * @param _bounty Bounty token address
     * @param _reference Reference documentation link
     * @param _startBlock Funding start block number
     * @param _stopBlock Funding stop block nubmer
     * @param _minValue Minimal funded value in wei 
     * @param _maxValue Maximal funded value in wei
     * @param _scale Bounty scaling factor by funded value
     * @param _startRatio Initial bounty ratio
     * @param _reductionStep Bounty reduction step in blocks 
     * @param _reductionValue Bounty reduction value
     * @notice this contract should be owner of bounty token
     */
    function Crowdfunding(
        address _fund,
        address _bounty,
        string  _reference,
        uint256 _startBlock,
        uint256 _stopBlock,
        uint256 _minValue,
        uint256 _maxValue,
        uint256 _scale,
        uint256 _startRatio,
        uint256 _reductionStep,
        uint256 _reductionValue
    ) {
        fund      = _fund;
        bounty    = TokenEmission(_bounty);
        reference = _reference;

        config.startBlock     = _startBlock;
        config.stopBlock      = _stopBlock;
        config.minValue       = _minValue;
        config.maxValue       = _maxValue;
        config.bountyScale    = _scale;
        config.startRatio     = _startRatio;
        config.reductionStep  = _reductionStep;
        config.reductionValue = _reductionValue;
    }

    /**
     * @dev Receive Ether token and send bounty
     */
    function () payable onlyRunning {
        ReceivedEther(msg.sender, msg.value);

        totalFunded           += msg.value;
        donations[msg.sender] += msg.value;

        var bountyVal = bountyValue(msg.value, block.number);
        if (bountyVal == 0) throw;

        bounty.emission(bountyVal);
        bounty.transfer(msg.sender, bountyVal);
    }

    /**
     * @dev Withdrawal balance on successfull finish
     */
    function withdraw() onlySuccess
    { if (!fund.send(this.balance)) throw; }

    /**
     * @dev Refund donations when no minimal value achieved
     */
    function refund() onlyFailure {
        var donation = donations[msg.sender];
        donations[msg.sender] = 0;
        if (!msg.sender.send(donation)) throw;
    }

    /**
     * @dev Disable receive another tokens
     */
    function receiveApproval(address _from, uint256 _value,
                             ERC20 _token, bytes _extraData)
    { throw; }
}
