pragma solidity ^0.4.2;
import 'common/Mortal.sol';

/**
 * @title Builder based contract
 */
contract BuilderBase is Mortal {
    /* Addresses builded contracts at sender */
    mapping(address => address[]) public getContractsOf;
    
    /**
     * @dev this event emitted for every builded contract
     */
    event Builded(address indexed sender, address indexed instance);
    
    /**
     * @dev Get last address
     * @return last address contract
     */
    function getLastContract() constant returns (address) {
        var sender_contracts = getContractsOf[msg.sender];
        return sender_contracts[sender_contracts.length - 1];
    }
}
