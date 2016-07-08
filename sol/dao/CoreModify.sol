import 'common/Modify.sol';
import './Core.sol';

/**
 * @title DAO Core modificator
 * @dev   It's contract can modify core by set/remove modules
 */
contract CoreModify is Modify {
    function CoreModify(address _target) Modify(Owned(_target)) {}

    enum ModifyType {
        SetModule,
        RemoveModule
    }

    struct ModuleParams {
        string name;
        address module;
        string interface;
        bool isConstant;
    }

    ModuleParams modParams;
    ModifyType   modType;

    function modify() internal {
        if (modType == ModifyType.SetModule) {
                Core(target).setModule(modParams.name,
                                       modParams.module,
                                       modParams.interface,
                                       modParams.isConstant);
        } else {
            Core(target).removeModule(modParams.name);
        }
    }

    /**
     * @dev Set core module
     * @param _name is a module name
     * @param _module is a module address
     * @param _interface is a module interface
     * @param _constant is a flag for set module constant
     */
    function setModule(string _name, address _module,
                       string _interface, bool _constant) onlyOwner {
        modParams = ModuleParams(_name, _module, _interface, _constant);
        modType   = ModifyType.SetModule;
    }

    /**
     * @dev Remove module from core register
     * @param _name is a module name
     */
    function removeModule(string _name) onlyOwner {
        modParams.name = _name;
        modType        = ModifyType.RemoveModule;
    }
}
