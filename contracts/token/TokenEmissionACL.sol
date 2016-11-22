pragma solidity ^0.4.4;
import './TokenEmission.sol';
import 'acl/ACL.sol';

contract TokenEmissionACL is TokenEmission, ACL {
    function TokenEmissionACL(string _name, string _symbol, uint8 _decimals,
                              uint _start_count,
                              address _acl_storage, string _emitent_group)
             TokenEmission(_name, _symbol, _decimals, _start_count) {
        acl          = ACLStorage(_acl_storage);
        emitentGroup = _emitent_group;
    }

    string public emitentGroup;

    /**
     * @dev Token emission
     * @param _value amount of token values to emit
     * @notice owner balance will be increased by `_value`
     */
    function emission(uint _value) onlyGroup(emitentGroup) {
        // Overflow check
        if (_value + totalSupply < totalSupply) throw;

        totalSupply          += _value;
        balances[msg.sender] += _value;
    }
}
