pragma solidity ^0.4.24;

import './LighthouseAPI.sol';
import './LighthouseABI.sol';
import './LiabilityFactory.sol';

contract LighthouseLib is LighthouseAPI, LighthouseABI {

    function refill(uint256 _value) external {
        require(xrt.transferFrom(msg.sender, this, _value));
        require(_value >= minimalFreeze);

        if (balances[msg.sender] == 0) {
            indexOf[msg.sender] = members.length;
            members.push(msg.sender);
        }
        balances[msg.sender] += _value;
    }

    function withdraw(uint256 _value) external {
        require(balances[msg.sender] >= _value);

        require(xrt.transfer(msg.sender, _value));
        balances[msg.sender] -= _value;

        // Drop member if quota go to zero
        if (quotaOf(msg.sender) == 0) {
            require(xrt.transfer(msg.sender, balances[msg.sender])); 
            balances[msg.sender] = 0;
            
            uint256 senderIndex = indexOf[msg.sender];
            uint256 lastIndex = members.length - 1;
            if (senderIndex < lastIndex)
                members[senderIndex] = members[lastIndex];
            members.length -= 1;
        }
    }

    function nextMember() internal
    { marker = (marker + 1) % members.length; }

    modifier quoted {
        if (quota == 0) {
            // Step over marker
            nextMember();

            // Allocate new quota
            quota = quotaOf(members[marker]);
        }

        // Consume one quota for transaction sending
        quota -= 1;

        _;
    }

    modifier keepalive {
        if (timeoutBlocks < block.number - keepaliveBlock) {
            // Search keepalive sender
            while (msg.sender != members[marker])
                nextMember();

            // Allocate new quota
            quota = quotaOf(members[marker]);
        }

        _;
    }

    modifier member {
        // Zero members guard
        require(members.length > 0);

        // Only member with marker can to send transaction
        require(msg.sender == members[marker]);

        // Store transaction sending block
        keepaliveBlock = block.number;

        _;
    }

    function to(address _to, bytes _data) external keepalive quoted member
    { require(_to.call(_data)); }

    function () external keepalive quoted member
    { require(factory.call(msg.data)); }
}
