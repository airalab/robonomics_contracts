pragma solidity ^0.4.24;

contract LighthouseABI {
    function quotaOf(address _member) public view returns (uint256);
    function refill(uint256 _value) external;
    function withdraw(uint256 _value) external;
    function to(address _to, bytes _data) external;
    function () external;
}
