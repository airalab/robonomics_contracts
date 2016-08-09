import 'cashflow/CashFlow.sol';
import 'cashflow/Proposal.sol';
import 'token/TokenEther.sol';
import './BuilderBase.sol';

/**
 * @title Builder based contract
 */
contract Builder is BuilderBase {
    /* Proposal */
    Proposal proposal;

    /* The DAO cashflow */
    CashFlow cashflow;

    /* Building cost  */
    uint public buildingCostWei;

    /**
     * @dev Builder constructor
     * @param _buildingCostWei is module name
     * @param _cashflow is address cashflow
     * @param _proposal is address proposal
     */
    function Builder(uint _buildingCostWei, address _cashflow, address _proposal) {
        buildingCostWei = _buildingCostWei;
        proposal = Proposal(_proposal);
        cashflow = CashFlow(_cashflow);
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
     * @param _buildingCostWei is cost
     */
    function setCost(uint _buildingCostWei) onlyOwner {
        buildingCostWei = _buildingCostWei;
    }
    
    /**
     * @dev Payment for builded contract and a request for release of shares
     * @param _contract is address contract
     * @notice Called after builded contract
     */
    function deal(address _contract) internal {
        if (msg.value < buildingCostWei)                   throw;
        if (!msg.sender.send(msg.value - buildingCostWei)) throw;
        
        TokenEther(cashflow.credits()).refill.value(buildingCostWei)();
        cashflow.credits().approve(cashflow, buildingCostWei);
        cashflow.fundback(proposal, buildingCostWei);
        getContractsOf[msg.sender].push(_contract);
        Builded(msg.sender, _contract);
    }
}
