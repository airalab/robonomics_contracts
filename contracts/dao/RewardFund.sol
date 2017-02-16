pragma solidity ^0.4.4;
import 'token/TokenObservable.sol';
import 'token/TokenEther.sol';
import './DAOToken.sol';

contract RewardFund is TokenEther, Observer {
    uint                     public totalReward;
    mapping(address => uint) public paidOf;
    DAOToken                 public daoToken;

    function RewardFund(string _name, string _symbol, address _dao_token)
            TokenEther(_name, _symbol) {
        daoToken = DAOToken(_dao_token);
    }

    /**
     * @dev Get reward for sender account
     */
    function getReward()
    { getReward(msg.sender); }

    /**
     * @dev Get reward for account
     * @param _account Target account
     */
    function getReward(address _account) internal {
        var accountShares = daoToken.balanceOf(_account);
        var totalShares   = daoToken.totalSupply();
        
        if (accountShares > 0) {
            var reward = totalReward * totalShares / accountShares;
            var paid   = paidOf[_account];
            if (reward > paid) {
                paidOf[_account] += reward - paid;
                if (!transfer(_account, reward - paid)) throw;
            }
        }
    }

    /**
     * @dev Observer interface
     */
    function eventHandle(uint _event, bytes32[] _data) returns (bool) {
        if (msg.sender != address(daoToken)) throw;

        if (_event == 0x10) { // TRANSFER_EVENT
            address from = address(_data[0]);
            address to   = address(_data[1]);
            getReward(from);
            getReward(to);
        }
    }

    /**
     * @dev Refill reward fund
     */
    function () payable {
        totalSupply    += msg.value;
        totalReward    += msg.value;
        balances[this] += msg.value;
    }
}
