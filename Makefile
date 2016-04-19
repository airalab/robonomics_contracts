all: doc/Core-API.md doc/Market-API.md

doc/Core-API.md: core.sol 
	solc --fulldoc $^ | docsol.py > $@

doc/Market-API.md: market.sol 
	solc --fulldoc $^ | docsol.py > $@

