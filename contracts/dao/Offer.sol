pragma solidity ^0.4.4;
import 'common/Object.sol';
import 'token/Token.sol';

contract Offer is Object {
    string  public description;
    address public beneficiary;
    address public hardOffer; 
    Token   public token;
    uint    public value;

    /* Mapping of offer accepters by count of accept */
    mapping(address => bool) public signer;

    uint public closed = 0;
    /**
     * @dev Force close the offer
     */
    function close() onlyOwner { closed = now; }

    /**
     * @dev Offer constructor
     * @param _description is a short description
     * @param _token is a offer token
     * @param _value is a count of tokens for transfer
     * @param _beneficiary is a offer recipient
     * @param _hard_offer is a hard offer address
     */
    function Offer(string _description, address _token, uint _value,
                   address _beneficiary, address _hard_offer) {
        description = _description;
        token       = Token(_token);
        value       = _value;
        beneficiary = _beneficiary;
        hardOffer   = _hard_offer;
    }

    function accept() {
        if (closed > 0) throw;
        if (hardOffer != 0 && msg.sender != hardOffer) throw;
        if (!token.transferFrom(msg.sender, beneficiary, value)) throw;
        signer[msg.sender] = true;
        closed = now;
    }
}
