import 'acl/ACLStorage.sol';

library CreatorACLStorage {
    function create() returns (ACLStorage)
    { return new ACLStorage(); }

    function version() constant returns (string)
    { return "v0.4.9 (bc824b75)"; }

    function interface() constant returns (string)
    { return '[{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"group","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":true,"inputs":[{"name":"_group","type":"string"},{"name":"_member","type":"address"}],"name":"isMemberOf","outputs":[{"name":"","type":"bool"}],"type":"function"},{"constant":true,"inputs":[{"name":"_group","type":"string"}],"name":"memberFirst","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_group","type":"string"},{"name":"_member","type":"address"}],"name":"addMember","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_group","type":"string"},{"name":"_member","type":"address"}],"name":"removeMember","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_firstMember","type":"address"}],"name":"createGroup","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_group","type":"string"},{"name":"_current","type":"address"}],"name":"memberNext","outputs":[{"name":"","type":"address"}],"type":"function"}]'; }
}
