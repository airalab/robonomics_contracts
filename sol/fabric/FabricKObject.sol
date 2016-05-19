import 'thesaurus/KObject.sol';

library FabricKObject {
    function create() returns (KObject)
    { return new KObject(); }
}
