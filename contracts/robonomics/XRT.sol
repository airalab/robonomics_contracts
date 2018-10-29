pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol';

contract XRT is ERC20Mintable, ERC20Burnable, ERC20Detailed {
    constructor() public ERC20Detailed("Robonomics Beta 3", "XRT", 9) {
        uint256 INITIAL_SUPPLY = 1000 * (10 ** 9);
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
