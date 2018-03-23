pragma solidity ^0.4.20;

contract LighthouseABI {
    function quotaOf(address _member) public view returns (uint256);
    function refill(uint256 _value) public;
    function withdraw(uint256 _value) public;
}
