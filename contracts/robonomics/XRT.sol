pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol';

contract XRT is ERC20Mintable, ERC20Burnable, ERC20Detailed {
    constructor(uint256 _initial_supply) public ERC20Detailed("Robonomics", "XRT", 9) {
        _mint(msg.sender, _initial_supply);
    }
}
