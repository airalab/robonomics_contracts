import 'dao/DAOKnowledgeStorage.sol';

library FactoryKnowledgeStorage {
    function create() returns (KnowledgeStorage)
    { return new KnowledgeStorage(); }
}
