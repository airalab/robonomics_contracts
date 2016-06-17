import 'cashflow/CashFlow.sol';
import 'cashflow/Proposal.sol';
import 'token/TokenEther.sol';

/**
 * @title Builder based contract
 */
contract Builder is Owned {
    /* Proposal */
    Proposal proposal;
    /* The DAO cashflow */
    CashFlow cashflow;

    /* Building cost  */
    uint public buildingCost;
    /* Addresses builded contracts at sender */
    mapping(address => address[]) public getContractsOf;
    
    /**
     * @dev this event emitted for every builded contract
     */
    event Builded(address indexed sender, address indexed instance);
    
    /**
     * @dev Builder constructor
     * @param _buildingCost is module name
     * @param _cashflow is address cashflow
     * @param _proposal is address proposal
     */
    function Builder(uint _buildingCost, address _cashflow, address _proposal) {
        buildingCost = _buildingCost;
        proposal = Proposal(_proposal);
        cashflow = CashFlow(_cashflow);
    }
    
    /**
     * @dev Get last address
     * @return last address contract
     */
    function getLastContract() constant returns (address) {
        return getContractsOf[msg.sender][getContractsOf[msg.sender].length - 1];
    }
    
    /**
     * @dev Set cashflow
     * @param _cashflow is address cashflow
     */
    function setCashflow(address _cashflow) onlyOwner {
        cashflow = CashFlow(_cashflow);
    }
    
    /**
     * @dev Set proposal
     * @param _proposal is address proposal
     */
    function setProposal(address _proposal) onlyOwner {
        proposal = Proposal(_proposal);
    }
    
    /**
     * @dev Set building cost
     * @param _buildingCost is cost
     */
    function setCost(uint _buildingCost) onlyOwner {
        buildingCost = _buildingCost;
    }
    
    /**
     * @dev Payment for builded contract and a request for release of shares
     * @param _contract is address contract
     * @notice Called after builded contract
     */
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
