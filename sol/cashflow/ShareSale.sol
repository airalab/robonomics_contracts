import './CashFlow.sol';

/**
 * @title Contract for direct sale shares for cashflow 
 */
contract ShareSale is Mortal {
    // Assigned cashflow contract
    CashFlow public cashflow;

    // Price of one share
    uint public priceWei;

    /**
     * @dev Set price of one share in Wei
     * @param _price_wei is share price
     */
    function setPrice(uint _price_wei) onlyOwner
    { priceWei = _price_wei; }
    
    /**
     * @dev Get count of shares on contract balance
     * @return shares on balance
     */
    function available() returns (uint)
    { return cashflow.shares().getBalance(); }

    /**
     * @dev Create the contract for given cashflow and start price
     * @param _cashflow is a `CashFlow` contract 
     * @param _price_wei is a price of one share
     * @notice After creation you should send shares to contract for sale
     */
    function ShareSale(address _cashflow, uint _price_wei) {
        cashflow = CashFlow(_cashflow);
        priceWei = _price_wei;
    }

    /**
     * @dev This fallback method receive ethers and exchange available shares 
     *      by price, setted by owner.
     * @notice only full packet of shares can be saled
     */
    function () {
        var value = available() * priceWei; 

        if (   msg.value < value
           || !msg.sender.send(msg.value - value)
           || !cashflow.send(value)
           || !cashflow.shares().transfer(msg.sender, available())
           ) throw;
    }
}
