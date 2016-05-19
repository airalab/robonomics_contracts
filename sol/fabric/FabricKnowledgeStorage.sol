import 'thesaurus/KnowledgeStorage.sol';

library FabricKnowledgeStorage {
    function create() returns (KnowledgeStorage)
    { return new KnowledgeStorage(); }
}
