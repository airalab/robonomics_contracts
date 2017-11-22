pragma solidity ^0.4.18;

import 'common/Object.sol';

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
    function groupLength() public view returns (uint256)
    { return group.length; }

    struct Members {
        address[] list;
        mapping(address => bool) contains;
    }

    mapping(bytes32 => Members) members;

    /**
     * @dev Group members iteration start.
     * @param _group A group name.
     * @param _index A groum member position.
     * @return first member address
     */
    function member(string _group, uint256 _index) public view returns (address)
    { return members[sha3(_group)].list[_index]; }
    
    /**
     * @dev Check for `_member` address is member of `_groupName`
     * @param _group is a group name for check
     * @param _member is a address for member checking
     * @return `true` when address is member of group
     */
    function isMemberOf(string _group, address _member) public view returns (bool)
    { return members[sha3(_group)].contains[_member]; }

    /**
     * @dev Create access group
     * @param _name is a group name
     * @param _firstMember is a first member address, group should not be empty
     */
    function createGroup(string _name, address _firstMember) public onlyOwner {
        var m = members[sha3(_name)];
        require(m.list.length == 0);

        group.push(_name);
        m.list.push(_firstMember);
        m.contains[_firstMember] = true;
    }

    /**
     * @dev Add new member into group
     * @param _group is a group name
     * @param _member is a new member address
     */
    function addMember(string _group, address _member) public onlyOwner {
        var m = members[sha3(_group)];
        require(m.list.length > 0);

        m.list.push(_member);
        m.contains[_member] = true;
    }

    /**
     * @dev Remove member from group
     * @param _group is a group name
     * @param _member is a address for remove
     */
    function removeMember(string _group, address _member) public onlyOwner {
        var m = members[sha3(_group)];
        require(m.list.length > 0);

        m.contains[_member] = false;
        for (uint256 i = 0; i < m.list.length; ++i) {
            if (m.list[i] == _member) {
                m.list[i] = m.list[m.list.length - 1];
                --m.list.length;
                break;
            }
        }
    }
}
