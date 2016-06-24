//
// AIRA Builder for basic DAO contracts
//
// Ethereum address:
//  - Testnet: 
//

import 'creator/CreatorTokenEmission.sol';
import 'creator/CreatorCore.sol';
import './Builder.sol';

contract BuilderDAO is Builder {
    function BuilderDAO(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}

    function create(string _dao_name, string _dao_description,
                    string _shares_name, string _shares_symbol, uint _shares_count) {
        // DAO core
        var dao = CreatorCore.create(_dao_name, _dao_description);

        var shares = CreatorTokenEmission.create(_shares_name, _shares_symbol, 0, _shares_count);
        shares.delegate(msg.sender);

        // Append shares module
        dao.setModule(_shares_name, shares,
                      "github://airalab/core/token/TokenEmission.sol", true);

        // Delegate DAO to sender
        dao.delegate(msg.sender);

        // Notify
        deal(dao);
    }
}
