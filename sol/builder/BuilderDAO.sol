import 'creator/CreatorKnowledgeStorage.sol';
import 'creator/CreatorTokenEmission.sol';
import 'creator/CreatorCashFlow.sol';
import 'creator/CreatorMarket.sol';
import 'creator/CreatorCore.sol';
import './Builder.sol';

contract BuilderDAO is Builder {
    function BuilderDAO(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}

    function create(string _dao_name, string _dao_description,
                    string _shares_name, string _shares_symbol,
                    string _credits_name, string _credits_symbol) {
        // DAO core
        var dao = CreatorCore.create(_dao_name, _dao_description);

        // Thesaurus simple
        dao.setModule("thesaurus",
                      CreatorKnowledgeStorage.create(),
                      "github://airalab/core/thesaurus/KnowledgeStorage.sol",
                      false);

        // Create DAO shares with spec
        dao.setModule("shares", 
                      CreatorTokenEmission.create(_shares_name, _shares_symbol, 0, 0),
                      "github://airalab/core/token/TokenEmission.sol",
                      true);
        Owned(dao.getModule("shares")).delegate(msg.sender);

        // Create DAO shares with spec
        dao.setModule("credits",
                      CreatorTokenEmission.create(_credits_name, _credits_symbol, 0, 0),
                      "github://airalab/core/token/TokenEmission.sol",
                      false);
        Owned(dao.getModule("credits")).delegate(msg.sender);

        // Create market
        dao.setModule("market",
                      CreatorMarket.create(),
                      "github://airalab/core/market/Market.sol",
                      false);

        // Create cashflow
        dao.setModule("cashflow",
                      CreatorCashFlow.create(dao.getModule("credits"),
                                             dao.getModule("shares")),
                      "github://airalab/core/cashflow/CashFlow.sol",
                      false);
        Owned(dao.getModule("cashflow")).delegate(msg.sender);

        // Delegate DAO to sender
        dao.delegate(msg.sender);

        // Notify
        deal(dao);
    }
}
