pragma solidity ^0.4.20;

import './LighthouseAPI.sol';
import './LighthouseABI.sol';

contract LighthouseLib is LighthouseAPI, LighthouseABI {
    function quotaOf(address _member) public view returns (uint256)
    { return balances[_member] / minimalFreeze; }

    function refill(uint256 _value) public {
        require(factory.xrt().transferFrom(msg.sender, this, _value));
        require(_value >= minimalFreeze);

        if (balances[msg.sender] == 0) {
            indexOf[msg.sender] = members.length;
            members.push(msg.sender);
        }
        balances[msg.sender] += _value;
    }

    function withdraw(uint256 _value) public {
        require(balances[msg.sender] >= _value);

        require(factory.xrt().transfer(msg.sender, _value));
        balances[msg.sender] -= _value;

        // Drop member if quota go to zero
        if (quotaOf(msg.sender) == 0) {
            require(factory.xrt().transfer(msg.sender, balances[msg.sender])); 
            balances[msg.sender] = 0;
            
            uint256 senderIndex = indexOf[msg.sender];
            uint256 lastIndex = members.length - 1;
            if (senderIndex < lastIndex)
                members[senderIndex] = members[lastIndex];
            members.length -= 1;
        }
    }

    function () public {
        require(members.length > 0);

        if (quota == 0) {
            marker = (marker + 1) % members.length;
            quota = balances[members[marker]] / minimalFreeze;
        }
        require(msg.sender == members[marker]);

        quota -= 1;
        require(factory.call(msg.data));
    }
}
