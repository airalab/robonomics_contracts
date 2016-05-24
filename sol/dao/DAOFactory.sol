import 'factory/FactoryDAOKnowledgeStorage.sol';
import 'factory/FactoryDAOMarketRegulator.sol';
import 'factory/FactoryKnowledgeStorage.sol';
import 'factory/FactoryTokenSpec.sol';
import 'factory/FactoryCashFlow.sol';
import 'factory/FactoryKObject.sol';
import 'factory/FactoryMarket.sol';
import 'factory/FactoryToken.sol';
import 'factory/FactoryCore.sol';

/* DAO build configuration */
contract DAOBuildConfig {
    function DAOBuildConfig(string _dao_name, string _dao_description, int _modules,
                            string _shares_name, string _shares_symbol,
                            string _credits_name, string _credits_symbol) {
        /* Core */
        name        = _dao_name;
        description = _dao_description;

        /* Shares */
        shares        = _modules & 1 > 0;
        shares_name   = _shares_name;
        shares_symbol = _shares_symbol;

        /* Credits */
        credits       = _modules & 2 > 0;
        credits_name  = _credits_name;
        credits_symbol= _credits_symbol;

        /* Cashflow */
        cashflow = _modules & 4 > 0;

        /* Thesaurus */
        thesaurus_simple   = _modules & 8 > 0;
        thesaurus_advanced = _modules & 16 > 0;
        
        /* Market */
        market_simple   = _modules & 32 > 0;
        market_advanced = _modules & 64 > 0;
    }

    /* Core fields */
    string public name;
    string public description;

    /* Shares support */
    bool   public shares;
    string public shares_name;
    string public shares_symbol;

    /* Credits support */
    bool   public credits;
    string public credits_name;
    string public credits_symbol;
    
    /* Cashflow support */
    bool   public cashflow;

    /* Thesaurus support */
    bool   public thesaurus_simple;
    bool   public thesaurus_advanced;

    function thesaurus() constant returns (bool)
    { return thesaurus_simple || thesaurus_advanced; }

    /* Market support */
    bool   public market_simple;
    bool   public market_advanced;

    function market() constant returns (bool)
    { return market_simple || market_advanced; }
    
    /* Service fields */
    string public version = "DAOFactory_v0.1";
}

