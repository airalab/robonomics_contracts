pragma solidity ^0.5.0;

contract AbstractResolver {
    function supportsInterface(bytes4 _interfaceID) public view returns (bool);
    function addr(bytes32 _node) public view returns (address ret);
    function setAddr(bytes32 _node, address _addr) public;
    function hash(bytes32 _node) public view returns (bytes32 ret);
    function setHash(bytes32 _node, bytes32 _hash) public;
}
