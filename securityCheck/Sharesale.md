# ShareSale

Исходный код контракта: [Sharesale.sol](sol/cashflow/ShareSale.sol)



```
/**
 * @title Contract for objects that can be morder
 */
contract Mortal is Owned {
    /**
     * @dev Destroy contract and scrub a data
     * @notice Only owner can kill me
     */
    function kill() onlyOwner
    { suicide(owner); }
}

/**
 * @title Contract for direct sale shares for cashflow
 */
contract ShareSale is Mortal {
    // Assigned shares contract
    Token public shares;

    // Ether fund token
    TokenEther public etherFund;

    // Target address for funds
    address public target;

    // Price of one share
    uint public priceWei;

    // Time of sale
    uint public closed = 0;

    /**
     * @dev Set price of one share in Wei
     * @param _price_wei is share price
     */
    function setPrice(uint _price_wei) onlyOwner
    { priceWei = _price_wei; }

    /**
     * @dev Create the contract for given cashflow and start price
     * @param _target is a target of funds
     * @param _etherFund is a ether wallet token
     * @param _shares is a shareholders token contract
     * @param _price_wei is a price of one share
     * @notice After creation you should send shares to contract for sale
     */
    function ShareSale(address _target, address _etherFund,
                       address _shares, uint _price_wei) {
        target    = _target;
        etherFund = TokenEther(_etherFund);
        shares    = Token(_shares);
        priceWei  = _price_wei;
    }

    /**
     * @dev This fallback method receive ethers and exchange available shares
     *      by price, setted by owner.
     * @notice only full packet of shares can be saled
     */
    function () {
        var value = shares.getBalance() * priceWei;
        // при невозможности вызвать метод будетвозвращен 0, что приведет к занчению value=0

        if (  closed > 0
           || msg.value < value
           || !msg.sender.send(msg.value - value)
           ) throw;
        // Проверка на присланное значение и на возврат лишних средств

        etherFund.refill.value(value)();
        // Перевод на счет контракта TokenEther средств
        // (!) потенциально уязвима к Call Depth attack
        // однако не может быть осуществлена, так как делее
        // происходит перевод средств. При ненулевом балансе
        // атака может быть выполнена

        if (  !etherFund.transfer(target, value)
           || !shares.transfer(msg.sender, shares.getBalance())
           ) throw;
        // Проверка на перевод стредств

        closed = now;
        // Закрытие сделки
    }

    function kill() onlyOwner {
        // Save the shares
        if (!shares.transfer(owner, shares.getBalance())) throw;

        super.kill();
    }
}
```
