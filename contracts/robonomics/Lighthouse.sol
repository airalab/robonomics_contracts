pragma solidity ^0.4.25;

import 'openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol';

import './interface/ILighthouse.sol';
import './interface/IFactory.sol';
import './XRT.sol';

contract Lighthouse is ILighthouse {
    constructor(XRT _xrt, uint256 _minimalStake, uint256 _timeoutInBlocks) public {
        require(_minimalStake > 0 && _timeoutInBlocks > 0);

        minimalStake    = _minimalStake;
        timeoutInBlocks = _timeoutInBlocks;
        xrt             = _xrt;
        factory         = IFactory(msg.sender);
    }

    using SafeERC20 for XRT;

    XRT      public xrt;
    IFactory public factory;

    /**
     * @dev Providers index, started from 1
     */
    mapping(address => uint256) public indexOf;

    function refill(uint256 _value) external returns (bool) {
        xrt.safeTransferFrom(msg.sender, this, _value);

        if (stakes[msg.sender] == 0) {
            require(_value >= minimalStake);
            providers.push(msg.sender);
            indexOf[msg.sender] = providers.length;
            emit Online(msg.sender);
        }

        stakes[msg.sender] += _value;
        return true;
    }

    function withdraw(uint256 _value) external returns (bool) {
        require(stakes[msg.sender] >= _value);

        stakes[msg.sender] -= _value;
        xrt.safeTransfer(msg.sender, _value);

        // Drop member with zero quota
        if (quotaOf(msg.sender) == 0) {
            uint256 balance = stakes[msg.sender];
            stakes[msg.sender] = 0;
            xrt.safeTransfer(msg.sender, balance);
            
            uint256 senderIndex = indexOf[msg.sender] - 1;
            uint256 lastIndex = providers.length - 1;
            if (senderIndex < lastIndex)
                providers[senderIndex] = providers[lastIndex];

            providers.length -= 1;
            indexOf[msg.sender] = 0;

            emit Offline(msg.sender);
        }
        return true;
    }

    uint256 private startGas;

    modifier startGasEstimation {
        startGas = gasleft();

        _;
    }

    function nextProvider() internal
    { marker = (marker + 1) % providers.length; }

    modifier keepAliveTransaction {
        if (timeoutInBlocks < block.number - keepAliveBlock) {
            // Thransaction sender should be a registered provider 
            require(indexOf[msg.sender] > 0 && indexOf[msg.sender] <= providers.length);

            // Set up the marker according to provider index
            marker = indexOf[msg.sender] - 1;

            // Allocate new quota
            quota = quotaOf(providers[marker]);

            // Current provider signal
            emit Current(providers[marker], quota);
        }

        // Store transaction sending block
        keepAliveBlock = block.number;

        _;
    }

    modifier quotedTransaction {
        // Don't premit transactions without providers on board
        require(providers.length > 0);

        // Zero quota guard
        // XXX: When quota for some reasons is zero, DoS will be preverted by keepalive transaction
        require(quota > 0);

        // Only provider with marker can to send transaction
        require(msg.sender == providers[marker]);

        // Consume one quota for transaction sending
        quota -= 1;

        if (quota == 0) {
            // Step over marker
            nextProvider();

            // Allocate new quota
            quota = quotaOf(providers[marker]);

            // Current provider signal
            emit Current(providers[marker], quota);
        }

        _;
    }

    function createLiability(
        bytes _demand,
        bytes _offer
    )
        external
        startGasEstimation
        keepAliveTransaction
        quotedTransaction
        returns (bool)
    {
        ILiability liability = factory.createLiability(_demand, _offer);
        require(address(liability) != 0);
        require(factory.liabilityCreated(liability, startGas));
        return true;
    }

    function finalizeLiability(
        address _liability,
        bytes _result,
        bool _success,
        bytes _signature
    )
        external
        startGasEstimation
        keepAliveTransaction
        quotedTransaction
        returns (bool)
    {
        ILiability liability = ILiability(_liability);

        require(factory.gasConsumedOf(_liability) > 0);
        require(liability.finalize(_result, _success, _signature));
        require(factory.liabilityFinalized(liability, startGas));
        return true;
    }
}
