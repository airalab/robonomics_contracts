pragma solidity ^0.4.18;

import 'token/TokenEmission.sol';
import 'token/TokenObservable.sol';
import './Association.sol';
import './RewardFund.sol';

contract DAOToken is TokenEmission, TokenObservable {
    function DAOToken(string _name, string _symbol,
                      uint8 _decimals, uint _start_count) public
        TokenEmission(_name, _symbol, _decimals, _start_count) {}

    // DAO holders association
    Association public daoAssociation;

    /**
     * @dev Set dao holders association
     * @param _association Association address
     */
    function setAssociation(Association _association) public onlyOwner {
        if (address(daoAssociation) != 0)
            delObserver(TRANSFER_EVENT, daoAssociation);

        addObserver(TRANSFER_EVENT, _association);
        daoAssociation = _association;
    }

    // DAO token reward fund
    RewardFund public daoRewardFund;

    /**
     * @dev Set reward fund for DAO token
     * @param _fund DAO reward fund 
     */
    function setRewardFund(RewardFund _fund) public onlyOwner {
        if (address(daoRewardFund) != 0)
            delObserver(TRANSFER_EVENT, daoRewardFund);

        addObserver(TRANSFER_EVENT, _fund);
        daoRewardFund = _fund;
    }
}
