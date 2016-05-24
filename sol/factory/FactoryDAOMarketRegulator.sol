import 'market/DAOMarketRegulator.sol';

library FactoryDAOMarketRegulator {
    function create(address _shares, address _thesaurus, address _dao_credits) returns (DAOMarketRegulator)
    { return new DAOMarketRegulator(_shares, _thesaurus, _dao_credits); }
}
