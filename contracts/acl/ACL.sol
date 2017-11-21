pragma solidity 0.4.18;

import './ACLStorage.sol';

/**
 * @title Access Control List contract
 */
contract ACL {
    ACLStorage public acl;

    modifier onlyGroup(string _name) {
        require(acl.isMemberOf(_name, msg.sender));
        _;
    }
}
