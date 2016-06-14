import 'cashflow/CashFlow.sol';
import 'cashflow/Proposal.sol';

contract Builder is Owned {
    uint public buildingCost;
    Proposal proposal;
    CashFlow cashflow;
    mapping (address => address) public lastContractOf;
    
    event Builded(address indexed sender, address indexed instance);
    
    function Builder(uint _buildingCost, address _cashflow, address _proposal) {
        buildingCost = _buildingCost;
        proposal = Proposal(_proposal);
        cashflow = CashFlow(_cashflow);
    }
    
    function getLastContract() constant returns (address) {
        return lastContractOf[msg.sender];
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
        if (msg.value < buildingCost) throw;
        
        lastContractOf[msg.sender] = _contract;
        Builded(msg.sender, _contract);
        
        msg.sender.send(msg.value - buildingCost);
        cashflow.credits().send(buildingCost);
        cashflow.credits().approve(cashflow, buildingCost);
        cashflow.fundback(proposal, buildingCost);
    }
}
