pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol';

contract XRT is MintableToken, BurnableToken {
    string public name     = "Robonomics Token :: Kovan";
    string public symbol   = "XRT";
    uint   public decimals = 9;
}
