pragma solidity ^0.4.18;

import 'airalab-common/contracts/Object.sol';
import 'airalab-token/contracts/Recipient.sol';

contract TokenHolder is Object, Recipient {
    /**
     * @dev Recipient account address
     */
    address public recipient;

    /**
     * @dev Block number for holding before it'll not mined
     */
    uint256 public holdBeforeBlock;

    /**
     * @dev Construct TokenHolder contract
     * @param _recipient Recipient account address
     * @param _releaseBlock Block for releasing assets
     */
    function TokenHolder(address _recipient, uint256 _releaseBlock) public {
        recipient       = _recipient;
        holdBeforeBlock = _releaseBlock;
    } 

    /**
     * @dev Check for current block is not release block
     */
    modifier holding { if (block.number < holdBeforeBlock) revert(); _; }

    /**
     * @dev Claim ERC20 token
     * @param _token Token address 
     */
    function claimERC20(ERC20 _token) public holding {
        require (_token.transfer(recipient, _token.balanceOf(this))); 
    }

    /**
     * @dev Claim ether
     */
    function claimEther() public holding {
        require (recipient.send(this.balance)); 
    }
}
