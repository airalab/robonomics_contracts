pragma solidity ^0.4.18;

import 'common/Object.sol';
import 'token/ERC20.sol';

contract InvestorSupply is Object {
    /**
     * @dev Utility token.
     */
    ERC20 public constant utility = ERC20(0);

    mapping(bytes32 => uint256) supplyOf;
    mapping(bytes32 => mapping(address => uint256)) accountSupplyOf;

    /**
     * @dev Market token supply.
     * @param _market Market identifier.
     */
    function supply(string _market) public view returns (uint256)
    { return supplyOf[keccak256(_market)]; }

    /**
     * @dev Refill market supply.
     * @param _market Market identifier.
     * @param _value Refill value.
     */
    function refill(string _market, uint256 _value) public {
        require(utility.transferFrom(msg.sender, this, _value));

        supplyOf[keccak256(_market)] += _value;
        accountSupplyOf[keccak256(_market)][msg.sender] += _value; 
    }

    /**
     * @dev Withdraw market supply.
     * @param _market Market identifier.
     * @param _value Withdraw value.
     */
    function withdraw(string _market, uint256 _value) public {
        require(accountSupplyOf[keccak256(_market)][msg.sender] >= _value); 

        supplyOf[keccak256(_market)] -= _value;
        accountSupplyOf[keccak256(_market)][msg.sender] -= _value; 
    }
}
