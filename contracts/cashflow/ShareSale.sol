pragma solidity ^0.4.4;
import 'common/Object.sol';
import 'token/TokenEther.sol';

/**
 * @title Contract for direct sale shares for cashflow 
 */
contract ShareSale is Object {
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
    function () payable {
        var value = shares.balanceOf(this) * priceWei;

        if (  closed > 0 
           || msg.value < value
           || !msg.sender.send(msg.value - value)) throw;

        etherFund.refill.value(value)();

        if (  !etherFund.transfer(target, value)
           || !shares.transfer(msg.sender, shares.balanceOf(this))
           ) throw;

        closed = now;
    }

    function destroy() onlyHammer {
        // Save the shares
        if (!shares.transfer(owner, shares.balanceOf(this))) throw;

        super.destroy();
    }
}
