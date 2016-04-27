import 'agent_storage.sol';
import 'spec_token.sol';
import 'voting.sol';
import 'market.sol';

/**
 * @title The market rule interface 
 */
contract MarketRule {
    /**
     * @dev How amount of token emission needed when given lot is deal
     * @param _deal lot address
     * @return count of emission token value
     */
    function getEmission(Lot _deal) returns (uint);
}

/**
 * @title The market agent interface,
 *        market agent is contract presents a person on the market
 */
contract MarketAgent is Mortal {
    /**
     * @dev Place lot on the market
     * @param _name traded item term name
     * @param _token traded token
     * @param _value how much items traded
     * @param _price one item price
     * @return placed lot address for tracking
     */
    function put(string _name, SpecToken _token,
                 uint _value,  uint _price) onlyOwner returns (Lot);

    /**
     * @dev Get market lot with traded item name
     * @param _index lot position
     * @return traded item description, lot address
     */
    function get(uint _index) constant returns (Knowledge, Lot);

    /**
     * @dev Take a deal by given lot
     * @param _lot target lot address
     * @return `true` when deal is ok
     */
    function deal(Lot _lot) onlyOwner returns (bool);
}

/**
 * @title Market regulator abstract contract,
 *        this contract creates market and `credits` token
 *        for market trade
 */
contract MarketRegulator is Mortal {
    /* The self market */
    Market public market;

    /* The self credits */
    Token  public credits;

    /* The self created market agents */
    address[] public agents;
    using AddressArray for address[];

    /* Only market agents can call modified functions */
    modifier onlyAgents { if (agents.indexOf(msg.sender) < agents.length) _ }

    function MarketRegulator() {
        market  = new Market();
        credits = new Token("Credits", "C");
    }

    /**
     * @dev Sign a contract with sender for trading on market
     * @return `MarketAgent` instance
     */
    function sign() returns (MarketAgent);

    /**
     * @dev Deal done callback, this called by market agent 
     *      after call deal of `Lot`
     * @param _lot is deal description
     */
    function dealDone(Lot _lot) onlyAgents;
}

/**
 * @title The DAO market regulator is a market regulator with voting procedure
 */
contract DAOMarketRegulator is MarketRegulator {
    /* The DAO shares token */
    Token public shares;

    /* The DAO thesaurus */
    HumanAgentStorage public thesaurus;

    /* The rule poll by asset address */
    mapping(address => Voting.Poll) ruleOf;
    using Voting for Voting.Poll;
    
    function MarketRegulator(Token _shares, HumanAgentStorage _thesaurus) {
        shares    = _shares;
        thesaurus = _thesaurus;
    }

    /**
     * @dev Sign a contract with sender for trading on market
     * @return `MarketAgent` instance
     */
    function sign() returns (MarketAgent) {
        // Make a new market agent
        var agent = new DAOMarketAgent(thesaurus);
        // Store agent address for the future usage
        agents.push(agent);
        // Delegate agent to sender
        agent.delegate(msg.sender);
        // Return agent address
        return agent;
    }

    /**
     * @dev Deal done callback, market regulation is maked according 
     *      the rules taked from poll stack
     * @param _lot is deal description
     */
    function dealDone(Lot _lot) onlyAgents {
        var assetToken = _lot.buy() == credits ? _lot.sale() : _lot.buy(); 
        var asset = SpecToken(assetToken).specification();
        var rule = ruleOf[asset].current;
        if (rule != 0) {
            var emission = MarketRule(rule).getEmission(_lot); 
            credits.emission(emission);
            credits.transfer(owner, emission);
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

contract DAOMarketAgent is MarketAgent {
    MarketRegulator   regulator;
    HumanAgentStorage thesaurus; 

    function DAOMarketAgent(HumanAgentStorage _thesaurus) {
        regulator = MarketRegulator(msg.sender);
        thesaurus = _thesaurus;
    }

    /**
     * @dev Place lot on the market
     * @param _name traded item term name
     * @param _token traded token
     * @param _value how much items traded
     * @param _price one item price
     * @return placed lot address for tracking
     */
    function put(string _name, SpecToken _token,
                 uint _value,  uint _price) onlyOwner returns (Lot) {
        // Check knowledge consistence
        var spec = thesaurus.getKnowledgeByName(_name);
        if (!spec.isEqual(_token.specification()))
            throw;

        // Transfer traded token to self
        if (!_token.transferFrom(msg.sender, this, _value))
            throw;

        // Approve credits that will be given from deal
        regulator.credits().approve(msg.sender, _value * _price);

        // Make lot and place on market
        var lot = new Lot(_token, regulator.credits(), _value, _price);
        regulator.market().append(lot);

        // Approve lot in traded token for deal
        _token.approve(lot, _value);
        return lot;
    }

    /**
     * @dev Get market lot with traded item specification
     * @param _index lot position
     * @return traded item description, lot address
     */
    function get(uint _index) constant returns (Knowledge, Lot) {
        if (_index >= regulator.market().size()) throw;

        var lot = Lot(regulator.market().lots(_index));
        var saleToken = SpecToken(lot.sale());
        var saleSpec = saleToken.specification();

        for (uint i = 0; i < thesaurus.knowledgesLength(); i += 1) {
            var knowledge = thesaurus.getKnowledge(i);
            if (knowledge.isEqual(saleSpec))
                return (knowledge, lot);
        }
        return (Knowledge(0), lot);
    }

    /**
     * @dev Take a deal by given lot
     * @param _lot target lot address
     * @return `true` when deal is ok
     */
    function deal(Lot _lot) onlyOwner returns (bool) {
        var buyValue = _lot.value() * _lot.price();
        // Check balance of sender for the deal

        // Transfer buy value for the lot
        if (!_lot.buy().transferFrom(msg.sender, this, buyValue))
            return false;
        _lot.buy().approve(_lot, buyValue);

        // Try the deal
        if(!_lot.deal()) {
            // Refund when deal isn't ok
            _lot.buy().transfer(msg.sender, buyValue); 
            return false;
        }

        // Transfer when deal is success
        _lot.sale().transfer(msg.sender, _lot.value());

        // Notify the regulator
        regulator.dealDone(_lot);
        return true;
    }
}
