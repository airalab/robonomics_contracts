import 'lib/AddressList.sol';
import 'token/TokenEmission.sol';
import './MarketAgent.sol';
import './Market.sol';

/**
 * @title Market regulator abstract contract,
 *        this contract creates market and `credits` token
 *        for market trade
 */
contract MarketRegulator is Mortal {
    /* The self market */
    Market public market;

    /* The self credits */
    TokenEmission public credits;

    /* The self created market agents */
    AddressList.Data agents;
    using AddressList for AddressList.Data;

    /* Only market agents can call modified functions */
    modifier onlyAgents { if (agents.contains(msg.sender)) _ }

    function MarketRegulator(address _credits) {
        market  = new Market();
        credits = TokenEmission(_credits);
    }

    /**
     * @dev this event emitted for every new MarketAgent
     * @param _client is a client address
     * @param _agent is an agent address
     */
    event MarketAgentSign(address indexed _client, address indexed _agent);

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
