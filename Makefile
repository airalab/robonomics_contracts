all: doc/Core-API.md doc/Market-API.md doc/Thesaurus-API.md

doc/Core-API.md: core.sol 
	solc --fulldoc $^ | docsol.py > $@

doc/Market-API.md: market_regulator.sol 
	solc --fulldoc $^ | docsol.py > $@

doc/Thesaurus-API.md: thesaurus_poll.sol
	solc --fulldoc $^ | docsol.py > $@
