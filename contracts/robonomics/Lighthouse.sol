pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol';

import './interface/ILighthouse.sol';
import './interface/IFactory.sol';
import './XRT.sol';

contract Lighthouse is ILighthouse {
    using SafeERC20 for XRT;

    IFactory public factory;
    XRT      public xrt;

    function setup(XRT _xrt, uint256 _minimalStake, uint256 _timeoutInBlocks) external returns (bool) {
        require(factory == IFactory(0) && _minimalStake > 0 && _timeoutInBlocks > 0);

        minimalStake    = _minimalStake;
        timeoutInBlocks = _timeoutInBlocks;
        factory         = IFactory(msg.sender);
        xrt             = _xrt;

        return true;
    }

    /**
     * @dev Providers index, started from 1
     */
    mapping(address => uint256) public indexOf;

    function refill(uint256 _value) external returns (bool) {
        xrt.safeTransferFrom(msg.sender, address(this), _value);

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

    function keepAliveTransaction() internal {
        if (timeoutInBlocks < block.number - keepAliveBlock) {
            // Set up the marker according to provider index
            marker = indexOf[msg.sender];

            // Thransaction sender should be a registered provider
            require(marker > 0 && marker <= providers.length);

            // Allocate new quota
            quota = quotaOf(providers[marker - 1]);

            // Current provider signal
            emit Current(providers[marker - 1], quota);
        }

        // Store transaction sending block
        keepAliveBlock = block.number;
    }

    function quotedTransaction() internal {
        // Don't premit transactions without providers on board
        require(providers.length > 0);

        // Zero quota guard
        // XXX: When quota for some reasons is zero, DoS will be preverted by keepalive transaction
        require(quota > 0);

        // Only provider with marker can to send transaction
        require(msg.sender == providers[marker - 1]);

        // Consume one quota for transaction sending
        if (quota > 1) {
            quota -= 1;
        } else {
            // Step over marker
            marker = marker % providers.length + 1;

            // Allocate new quota
            quota = quotaOf(providers[marker - 1]);

            // Current provider signal
            emit Current(providers[marker - 1], quota);
        }
    }

    function startGas() internal view returns (uint256 gas) {
        // the total amount of gas the tx is DataFee + TxFee + ExecutionGas
        // ExecutionGas
        gas = gasleft();
        // TxFee
        gas += 21000;
        // DataFee
        for (uint256 i = 0; i < msg.data.length; ++i)
            gas += msg.data[i] == 0 ? 4 : 68;
    }

    function createLiability(
        bytes calldata _demand,
        bytes calldata _offer
    )
        external
        returns (bool)
    {
        // Gas with estimation error
        uint256 gas = startGas() + 5292;

        keepAliveTransaction();
        quotedTransaction();

        ILiability liability = factory.createLiability(_demand, _offer);
        require(liability != ILiability(0));
        require(factory.liabilityCreated(liability, gas - gasleft()));
        return true;
    }

    function finalizeLiability(
        address _liability,
        bytes calldata _result,
        bool _success,
        bytes calldata _signature
    )
        external
        returns (bool)
    {
        // Gas with estimation error
        uint256 gas = startGas() + 23363;

        keepAliveTransaction();
        quotedTransaction();

        ILiability liability = ILiability(_liability);
        require(factory.gasConsumedOf(_liability) > 0);
        require(liability.finalize(_result, _success, _signature));
        require(factory.liabilityFinalized(liability, gas - gasleft()));
        return true;
    }
}
