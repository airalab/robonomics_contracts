import 'market/MarketRegulator.sol';
import 'market/MarketRule.sol';
import 'lib/Voting.sol';
import 'creator/CreatorDAOMarketAgent.sol';

/**
 * @title The DAO market regulator is a market regulator with voting procedure
 */
contract DAOMarketRegulator is MarketRegulator {
    /* The DAO shares token */
    Token shares;

    /* The DAO thesaurus */
    KnowledgeStorage thesaurus;

    /* The rule poll by asset address */
    mapping(address => Voting.Poll) ruleOf;
    using Voting for Voting.Poll;
    
    function DAOMarketRegulator(address _shares, address _thesaurus,
                                address _dao_credits)
            MarketRegulator(_dao_credits) {
        shares    = Token(_shares);
        thesaurus = KnowledgeStorage(_thesaurus);
    }

    /**
     * @dev Sign a contract with sender for trading on market
     * @return `MarketAgent` instance
     */
    function sign() returns (MarketAgent) {
        // Make a new market agent
        var agent = CreatorDAOMarketAgent.create(thesaurus, this);

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
    event DealDoneEmission(uint _value);

    /**
     * @dev Deal done callback, market regulation is maked according 
     *      the rules taked from poll stack
     * @param _lot is deal description
     */
    function dealDone(Lot _lot) onlyAgents {
        // Select the traded asset
        var assetToken = _lot.buy() == credits ? _lot.sale() : _lot.buy(); 

        // Get asset specification
        var asset = TokenSpec(assetToken).specification();

        // Select current trade rule for traded asset
        var rule = ruleOf[asset].current();
        if (rule != 0) {
            // Get emission value based on current rule
            var emission = MarketRule(rule).getEmission(_lot); 

            // Make emission and transfer to owner
            credits.emission(emission);
            credits.transfer(owner, emission);

            // Notify for emission value
            DealDoneEmission(emission);
        }
    }

    /**
     * @dev Increase poll for given asset
     * @param _asset asset for applying the rule
     * @param _rule the rule is maked for given asset
     * @param _count how much shares given for increase
     */
    function pollUp(Knowledge _asset, MarketRule _rule, uint _count)
    { ruleOf[_asset].up(msg.sender, _rule, shares, _count); }

    /**
     * @dev Decrease poll for given asset
     * @param _asset asset for applying the rule
     * @param _count count of refunded shares
     */
    function pollDown(Knowledge _asset, uint _count)
    { ruleOf[_asset].down(msg.sender, shares, _count); }
}
