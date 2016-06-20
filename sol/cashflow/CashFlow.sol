import './Proposal.sol';
import 'lib/AddressList.sol';
import 'common/Mortal.sol';
import 'token/Token.sol';

contract CashFlow is Owned {
    Token public credits;
    Token public shares;
 
    // Proposal list
    Proposal[] public proposals;

    // Events
    event Created(address indexed proposal);
    event Updated(address indexed proposal);
    event Closed(address indexed proposal);

    // Constructor
    function CashFlow(address _credits, address _shares) {
        credits = Token(_credits);
        shares  = Token(_shares);
    }

    /**
     * @dev Nominal price of one share in credits
     * @return amount of credits in one share
     */
    function nominalSharePrice() constant returns (uint)
    { return credits.getBalance() / shares.totalSupply(); }

    /**
     * @dev Initial new proposal
     * @param _target is a destination address
     * @param _total is a credits goal
     * @param _description is a short description of new proposal
     * @return proposal address
     */
    function init(address _target, uint _total, string _description) returns (Proposal) {
        var proposal = new Proposal(_target, _total, _description); 
        proposals.push(proposal);
        Created(proposal);
        return proposal;
    }

    /**
     * @dev Vote for the proposal
     * @param _proposal is an proposal instance
     * @param _value is a count of given shares
     */
    function fund(Proposal _proposal, uint _value) {
        if (_proposal.closed() == 0 ||
            shares.getBalance(msg.sender) < _value) throw;

        var share_price = nominalSharePrice();
        var summary     = _proposal.summaryShares() + _value;

        bool overload = summary * share_price > _proposal.targetValue();
        if (overload) {
            var correction = summary * share_price - _proposal.targetValue();
            _value -= correction / share_price;
        }

        // Transfer shares
        shares.transferFrom(msg.sender, this, _value);

        // Append new funder
        _proposal.appendFunder(msg.sender);
        _proposal.setSharesOf(msg.sender, _proposal.sharesOf(msg.sender) + _value);
        _proposal.setSummaryShares(_proposal.summaryShares() + _value);

        // Is proposal done?
        if (_proposal.summaryShares() * share_price >= _proposal.targetValue()) {
            // Transfer credits
            if (!credits.transfer(_proposal.destination(),
                                  _proposal.targetValue())) throw;

            // Close proposal
            _proposal.close();
            _proposal.setSharePrice(share_price);
            Closed(_proposal);
        } else {
            Updated(_proposal);
        }
    }

    /**
     * @dev Refund shares from proposal 
     * @param _proposal is a proposal instance 
     * @param _value is how amount shares will be refunded
     * @notice target proposal should be open
     */
    function refund(Proposal _proposal, uint _value) {
        uint sender_balance = _proposal.sharesOf(msg.sender); 
        uint refund_shares  = 0;

        if (_proposal.closed() > 0) {
            // CLOSED proposal
            var free_shares  = sender_balance
                             * _proposal.backValue()
                             / _proposal.targetValue();

            refund_shares = free_shares > sender_balance
                          ? sender_balance : free_shares;
            refund_shares = refund_shares > _value
                          ? _value : refund_shares;

            _proposal.setRefunSharesOf(msg.sender, refund_shares);
        } else {
            // OPEN proposal
            refund_shares  = sender_balance > _value ? _value : sender_balance; 

            _proposal.setSharesOf(msg.sender, sender_balance - refund_shares);
            _proposal.setSummaryShares(_proposal.summaryShares() - refund_shares);
        }

        if (!shares.transfer(msg.sender, refund_shares)) throw;
        Updated(_proposal);
    }
 
    /**
     * @dev Request for release shares by sending
     * @param _proposal is a proposal instance
     * @param _value is a value of returned credits
     */
    function fundback(Proposal _proposal, uint _value) {
        // Try to take a credits
        if (!credits.transferFrom(msg.sender, this, _value)) throw;

        // Update back value
        _proposal.setBackValue(_proposal.backValue() + _value);
        Updated(_proposal);
    }
}
