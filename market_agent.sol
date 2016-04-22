import 'thesaurus.sol';
import 'spec_token.sol';

contract MarketAgent is Mortal {
	HumanAgentStorage agentStorage; 
	Market public market;
	Token public credits;

	Lot public lot = 0;

	function MarketAgent(HumanAgentStorage _storage, Market _market, Token _credits) {
		agentStorage = _storage;
		market  = _market;
		credits = _credits;
	}

	/**
	 * @dev Place lot on the market
	 * @notice market agent can place only one lot, for more create more agents
	 * @param _name traded item term name
	 * @param _token traded token
	 * @param _value how much items traded
	 * @param _price one item price
	 * @return placed lot address for tracking
	 */
	function placeLot(string _name, SpecToken _token,
					  uint _value,  uint _price) onlyOwner returns (Lot) {
		// Only one lot can be placed
		if (lot != 0) throw;

		// Check knowledge consistence
		var spec = agentStorage.getKnowledgeByName(_name);
		if (!spec.isEqual(_token.specification()))
			return Lot(0);

		// Check traded token balance
		if (_token.getBalance(msg.sender) < _value)
			return Lot(0);

		// Transfer traded token for self and approve credits
		_token.transferFrom(msg.sender, this, _value);
		credits.approve(msg.sender, _value * _price);

		lot = new Lot(_token, credits, _value, _price);
		market.appendLot(lot);

		return lot;
	}

	/**
	 * @dev Take a best deal from market with knowledge term check
	 * @param _name traded item term name
	 * @param _token items for the search
	 * @param _value how much items 
	 */
	function bestDeal(string _name, SpecToken _token, uint _value) constant
			returns (Lot) {
		// Check knowledge consistence
		var spec = agentStorage.getKnowledgeByName(_name);
		if (!spec.isEqual(_token.specification())
			return Lot(0);

		// Search best deal on market
		return market.bestDeal(_token, credits, _value);
	}

	/**
	 * @dev Get market lot with traded item name
	 * @param _index lot position
	 * @return traded item description, lot address
	 */
	function marketGet(uint _index) returns (string, Lot) {
		if (_index >= market.size()) throw;

		var lot = market.lots(_index);
		var saleToken = SpecToken(lot.sale());
		var saleSpec = saleToken.specification();

		for (uint i = 0; i < agentStorage.thesaurusLength(); i += 1) {
			var name = agentStorage.thesaurusGet(i);
			var knowledge = agentStorage.getKnowledgeByName(name);
			if (knowledge.isEqual(saleSpec))
				return (name, lot);
		}
		return ("", lot);
	}
}
