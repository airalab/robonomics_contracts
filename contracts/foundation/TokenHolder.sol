pragma solidity ^0.4.18;
import 'common/Object.sol';
import 'token/Recipient.sol';

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
    function TokenHolder(address _recipient, uint256 _releaseBlock) {
        recipient       = _recipient;
        holdBeforeBlock = _releaseBlock;
    } 

    /**
     * @dev Check for current block is not release block
     */
    modifier holding { if (block.number < holdBeforeBlock) throw; _; }

    /**
     * @dev Claim ERC20 token
     * @param _token Token address 
     */
    function claimERC20(ERC20 _token) holding {
        if (!_token.transfer(recipient, _token.balanceOf(this)))
            throw; 
    }

    /**
     * @dev Claim ether
     */
    function claimEther() holding {
        if (!recipient.send(this.balance))
            throw; 
    }
}
