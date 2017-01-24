pragma solidity ^0.4.4;
import 'common/Object.sol';
import 'lib/AddressList.sol';

/**
 * @title ACL storage contract
 * @dev this contract used for store and manage access groups and its members
 */
contract ACLStorage is Object {
    // Group list
    string[] public group;

    /**
     * @dev Size of group array
     */
    function groupLength() constant returns (uint)
    { return group.length; }

    // Group members list by SHA3 of group name
    mapping(bytes32 => AddressList.Data) members;
    using AddressList for AddressList.Data;

    /**
     * @dev Group members iteration start 
     * @param _group is a group name
     * @return first member address
     */
    function memberFirst(string _group) constant returns (address)
    { return members[sha3(_group)].first(); }

    /**
     * @dev Group members iteration
     * @param _group is a group name
     * @param _current is a current iteration address
     * @return next iteration address
     */
    function memberNext(string _group, address _current) constant returns (address)
    { return members[sha3(_group)].next(_current); }
    
    /**
     * @dev Check for `_member` address is member of `_groupName`
     * @param _group is a group name for check
     * @param _member is a address for member checking
     * @return `true` when address is member of group
     */
    function isMemberOf(string _group, address _member) constant returns (bool)
    { return members[sha3(_group)].contains(_member); }

    /**
     * @dev Create access group
     * @param _name is a group name
     * @param _firstMember is a first member address, group should not be empty
     */
    function createGroup(string _name, address _firstMember) onlyOwner {
        var mems = members[sha3(_name)];
        if (mems.first() == 0) {
            group[group.length++] = _name;
            mems.append(_firstMember);
        }
    }

    /**
     * @dev Add new member into group
     * @param _group is a group name
     * @param _member is a new member address
     */
    function addMember(string _group, address _member) onlyOwner
    { members[sha3(_group)].append(_member); }

    /**
     * @dev Remove member from group
     * @param _group is a group name
     * @param _member is a address for remove
     */
    function removeMember(string _group, address _member) onlyOwner
    { members[sha3(_group)].remove(_member); }
}
