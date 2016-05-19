import 'fabric/FabricDAOKnowledgeStorage.sol';
import 'fabric/FabricKnowledgeStorage.sol';
import 'fabric/FabricTokenSpec.sol';
import 'fabric/FabricKObject.sol';
import 'fabric/FabricCore.sol';

contract DAOFabric is Mortal {
    event NewDAO(address indexed owner, address indexed dao);

    function newDAO(string _dao_name, string _dao_description,
                    string _shares_name, string _shares_symbol)
            returns (address) {
        // Create thesaurus instance
        var thesaurus = FabricKnowledgeStorage.create();

        // Create shares knowledge instance
        var shares_knowledge = FabricKObject.create();
        shares_knowledge.insertProperty("name",   _shares_name);
        shares_knowledge.insertProperty("symbol", _shares_symbol);
        thesaurus.set("shares", shares_knowledge);
        
        // Create DAO shares
        var dao_shares = FabricTokenSpec.create(_shares_name, _shares_symbol, shares_knowledge);
        dao_shares.delegate(msg.sender);

        // Create DAO thesaurus module
        var dao_thesaurus = FabricDAOKnowledgeStorage.create(thesaurus, dao_shares);
        thesaurus.delegate(dao_thesaurus);
        shares_knowledge.delegate(dao_thesaurus);
        dao_thesaurus.delegate(msg.sender);

        // Create DAO core
        var dao = FabricCore.create(_dao_name, _dao_description);
        dao.setModule("shares", dao_shares,
                      "github://airalab/core/sol/token/SpecToken.sol");
        dao.setModule("thesaurus", dao_thesaurus,
                      "github://airalab/core/sol/dao/DAOKnowledgeStorage.sol");
        dao.delegate(msg.sender);
        NewDAO(msg.sender, dao);
        return dao;
    }
}
