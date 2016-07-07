all:
	npm install

docs:
	docsol -I sol > doc/API-Reference.md
