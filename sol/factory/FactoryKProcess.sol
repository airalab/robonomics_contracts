import 'thesaurus/KProcess.sol';

library FactoryKProcess {
    function create() returns (KProcess)
    { return new KProcess(); }
}
