import 'thesaurus.sol';

/**
 * @title Storage contains all agent knowledges and active contracts
 */
contract AgentStorage is Mortal {
    /*
     * Knowledge base
     */
    
    /* The knowledge base of agent */
    address[] public knowledges;
    using AddressArray for address[];
    
    function knowledgesLength() constant returns (uint)
    { return knowledges.length; }
    
    function getKnowledge(uint _index) constant returns (Knowledge)
    { return Knowledge(knowledges[_index]); }
    
    function appendKnowledge(Knowledge _knowledge) onlyOwner
    { knowledges.push(_knowledge); }
    
    function removeKnowledge(Knowledge _knowledge) onlyOwner {
        var index = knowledges.indexOf(_knowledge);
        if (index < knowledges.length) {
            Knowledge(knowledges[index]).kill();
            knowledges.remove(index);
        }
    }
    
    /*
     * Contract base
     */
    
    /* The active contract base of agent */
    address[] public contracts;
    
    function contractsLength() constant returns (uint)
    { return contracts.length; }
    
    function getContract(uint _index) constant returns (address)
    { return contracts[_index]; }
    
    function appendContract(address _contract) onlyOwner
    { contracts.push(_contract); }
    
    function removeContract(address _contract) onlyOwner {
        var index = contracts.indexOf(_contract);
        if (index < contracts.length)
            contracts.remove(index);
    }
}

/*
 * Same as AgentStorage but have human readable interface
 */
contract HumanAgentStorage is AgentStorage {
    /* Thesaurus interface for knowledge base */
    Thesaurus.Index thesaurus;
    
    function thesaurusLength() constant returns (uint)
    { return thesaurus.thesaurus.length; }
    
    function thesaurusGet(uint _index) constant returns (string)
    { return thesaurus.thesaurus[_index]; }
    
    /**
     * @dev Append new knowledge into thesaurus
     * @notice knowledge with the same name will be replaced
	 * @param _name knowledge name
	 * @param _knowledge knowledge address
     */
    function appendKnowledgeByName(string _name, Knowledge _knowledge) {
        appendKnowledge(_knowledge);
        
        var replaced = Thesaurus.set(thesaurus, _name, _knowledge);
        /* Knowledge with same name already exist */
        if (replaced != Knowledge(0x0))
            removeKnowledge(replaced);
    }
    
    function getKnowledgeByName(string _name) constant returns (Knowledge) {
        return Thesaurus.get(thesaurus, _name);
    }
}
