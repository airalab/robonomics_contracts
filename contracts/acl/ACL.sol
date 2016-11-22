pragma solidity ^0.4.4;
import './ACLStorage.sol';

/**
 * @title Access Control List contract
 */
contract ACL {
    ACLStorage public acl;

    modifier onlyGroup(string _name) {
        if (!acl.isMemberOf(_name, msg.sender)) throw;
        _;
    }
}
