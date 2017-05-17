pragma solidity ^0.4.4;
import 'token/ERC20.sol';
import 'common/Object.sol';

contract Presale is Object {
    ERC20   public token;
    uint256 public bounty;
    uint256 public donation;

    /**
     * @dev Presale contract constructor
     * @param _token Bounty token address
     * @param _bounty Bount value by donation
     * @param _donation Donation value
     */
    function Presale(address _token, uint256 _bounty, uint256 _donation) {
        token    = ERC20(_token);
        bounty   = _bounty;
        donation = _donation;
    }

    /**
     * @dev Cancel presale contract by owner, bounty refunded to owner
     */
    function cancel() onlyOwner {
        if (!token.transfer(owner, bounty)) throw;
    }

    /**
    * @dev Accept presale contract,
    *      bounty transfered to sender - donation to owner
    */
    function () payable {
        if (msg.value != donation) throw;
        if (!token.transfer(msg.sender, bounty)) throw;
        if (!owner.send(msg.value)) throw;
    }
}
