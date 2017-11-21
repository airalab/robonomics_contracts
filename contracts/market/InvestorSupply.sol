pragma solidity ^0.4.18;

import 'common/Object.sol';
import 'token/ERC20.sol';

contract InvestorSupply is Object {
    ERC20 constant public utility;

    mapping(bytes32 => uint256) supplyOf;
    mapping(bytes32 => mapping(address => uint256)) accountSupplyOf;

    function supply(string _market) view returns (uint256)
    { return supplyOf[keccak256(market)]; }

    function refill(string _market, uint256 _value) {
        require(utility.transferFrom(msg.sender, this, _value));
        supplyOf[keccak256(market)] += _value;
        accountSupplyOf[keccak256(market)][msg.sender] += _value; 
    }

    function withdraw(string _market, uint256 _value) {
        require(accountSupplyOf[keccak256(market)][msg.sender] >= _value); 
        supplyOf[keccak256(market)] -= _value;
        accountSupplyOf[keccak256(market)][msg.sender] -= _value; 
    }
}
