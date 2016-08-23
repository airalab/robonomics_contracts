import 'lib/AddressList.sol';
import 'common/Mortal.sol';

contract LibAddressList is Mortal {
    AddressList.Data list;
    using AddressList for AddressList.Data;

    uint public m = 42;

    function first() constant returns (address)
    { return list.first(); }

    function last() constant returns (address)
    { return list.last(); }

    function contains(address _item) constant returns (bool)
    { return list.contains(_item); }

    function next(address _item) constant returns (address)
    { return list.next(_item); }

    function prev(address _item) constant returns (address)
    { return list.prev(_item); }

    function append(address _item)
    { list.append(_item); }

    function appendTo(address _item, address _to)
    { list.append(_item, _to); }
 
    function prepend(address _item)
    { list.prepend(_item); }

    function prependTo(address _item, address _to)
    { list.prepend(_item, _to); }
 
    function remove(address _item)
    { list.remove(_item); }

    function replace(address _from, address _to)
    { list.replace(_from, _to); }

    function swap(address _a, address _b)
    { list.swap(_a, _b); }
}
