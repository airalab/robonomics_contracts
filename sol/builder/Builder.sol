pragma solidity ^0.4.2;
import 'cashflow/CashFlow.sol';
import 'cashflow/Proposal.sol';
import 'token/TokenEther.sol';
import './BuilderBase.sol';

/**
 * @title Builder based contract
 */
contract Builder is BuilderBase {
    /* Building beneficiary */
    address public beneficiary;

    /**
     * @dev Set beneficiary
     * @param _beneficiary is address of beneficiary
     */
    function setBeneficiary(address _beneficiary) onlyOwner
    { beneficiary = _beneficiary; }

    /* Building cost  */
    uint public buildingCostWei;

    /**
     * @dev Set building cost
     * @param _buildingCostWei is cost
     */
    function setCost(uint _buildingCostWei) onlyOwner
    { buildingCostWei = _buildingCostWei; }

    /* Security check report */
    string public securityCheckURI;

    /**
     * @dev Set security check report URI
     * @param _uri is an URI to report
     */
    function setSecurityCheck(string _uri) onlyOwner
    { securityCheckURI = _uri; }
 
    /**
     * @dev Payment for builded contract and a request for release of shares
     * @param _contract is address contract
     * @notice Called after builded contract
     */
    function deal(address _contract) internal {
        Builded(msg.sender, _contract);
        getContractsOf[msg.sender].push(_contract);

        if (buildingCostWei > 0 && beneficiary != 0) {
            if (   msg.value < buildingCostWei
               || !msg.sender.send(msg.value - buildingCostWei)
               || !beneficiary.send(buildingCostWei)
               ) throw;
        }
    }
}
