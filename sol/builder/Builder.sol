import 'cashflow/CashFlow.sol';
import 'cashflow/Proposal.sol';
import 'token/TokenEther.sol';

contract Builder is Owned {
    Proposal proposal;
    CashFlow cashflow;

    uint public buildingCost;
    mapping(address => address[]) public getContractsOf;
    
    event Builded(address indexed sender, address indexed instance);
    
    function Builder(uint _buildingCost, address _cashflow, address _proposal) {
        buildingCost = _buildingCost;
        proposal = Proposal(_proposal);
        cashflow = CashFlow(_cashflow);
    }
    
    function getLastContract() constant returns (address) {
        return getContractsOf[msg.sender][getContractsOf[msg.sender].length - 1];
    }
    
    function setCashflow(address _cashflow) onlyOwner {
        cashflow = CashFlow(_cashflow);
    }
    
    function setProposal(address _proposal) onlyOwner {
        proposal = Proposal(_proposal);
    }
    
    function setCost(uint _buildingCost) onlyOwner {
        buildingCost = _buildingCost;
    }
    
    function deal(address _contract) internal {
        if (msg.value < buildingCost)                   throw;
        if (!msg.sender.send(msg.value - buildingCost)) throw;
        
        TokenEther(cashflow.credits()).refill.value(buildingCost)();
        cashflow.credits().approve(cashflow, buildingCost);
        cashflow.fundback(proposal, buildingCost);
        getContractsOf[msg.sender].push(_contract);
        Builded(msg.sender, _contract);
    }
}
