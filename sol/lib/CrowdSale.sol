import 'lib/AddressArray.sol';
import 'token/Token.sol';

library CrowdSale {
    struct Item {
        address   target;
        uint      total;
        bool      closed;
        address[] voters;
        mapping(address => uint) valueOf;
    }

    using AddressArray for address[];

    /**
     * @dev Initial new crowdsale goal
     * @param _data is crowdsale item
     * @param _target is crowdsale target address
     * @param _total is crowdsale value goal
     */
    function init(Item storage _data, address _target, uint _total) {
        _data.target = _target;
        _data.total  = _total;
        _data.closed = false;
    }

    /**
     * @dev Append new voter for crowdsale
     * @param _data is crowdsale item
     * @param _voter is voter address
     * @param _credits is crowdsale credits token
     * @param _shares is crowdsale shares token
     */
    function fund(Item storage _data, address _voter,
                  Token _credits, Token _shares) returns (bool) {
        var count = _shares.getBalance(_voter);
        if (count == 0 || _data.closed)
            return false;

        _shares.transferFrom(_voter, this, count);
        if (_data.voters.indexOf(_voter) == _data.voters.length)
            _data.voters.push(_voter);
        _data.valueOf[_voter] += count;

        var available = _shares.totalSupply() - _shares.getBalance();
        var scale     = _credits.getBalance() / available;
        if (sum(_data) * scale < _data.total)
            return false;

        if (_credits.transfer(_data.target, _data.total))
            _data.closed = true;
        return _data.closed;
    }
    
    /**
     * @dev Get summary shares value of target
     * @param _data is crowdsale item
     */
    function sum(Item storage _data) constant returns (uint) {
        uint summary = 0;
        for (uint i = 0; i < _data.voters.length; i += 1)
            summary += _data.valueOf[_data.voters[i]];
        return summary;
    }
}
