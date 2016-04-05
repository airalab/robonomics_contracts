import 'thesaurus.sol';

/*
 * Storage contains all agent knowledges and active contracts
 */
contract AgentStorage is Mortal {
    /* Common used array iterator */
    Array.Iterator it;
    
    /*
     * Knowledge base
     */
    
    /* The knowledge base of agent */
    Array.Data knowledges;
    
    function knowledgesLength() constnant returns (uint)
    { return Array.size(knowledges); }
    
    function getKnowledge(uint _index) constnant returns (Knowledge)
    { return Knowledge(Array.get(knowledges, _index)); }
    
    function appendKnowledge(Knowledge _knowledge) onlyOwner
    { Array.append(knowledges, _knowledge); }
    
    function removeKnowledge(Knowledge _knowledge) onlyOwner {
        Array.setBegin(knowledges, it);
        Array.find(it, _knowledge);
        if (!Array.end(it)) {
            Knowledge(Array.get(it)).kill();
            Array.remove(it);
        }
    }
    
    /*
     * Contract base
     */
    
    /* The active contract base of agent */
    Array.Data contracts;
    
    function contractsLength() constnant returns (uint)
    { return Array.size(contracts); }
    
    function getContract(uint _index) constnant returns (address)
    { return Array.get(contracts, _index); }
    
    function appendContract(address _contract) onlyOwner
    { Array.append(contracts, _contract); }
    
    function removeContract(address _contract) onlyOwner {
        Array.setBegin(contracts, it);
        Array.find(it, _contract);
        if (!Array.end(it))
            Array.remove(it);
    }
}

/*
 * Same as AgentStorage but have human readable interface
 */
contract HumanAgentStorage is AgentStorage {
    /* Thesaurus interface for knowledge base */
    Thesaurus.Index thesaurus;
    
    function thesaurusLength() constnant returns (uint)
    { return thesaurus.thesaurus.length; }
    
    function thesaurusGet(uint _index) constnant returns (string)
    { return thesaurus.thesaurus[_index]; }
    
    function appendKnowledgeByName(string _name, Knowledge _knowledge) {
        appendKnowledge(_knowledge);
        
        var replaced = Thesaurus.set(thesaurus, _name, _knowledge);
        /* Knowledge with same name already exist */
        if (replaced != Knowledge(0x0))
            removeKnowledge(replaced);
    }
    
    function getKnowledgeByName(string _name) constnant returns (Knowledge) {
        return Thesaurus.get(thesaurus, _name);
    }
}
