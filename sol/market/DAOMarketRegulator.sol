import 'market/MarketRegulator.sol';
import 'market/MarketRule.sol';
import 'lib/Voting.sol';
import 'dao/Core.sol';
import 'creator/CreatorDAOMarketAgent.sol';

/**
 * @title The DAO market regulator is a market regulator with voting procedure
 */
contract DAOMarketRegulator is MarketRegulator {
    /* The DAO shares token */
    Token public shares;

    /* The DAO Core register */
    Core public dao_core;

    /* The rule poll by asset address */
    mapping(address => Voting.Poll) ruleOf;
    using Voting for Voting.Poll;

    /**
     * @dev Rule by asset getter
     * @param _asset is asset address
     * @return rule address or `0x` when no rule setted
     */
    function currentRuleOf(address _asset) constant returns (address)
    { return ruleOf[_asset].current(); }
    
    /**
     * @dev DAO Market regulator
     * @param _shares is a share holders token for voting actions
     * @param _core is a DAO core ref for asset exist checks
     * @param _market is a DAO market address
     * @param _dao_credits is a common traded asset
     */
    function DAOMarketRegulator(address _shares, address _core,
                                address _market, address _dao_credits)
            MarketRegulator(_market, _dao_credits) {
        shares   = Token(_shares);
        dao_core = Core(_core);
    }

    event NewLot(address indexed sender, address indexed lot);

    /**
     * @dev Append new lot into the market for sale
     * @param _sale the token to sale by this lot
     * @param _quantity amount of tokens to sale;
     * @param _price price of one in credits 
     * @return new lot address
     */
    function sale(Token _sale, uint _quantity, uint _price) returns (Lot) {
        if (!dao_core.contains(_sale)) throw;

        var lot = market.append(msg.sender, _sale, credits, _quantity, _quantity * _price);
        NewLot(msg.sender, lot);
        return lot;
    }
 
    /**
     * @dev Append new lot into the market for buy
     * @param _buy the token to buy by this lot
     * @param _quantity amount of tokens to sale;
     * @param _price price of one in credits 
     * @return new lot address
     */
    function buy(Token _buy, uint _quantity, uint _price) returns (Lot) {
        if (!dao_core.contains(_buy)) throw;

        var lot = market.append(msg.sender, credits, _buy, _quantity * _price, _quantity);
        NewLot(msg.sender, lot);
        return lot;
    }

    /**
     * @dev Sign a contract with sender for trading on market
     * @return `MarketAgent` instance
     */
    function sign() returns (MarketAgent) {
        // Make a new market agent
        var agent = CreatorDAOMarketAgent.create(this);

        // Store agent address for the future usage
        agents.append(agent);

        // Delegate agent to sender
        agent.delegate(msg.sender);

        // Notify client for the new agent
        MarketAgentSign(msg.sender, agent);

        // Return agent address
        return agent;
    }

    /**
     * @dev this event emmitted for every trade based emission
     */
    event Emission(uint _value);

    /**
     * @dev Deal notify callback, market regulation is maked according 
     *      the rules taked from poll stack
     * @param _lot is deal description
     */
    function notifyDeal(Lot _lot) onlyAgents {
        // Select the traded asset
        var asset = _lot.buy() == credits ? _lot.sale() : _lot.buy(); 

        // Select current trade rule for traded asset
        var rule = ruleOf[asset].current();
        if (rule != 0) {
            // Get emission value based on current rule
            var emission = MarketRule(rule).getEmission(_lot); 

            // Make emission and transfer to owner
            credits.emission(emission);
            credits.transfer(owner, emission);

            // Notify for emission value
            Emission(emission);
        }
    }

    /**
     * @dev Increase poll for given asset
     * @param _asset asset for applying the rule
     * @param _rule the rule is maked for given asset
     * @param _count how much shares given for increase
     */
    function pollUp(address _asset, MarketRule _rule, uint _count)
    { ruleOf[_asset].up(msg.sender, _rule, shares, _count); }

    /**
     * @dev Decrease poll for given asset
     * @param _asset asset for applying the rule
     * @param _count count of refunded shares
     */
    function pollDown(address _asset, uint _count)
    { ruleOf[_asset].down(msg.sender, shares, _count); }
}
