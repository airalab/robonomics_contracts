pragma solidity ^0.4.18;

import './LighthouseAPI.sol';
import './LighthouseABI.sol';
import './Factory.sol';

contract LighthouseLib is LighthouseAPI, LighthouseABI {

    function quotaOf(address _member) public view returns (uint256)
    { return balances[_member] / minimalFreeze; }

    function refill(uint256 _value) public {
        ERC20 xrt = Factory(factory).xrt();

        require(xrt.transferFrom(msg.sender, this, _value));
        require(_value >= minimalFreeze);

        if (balances[msg.sender] == 0) {
            indexOf[msg.sender] = members.length;
            members.push(msg.sender);
        }
        balances[msg.sender] += _value;
    }

    function withdraw(uint256 _value) public {
        ERC20 xrt = Factory(factory).xrt();

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

    function nextMember() internal {
        marker = (marker + 1) % members.length;
        quota = balances[members[marker]] / minimalFreeze;
        keepaliveBlock = block.number;
    }

    modifier quoted {
        if (quota == 0) nextMember();
        quota -= 1;

        _;
    }

    modifier keepalive {
        if (timeoutBlocks < block.number - keepaliveBlock) {
            nextMember();

            // The main reason why here used 'while' is deadlock if two members is unavailable
            while (msg.sender != members[marker])
                nextMember();
        }

        _;
    }

    modifier member {
        require(members.length > 0);
        require(msg.sender == members[marker]);

        _;
    }

    function to(address _to, bytes _data) public quoted keepalive member
    { require(_to.call(_data)); }

    function () public quoted keepalive member 
    { require(factory.call(msg.data)); }
}
