pragma solidity ^0.4.4;
import 'token/TokenObservable.sol';
import 'token/TokenEther.sol';
import './DAOToken.sol';

contract RewardFund is TokenEther, Observer {
    DAOToken public daoToken;

    /**
     * @dev Reward payment description
     */
    struct Reward {
        // Reward sender account
        address sender;
        // Reward value in wei
        uint    value;
        // Reward timestamp
        uint    stamp;
    }

    /**
     * @dev List of received reward payments
     */
    Reward[] public rewards;

    /**
     * @dev Minimal incoming reward value
     */
    uint public minimalReward;

    /**
     * @dev Get rewards array length
     */
    function rewardsLength() constant returns (uint)
    { return rewards.length; }

    /**
     * @dev Pointer to holder next reward,
     *      is equal to rewards.length if no reward available
     */
    mapping(address => uint) public nextReward;

    /**
     * @dev Reward fund construction
     * @param _name Fund token name
     * @param _symbol Fund token symbol 
     * @param _dao_token DAO token address
     * @param _min Minimal reward value in wei
     */
    function RewardFund(string _name, string _symbol, address _dao_token, uint _min)
            TokenEther(_name, _symbol) {
        daoToken = DAOToken(_dao_token);
        minimalReward = _min;
    }

    /**
     * @dev Refill reward fund
     * @notice Payment should be greater than minimal reward
     */
    function putReward() payable {
        if (msg.value < minimalReward) throw;

        totalSupply    += msg.value;
        balances[this] += msg.value;
        rewards.push(Reward(msg.sender, msg.value, now));
    }

    /**
     * @dev Get rewards for sender account,
     * @param _count Count of rewards to payout
     * @notice Possible out of gas with big _count value
     */
    function getRewards(uint _count) {
        var accountShares = daoToken.balanceOf(msg.sender);
        var daoShares     = daoToken.totalSupply();
        for (uint i = 0; i < _count && nextReward[msg.sender] < rewards.length; ++i)
            getReward(msg.sender, accountShares, daoShares);
    }

    function getReward(address _account, uint _accountShares, uint _daoShares)
            internal returns (bool) {
        if (nextReward[_account] < rewards.length) {
            var reward         = rewards[nextReward[_account]];
            uint accountReward = reward.value * _accountShares / _daoShares;
            if (accountReward > 0) {
                if (balances[this] < accountReward) throw;

                balances[_account] += accountReward;
                balances[this]     -= accountReward;
                Transfer(this, _account, accountReward);
            }
            ++nextReward[_account];
        }
        return true;
    }

    /**
     * @dev Observer interface
     */
    function eventHandle(uint _event, bytes32[] _data) returns (bool) {
        if (msg.sender != address(daoToken)) throw;

        if (_event == 0x10) { // TRANSFER_EVENT
            address from = address(_data[0]);
            address to   = address(_data[1]);

            // Check for the all rewards is payed
            if (nextReward[from] < rewards.length
                || nextReward[to] < rewards.length) throw;
        }

        return true;
    }
}
