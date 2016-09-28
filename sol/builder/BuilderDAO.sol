//
// AIRA Builder for basic DAO contracts
//
// Ethereum address:
//  - Testnet: 
//

pragma solidity ^0.4.2;
import 'creator/CreatorTokenEmission.sol';
import 'creator/CreatorCore.sol';
import './Builder.sol';

contract BuilderDAO is Builder {
    function create(string _dao_name, string _dao_description,
                    string _shares_name, string _shares_symbol, uint _shares_count) {
        // DAO core
        var dao = CreatorCore.create(_dao_name, _dao_description);

        var shares = CreatorTokenEmission.create(_shares_name, _shares_symbol, 0, _shares_count);
        shares.transfer(msg.sender, _shares_count);
        shares.delegate(msg.sender);

        // Append shares module
        dao.set(_shares_name, shares,
                "github://airalab/core/token/TokenEmission.sol", true);

        // Delegate DAO to sender
        dao.delegate(msg.sender);

        // Notify
        deal(dao);
    }
}
