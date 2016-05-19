import 'dao/Core.sol';

library FabricCore {
    function create(string _name, string _description) returns (Core)
    { return new Core(_name, _description); }
}
