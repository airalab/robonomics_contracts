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

    // List of received reward payments
    Reward[] public rewards;

    // Minimal incoming reward value
    uint public minimalReward;

    /**
     * @dev Get rewards array length
     */
    function rewardsLength() constant returns (uint)
    { return rewards.length; }

    // Pointer to holder next reward,
    // is equal to rewards.length if no reward available
    mapping(address => uint) public nextReward;

    function RewardFund(string _name, string _symbol, address _dao_token, uint _min)
            TokenEther(_name, _symbol) {
        daoToken = DAOToken(_dao_token);
        minimalReward = _min;
    }

    /**
     * @dev Refill reward fund
     */
    function putReward() payable {
        if (msg.value < minimalReward) throw;

        totalSupply    += msg.value;
        balances[this] += msg.value;
        rewards.push(Reward(msg.sender, msg.value, now));
    }

    /**
     * @dev Get reward for sender account
     */
    function getReward()
    { getReward(msg.sender, daoToken.balanceOf(msg.sender), daoToken.totalSupply()); }

    /**
     * @dev Get multiple rewards for sender account,
     * @notice Possible out of gas with big _count
     */
    function getRewards(uint _count) {
        var accountShares = daoToken.balanceOf(msg.sender);
        var daoShares     = daoToken.totalSupply();
        for (uint i = 0; i < _count && nextReward[msg.sender] < rewards.length; ++i)
            getReward(msg.sender, accountShares, daoShares);
    }

    /**
     * @dev Get reward for account
     * @param _account Target account
     */
    function getReward(address _account, uint accountShares, uint daoShares)
            internal returns (bool) {
        if (nextReward[_account] < rewards.length) {
            var reward         = rewards[nextReward[_account]];
            uint accountReward = reward.value * accountShares / daoShares;
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
            var daoShares = daoToken.totalSupply();

            // Make rewards for token sender
            var fromShares = daoToken.balanceOf(from);
            while (nextReward[from] < rewards.length)
                if (!getReward(from, fromShares, daoShares)) throw;

            // Make rewards for token receiver
            var toShares = daoToken.balanceOf(to);
            while (nextReward[to] < rewards.length)
                if (!getReward(to, toShares, daoShares)) throw;
        }

        return true;
    }
}
