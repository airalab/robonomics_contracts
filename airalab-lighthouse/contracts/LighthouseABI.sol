pragma solidity ^0.4.18;

contract LighthouseABI {
    function quotaOf(address _member) public view returns (uint256);
    function refill(uint256 _value) public;
    function withdraw(uint256 _value) public;
    function to(address _to, bytes _data) public;
}
