pragma solidity ^0.4.4;

import './ERC20.sol';

/**
 * @title Asset recipient interface
 */
contract Recipient {
    /**
     * @dev On received ethers
     * @param sender Ether sender
     * @param amount Ether value
     */
    event ReceivedEther(address indexed sender,
                        uint256 indexed amount);

    /**
     * @dev On received custom ERC20 tokens
     * @param from Token sender
     * @param value Token value
     * @param token Token contract address
     * @param extraData Custom additional data
     */
    event ReceivedTokens(address indexed from,
                         uint256 indexed value,
                         address indexed token,
                         bytes extraData);

    /**
     * @dev Receive approved ERC20 tokens
     * @param _from Spender address
     * @param _value Transaction value
     * @param _token ERC20 token contract address
     * @param _extraData Custom additional data
     */
    function receiveApproval(address _from, uint256 _value,
                             ERC20 _token, bytes _extraData) {
        if (!_token.transferFrom(_from, this, _value)) throw;
        ReceivedTokens(_from, _value, _token, _extraData);
    }

    /**
     * @dev Catch sended to contract ethers
     */
    function () payable
    { ReceivedEther(msg.sender, msg.value); }
}
