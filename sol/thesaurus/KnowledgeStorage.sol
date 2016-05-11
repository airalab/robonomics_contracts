import 'lib/AddressArray.sol';
import 'common/Mortal.sol';
import './Knowledge.sol';

/**
 * @title Contract for access to knowledges by index or term name
 */
contract KnowledgeStorage is Mortal {
    /* The knowledge base of agent */
    address[] public knowledgeList;
    using AddressArray for address[];

    /*
     * Index based accessors
     */

    function size() constant returns (uint)
    { return knowledgeList.length; }
    
    function get(uint _index) constant returns (Knowledge)
    { return Knowledge(knowledgeList[_index]); }
    
    function append(Knowledge _knowledge) onlyOwner
    { knowledgeList.push(_knowledge); }
    
    function remove(Knowledge _knowledge) onlyOwner {
        var index = knowledgeList.indexOf(_knowledge);
        if (index < knowledgeList.length) {
            knowledgeList.remove(index);
        }
    }

    /*
     * Name based accessors
     */
 
    mapping(address => string) public nameOf;
    mapping(bytes32 => address) addressOf;

    /**
     * @dev Append new knowledge into thesaurus
     * @notice knowledge with the same name will be replaced
     * @param _name knowledge name
     * @param _knowledge knowledge address
     */
    function set(string _name, Knowledge _knowledge) onlyOwner {
        // Append to list if no exists
        if (knowledgeList.indexOf(_knowledge) == knowledgeList.length)
            knowledgeList.push(_knowledge);
        // Set mapping fields
        nameOf[_knowledge] = _name;
        addressOf[sha3(_name)] = _knowledge;
    }
    
    function getByName(string _name) constant returns (Knowledge)
    { return Knowledge(addressOf[sha3(_name)]); }
}
