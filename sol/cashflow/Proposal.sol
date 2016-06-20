import 'common/Owned.sol';
import 'lib/AddressList.sol';

contract Proposal is Owned {
    // Constructor
    function Proposal(address _destination, uint _targetValue, string _description) {
        destination = _destination;
        description = _description;
        targetValue = _targetValue;
    }

    // Proposal destination address
    address public destination;
    
    // Proposal description
    string public description;

    // Proposal value in credits
    uint public targetValue;

    // Proposal close time
    uint public closed = 0;

    function close() onlyOwner
    { closed = now; }

    // Current summary shares given
    uint public summaryShares = 0;

    function setSummaryShares(uint _summary) onlyOwner
    { summaryShares = _summary; }

    // Current given shares by funder address
    mapping(address => uint) public sharesOf;

    function setSharesOf(address _funder, uint _shares) onlyOwner
    { sharesOf[_funder] = _shares; }

    // Amount of credits returned
    uint public backValue = 0;

    function setBackValue(uint _backValue) onlyOwner
    { backValue = _backValue; }

    // Current released shares
    mapping(address => uint) public refundSharesOf;

    function setRefunSharesOf(address _funder, uint _shares) onlyOwner
    { refundSharesOf[_funder] = _shares; }
 
    // List of proposal funders
    address[] public funders;

    function appendFunder(address _funder) onlyOwner
    { funders.push(_funder); }

    uint public sharePrice = 0;

    function setSharePrice(uint _sharePrice) onlyOwner
    { sharePrice = _sharePrice; }
}
