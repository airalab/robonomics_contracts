import 'thesaurus/KnowledgeStorage.sol';

library CreatorKnowledgeStorage {
    event Created(address indexed sender, address indexed instance);

    function create() returns (KnowledgeStorage) {
        var inst = new KnowledgeStorage();
        Created(msg.sender, inst);
        return inst;
    }

    function version() constant returns (string)
    { return "v0.4.0 (075857)"; }

    function abi() constant returns (string)
    { return '[{"constant":true,"inputs":[],"name":"first","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_knowledge","type":"address"}],"name":"getName","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":true,"inputs":[{"name":"_name","type":"string"}],"name":"get","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_knowledge","type":"address"}],"name":"set","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_current","type":"address"}],"name":"next","outputs":[{"name":"","type":"address"}],"type":"function"}]'; }
}
