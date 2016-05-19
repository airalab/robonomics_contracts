import 'dao/DAOKnowledgeStorage.sol';

library FabricDAOKnowledgeStorage {
    function create(KnowledgeStorage _thesaurus, Token _shares) returns (DAOKnowledgeStorage)
    { return new DAOKnowledgeStorage(_thesaurus, _shares); }
}
