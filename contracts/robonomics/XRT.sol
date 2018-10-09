pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol';

contract XRT is ERC20Mintable, ERC20Burnable, ERC20Detailed {
    constructor() public ERC20Detailed("XRT", "Robonomics Beta", 9) {
        uint256 INITIAL_SUPPLY = 1000 * (10 ** 9);
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
