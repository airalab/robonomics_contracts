pragma solidity ^0.4.4;
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
        string  name;
        address module;
        string  abi;
        bool    is_constant;
    }

    ModuleParams modParams;
    ModifyType   modType;

    function modify() internal {
        if (modType == ModifyType.SetModule) {
                Core(target).set(modParams.name,
                                 modParams.module,
                                 modParams.abi,
                                 modParams.is_constant);
        } else {
            Core(target).remove(modParams.name);
        }
    }

    /**
     * @dev Set core module
     * @param _name is a module name
     * @param _module is a module address
     * @param _abi is a module interface
     * @param _constant is a flag for set module constant
     */
    function setModule(string _name, address _module,
                       string _abi, bool _constant) onlyOwner {
        modParams = ModuleParams(_name, _module, _abi, _constant);
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
