//
// AIRA Builder for Offer contract
//
// Ethereum address:
//  - Testnet: 
//

pragma solidity ^0.4.2;
import 'creator/CreatorOffer.sol';
import './Builder.sol';

/**
 * @title BuilderOffer contract
 */
contract BuilderOffer is Builder {
    /**
     * @dev Run script creation contract
     * @param _description is a short description
     * @param _token is a offer token
     * @param _value is a count of tokens for transfer
     * @param _beneficiary is a offer recipient
     * @param _hard_offer is a hard offer address
     * @return address new contract
     */
    function create(string _description, address _token, uint _value,
                    address _beneficiary, address _hard_offer) returns (address) {
        var inst = CreatorOffer.create(_description, _token, _value,
                                       _beneficiary, _hard_offer);
        Owned(inst).delegate(msg.sender);
        getContractsOf[msg.sender].push(inst);
        Builded(msg.sender, inst);
        return inst;
    }
}
