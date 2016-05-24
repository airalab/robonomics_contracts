import 'thesaurus/DAOKnowledgeStorage.sol';

library FactoryDAOKnowledgeStorage {
    function create(address _thesaurus, address _shares) returns (DAOKnowledgeStorage)
    { return new DAOKnowledgeStorage(_thesaurus, _shares); }
}
