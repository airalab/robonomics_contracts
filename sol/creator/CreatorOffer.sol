import 'dao/Offer.sol';

library CreatorOffer {
    function create(string _description, address _token, uint256 _value, address _beneficiary, address _hard_offer) returns (Offer)
    { return new Offer(_description, _token, _value, _beneficiary, _hard_offer); }

    function version() constant returns (string)
    { return "v0.4.9 (b0c9353b)"; }

    function interface() constant returns (string)
    { return '[{"constant":false,"inputs":[],"name":"accept","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"beneficiary","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"value","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":false,"inputs":[],"name":"close","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"closed","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"description","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"hardOffer","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"token","outputs":[{"name":"","type":"address"}],"type":"function"},{"inputs":[{"name":"_description","type":"string"},{"name":"_token","type":"address"},{"name":"_value","type":"uint256"},{"name":"_beneficiary","type":"address"},{"name":"_hard_offer","type":"address"}],"type":"constructor"}]'; }
}
