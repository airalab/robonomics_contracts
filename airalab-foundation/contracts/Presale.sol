pragma solidity ^0.4.18;

import 'airalab-token/contracts/ERC20.sol';
import 'airalab-common/contracts/Object.sol';

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
    function Presale(address _token, uint256 _bounty, uint256 _donation) public {
        token    = ERC20(_token);
        bounty   = _bounty;
        donation = _donation;
    }

    /**
     * @dev Cancel presale contract by owner, bounty refunded to owner
     */
    function cancel() public onlyOwner {
        require (token.transfer(owner, bounty));
    }

    /**
    * @dev Accept presale contract,
    *      bounty transfered to sender - donation to owner
    */
    function () public payable {
        require (msg.value == donation);
        require (token.transfer(msg.sender, bounty));
        require (owner.send(msg.value));
    }
}
