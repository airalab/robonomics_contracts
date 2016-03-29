import 'thesaurus.sol';

/*
 * Knowledge storage contains all agent knowledges and thesaurus for this
 */
contract KnowledgeStorage is Mortal {
    /* The knowledge base of agent */
    Knowledge[] public knowledges;
    
    function knowledgesLength() returns (uint)
    { return knowledges.length; }
    
    /* Helper mappings */
    mapping (address => uint) public knowledgeIndexOf;
    mapping (address => bool) public isKnowledgeAlive;
    
    /* Thesaurus interface for knowledge base */
    Thesaurus.Index thesaurus;
    
    function insertKnowledge(string _name, Knowledge _knowledge) onlyOwner {
        // Insert new term into thesaurus
        var replaced = Thesaurus.insert(thesaurus, _name, _knowledge);

        // Check for replacement insert
        if (replaced != 0x0) {
            /* Replace exist knowledge */
            var i = knowledgeIndexOf[replaced];
            knowledges[i].kill();
            knowledges[i] = _knowledge;
            knowledgeIndexOf[_knowledge] = i;
        } else {
            /* Append to tail */
            knowledges[knowledges.length++] = _knowledge;
            knowledgeIndexOf[_knowledge] = knowledges.length - 1;
        }
        
        isKnowledgeAlive[_knowledge] = true;
    }
    
    function removeKnowledge(string _name) onlyOwner {
        var knowledge = thesaurus.knowledgeOf[sha3(_name)];
        isKnowledgeAlive[knowledge] = false;
    }
    
    function removeKnowledge(Knowledge _knowledge) onlyOwner {
        isKnowledgeAlive[_knowledge] = false;
    }
}
