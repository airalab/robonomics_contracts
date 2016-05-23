import 'thesaurus/KObject.sol';

library FactoryKObject {
    function create() returns (KObject)
    { return new KObject(); }
}
