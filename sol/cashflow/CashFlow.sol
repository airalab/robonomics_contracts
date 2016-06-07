import './Proposal.sol';
import 'lib/AddressList.sol';
import 'common/Mortal.sol';
import 'token/Token.sol';

contract CashFlow is Mortal {
    Token public credits;
    Token public shares;
 
    // Proposal list
    AddressList.Data proposals;
    using AddressList for AddressList.Data;

    // Events
    event NewProposal(address indexed proposal);
    event CloseProposal(address indexed proposal);

    // Constructor
    function CashFlow(address _credits, address _shares) {
        credits = Token(_credits);
        shares  = Token(_shares);
    }

    /**
     * @dev Get first proposal
     * @return first proposal
     */
    function firstProposal() constant returns (address)
    { return proposals.first(); }

    /**
     * @dev Get next proposal
     * @param _current is a current proposal
     * @return next proposal
     */
    function nextProposal(address _current) constant returns (address)
    { return proposals.next(_current); }

    /**
     * @dev Initial new proposal
     * @param _target is a destination address
     * @param _total is a credits goal
     * @return proposal address
     */
    function init(address _target, uint _total) returns (Proposal) {
        var proposal = new Proposal(_target, _total); 
        proposals.append(proposal);
        NewProposal(proposal);
        return proposal;
    }

    /**
     * @dev Vote for the proposal
     * @param _proposal is an proposal instance
     * @param _value is a count of given shares
     */
    function fund(Proposal _proposal, uint _value) {
        if (_proposal.closed() ||
            shares.getBalance(msg.sender) < _value) throw;

        var available   = shares.totalSupply() - shares.getBalance();
        var share_price = credits.getBalance() / available;
        var overload    = (_proposal.summary() + _value) * share_price
                        - _proposal.total_value();
        if (overload > 0)
            _value -= overload;

        // Transfer shares
        shares.transferFrom(msg.sender, this, _value);

        // Append new funder
        _proposal.append(msg.sender, _value, share_price);

        // Is proposal done?
        if (_proposal.closed()) {
            if (!credits.transfer(_proposal.target(), _proposal.total_value()))
                throw;
            else
                CloseProposal(_proposal);
        }
    }

    /**
     * @dev Decrease self share value from opened target
     * @param _proposal is a proposal instance 
     * @param _value is how amount shares will be refunded
     * @notice target proposal should be open
     */
    function refund(Proposal _proposal, uint _value) {
        // Check for closed
        if (!_proposal.closed()) {
            var refund_value = _proposal.remove(msg.sender, _value);
            shares.transfer(msg.sender, refund_value);
        }
    }
 
    /**
     * @dev Request for release shares by sending
     * @param _proposal is a proposal instance
     * @param _value is a value of returned credits
     */
    function fundback(Proposal _proposal, uint _value) {
        if (credits.transferFrom(msg.sender, this, _value)) {
            var released_shares = _proposal.fundback(msg.sender, _value);
            shares.transfer(msg.sender, released_shares);
        }
    }
}
