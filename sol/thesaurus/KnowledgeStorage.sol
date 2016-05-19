import 'lib/AddressMap.sol';
import 'common/Mortal.sol';
import './Knowledge.sol';

/**
 * @title Contract for access to knowledges by index or term name
 */
contract KnowledgeStorage is Mortal {
    /* The knowledge base */
    AddressMap.Data knowledges;

    /* Using libraries */
    using AddressList for AddressList.Data;
    using AddressMap for AddressMap.Data;
 
    /**
     * @dev Get first knowledge
     * @return first knowledge of list
     */
    function first() constant returns (Knowledge)
    { return Knowledge(knowledges.items.head); }

    /**
     * @dev Get next knowledge of list
     * @param _current is a current knowledge
     * @return next knowledge
     */
    function next(Knowledge _current) constant returns (Knowledge)
    { return Knowledge(knowledges.items.next(_current)); }

    /**
     * @dev Get knowledge by name
     * @param _name is a knowledge name
     * @return knowledge address
     */
    function get(string _name) constant returns (Knowledge)
    { return Knowledge(knowledges.get(_name)); }

    /**
     * @dev Get name of knowledge
     * @param _knowledge is a knowledge address
     * @return knowledge name
     */
    function getName(Knowledge _knowledge) constant returns (string)
    { return knowledges.keyOf[_knowledge]; }

    /**
     * @dev Append new knowledge into thesaurus
     * @notice knowledge with the same name will be replaced
     * @param _name knowledge name
     * @param _knowledge knowledge address
     */
    function set(string _name, Knowledge _knowledge) onlyOwner
    { knowledges.set(_name, _knowledge); }
}
