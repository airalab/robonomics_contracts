import 'thesaurus.sol';

/*
 * Storage contains all agent knowledges and active contracts
 */
contract AgentStorage is Mortal {
    /* The knowledge base of agent */
    Array.Data knowledges;
    
    /* Common used array iterator */
    Array.Iterator it;
    
    function knowledgesLength() returns (uint)
    { return Array.size(knowledges); }
    
    function appendKnowledge(Knowledge _knowledge) onlyOwner {
        Array.append(knowledges, _knowledge);
    }

    function removeKnowledge(Knowledge _knowledge) onlyOwner {
        Array.find(knowledges, it, _knowledge);
        if (!Array.end(knowledges, it)) {
            Knowledge(Array.get(it)).kill();
            Array.remove(it);
        }
    }
}

/*
 * Same as AgentStorage but have human readable interface
 */
contract HumanAgentStorage is AgentStorage {
    /* Thesaurus interface for knowledge base */
    Thesaurus.Index thesaurus;
}
