all:
	npm install

docs: doc/Core-API.md doc/Market-API.md doc/Thesaurus-API.md

doc/Core-API.md: sol/dao/Core.sol 
	solc --fulldoc $^ | docsol.py > $@

doc/Market-API.md: sol/dao/DAOMarketRegulator.sol 
	solc --fulldoc $^ | docsol.py > $@

doc/Thesaurus-API.md: sol/dao/DAOKnowledgeStorage.sol
	solc --fulldoc $^ | docsol.py > $@