contract DAOFactory is Mortal {
    /* This event emitted on complete DAO build */
    event BuildSuccess(address indexed sender,
                       address indexed config,
                       address indexed dao);

    /* This event emitted on any error */
    event BuildError(address indexed sender,
                     string description);

    function module_mask(bool _has_shares,
                         bool _has_credits,
                         bool _has_cashflow,
                         bool _has_thesaurus_simple,
                         bool _has_thesaurus_advanced,
                         bool _has_market_simple,
                         bool _has_market_advanced) constant returns (int) {
        int mask = 1;
        if (_has_shares)                mask |= 1;
        if (_has_credits)               mask |= 2; 
        if (_has_cashflow)              mask |= 4; 
        if (_has_thesaurus_simple)      mask |= 8; 
        if (_has_thesaurus_advanced)    mask |= 16; 
        if (_has_market_simple)         mask |= 32; 
        if (_has_market_advanced)       mask |= 64; 
        return mask;
    }

    function create(string _dao_name, string _dao_description, int _modules,
                    string _shares_name, string _shares_symbol,
                    string _credits_name, string _credits_symbol) returns (address) {
        /* Create config */
        var cfg = new DAOBuildConfig(_dao_name, _dao_description, _modules,
                                     _shares_name, _shares_symbol,
                                     _credits_name, _credits_symbol);
        
        // Create core 
        var dao = FactoryCore.create(_dao_name, _dao_description);

        // Set config 
        dao.setModule("config", cfg, "github://airalab/core/dao/DAOFactory.sol");

        // Thesaurus simple 
        if (cfg.thesaurus())
            dao.setModule("thesaurus", FactoryKnowledgeStorage.create(),
                          "github://airalab/core/thesaurus/KnowledgeStorage.sol");

        // Shares 
        if (cfg.shares()) {
            if (cfg.thesaurus()) {
                // Make shares knowledge
                var shares_knowledge = FactoryKObject.create();
                shares_knowledge.insertProperty("name",   _shares_name);
                shares_knowledge.insertProperty("symbol", _shares_symbol);
                KnowledgeStorage(dao.getModule("thesaurus")).set("shares", shares_knowledge);
                shares_knowledge.delegate(dao.getModule("thesaurus"));
 
                // Create DAO shares with spec
                dao.setModule("shares",
                              FactoryTokenSpec.create(_shares_name, _shares_symbol,
                                                      shares_knowledge),
                              "github://airalab/core/token/TokenSpec.sol");
            } else {
                // Create simple DAO shares
                dao.setModule("shares",
                              FactoryToken.create(_shares_name, _shares_symbol),
                              "github://airalab/core/token/Token.sol");
            }
            // Delegate shares to client
            Owned(dao.getModule("shares")).delegate(msg.sender);
        }

        // Thesaurus advanced 
        if (cfg.thesaurus_advanced()) {
            if (!cfg.shares()) {
                BuildError(msg.sender, "Config: `shares` should be enabled for `thesaurus_advanced` option");
                return 0;
            } else {
                dao.setModule("dao_thesaurus",
                              FactoryDAOKnowledgeStorage.create(dao.getModule("thesaurus"),
                                                                dao.getModule("shares")),
                              "github://airalab/core/sol/dao/DAOKnowledgeStorage.sol");
                Owned(dao.getModule("thesaurus")).delegate(dao.getModule("dao_thesaurus"));
                Owned(dao.getModule("dao_thesaurus")).delegate(msg.sender);
            }
        }
 
        // Credits
        if (cfg.credits()) {
            if (cfg.thesaurus()) {
                // Make shares knowledge
                var credits_knowledge = FactoryKObject.create();
                credits_knowledge.insertProperty("name",   _credits_name);
                credits_knowledge.insertProperty("symbol", _credits_symbol);
                KnowledgeStorage(dao.getModule("thesaurus")).set("credits", credits_knowledge);
                credits_knowledge.delegate(dao.getModule("thesaurus"));
 
                // Create DAO shares with spec
                dao.setModule("credits",
                              FactoryTokenSpec.create(_credits_name, _credits_symbol,
                                                      credits_knowledge),
                              "github://airalab/core/token/TokenSpec.sol");
            } else {
                // Create simple DAO shares
                dao.setModule("credits",
                              FactoryToken.create(_credits_name, _credits_symbol),
                              "github://airalab/core/token/Token.sol");
            }
            // Delegate shares to client
            Owned(dao.getModule("credits")).delegate(msg.sender);
        }

        // Market
        if (cfg.market()) {
            if (cfg.market_advanced()) {
                if (!cfg.shares() || !cfg.credits() || !cfg.thesaurus()) {
                    BuildError(msg.sender, 'Config: `shares`, `credits` and `thesaurus` should be enabled for `market_advanced` option');
                    return 0;
                }
                dao.setModule("market",
                              FactoryDAOMarketRegulator.create(dao.getModule("shares"),
                                                               dao.getModule("thesaurus"),
                                                               dao.getModule("credits")), 
                              "github://airalab/core/sol/market/DAOMarketRegulator.sol");
            } else {
                dao.setModule("market", FactoryMarket.create(),
                              "github://airalab/core/sol/market/Market.sol");
            }
            Owned(dao.getModule("market")).delegate(msg.sender);
        }

        // Cashflow 
        if (cfg.cashflow()) {
            if (!cfg.credits() || !cfg.shares()) {
                    BuildError(msg.sender, 'Config: `shares` and `credits` enabled for `cashflow` option');
                    return 0;
            }
            dao.setModule("cashflow",
                          FactoryCashFlow.create(dao.getModule("credits"),
                                                 dao.getModule("shares")),
                          "github://airalab/core/sol/cashflow/CashFlow.sol");
            Owned(dao.getModule("cashflow")).delegate(msg.sender);
        }

        // Delegate DAO to sender
        dao.delegate(msg.sender);
        BuildSuccess(msg.sender, cfg, dao);
        return dao;
    }
}
