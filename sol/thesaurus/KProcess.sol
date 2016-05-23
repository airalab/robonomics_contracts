import './Knowledge.sol';

/**
 * The knowledge process describe knowledge manipulation
 */
contract KProcess is Knowledge {
    /* KProcess constructor */
    function KProcess() Knowledge(PROCESS) {}

    /**
     * Morphism describe knowledge manipulation line
     * e.g. apple production have a morphism with 
     * three objects: Ground -> AppleTree -> Apple
     * this knowledges can be stored in morphism list
     * as [ Ground, AppleTree, Apple ]
     */
    address[] morphism;

    function morphismLength() constant returns (uint)
    { return morphism.length; }

    /**
     * Append knowledge into line
     * @param _knowledge new item of `morphism` list
     */
    function append(Knowledge _knowledge) onlyOwner
    { morphism.push(_knowledge); }
    
    /**
     * Get knowledge by position
     * @param _index knowledge position in `morphism`
     */
    function get(uint _index) returns (Knowledge)
    { return Knowledge(morphism[_index]); }

    function isEqual(Knowledge _to) constant returns (bool) {
        if (knowledgeType != _to.knowledgeType())
            return false; 
        
        var process = KProcess(_to);
        // Count of knowledges in equal processes should be same
        if (morphism.length != process.morphismLength())
            return false;

        for (uint i = 0; i < morphism.length; i += 1)
            // All knowledge in morphism line should be equal
            if (!get(i).isEqual(process.get(i)))
                return false;
        return true;
    }
}
