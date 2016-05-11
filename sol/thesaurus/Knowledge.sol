import 'common/Owned.sol';

/**
 * Knowledge is a generic declaration of object or process
 */
contract Knowledge is Owned {
    /* Knowledge can have a type described below */
    int8 constant OBJECT  = 1;
    int8 constant PROCESS = 2;

    /* Knowledge type is a int value */
    int public knowledgeType;

    function Knowledge(int8 _type)
    { knowledgeType = _type; }

    /**
     * Generic Knowledge comparation procedure
     * @param _to compared knowledge address
     * @return `true` when knowledges is equal
     */
    function isEqual(Knowledge _to) constant returns (bool);
}
