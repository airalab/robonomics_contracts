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

    modifier quotedCall {
        require(members.length > 0);

        if (quota == 0) {
            marker = (marker + 1) % members.length;
            quota = quotaOf(members[marker]);
        }

        require(msg.sender == members[marker]);
        quota -= 1;

        _;
    }

    function to(address _to, bytes _data) public quotedCall
    { require(_to.call(_data)); }

    function () public quotedCall
    { require(factory.call(msg.data)); }
}
