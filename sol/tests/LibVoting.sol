import 'common/Mortal.sol';
import 'lib/Voting.sol';

/*
 * @dev lib/Voting functional testing contract
 */
contract LibVoting is Mortal {
    Token public shares;

    Voting.Poll  vpoll;
    using Voting for Voting.Poll;
    using AddressList for AddressList.Data;

    /* Constructor */

    function LibVoting(address _shares)
    { shares = Token(_shares); }

    /* Poll public members */

    function current() constant returns (address)
    { return vpoll.current(); } 

    function up(address _variant, uint _count)
    { vpoll.up(msg.sender, _variant, shares, _count); } 

    function down(uint _count)
    { vpoll.down(msg.sender, shares, _count); }

    /* Poll state getters */

    function votersFirst() constant returns (address)
    { return vpoll.voters.first(); }

    function votersNext(address _current) constant returns (address)
    { return vpoll.voters.next(_current); }

    function variantsFirst() constant returns (address)
    { return vpoll.variants.first(); }

    function variantsNext(address _current) constant returns (address)
    { return vpoll.variants.next(_current); }
    
    function value(address _variant) constant returns (uint)
    { return vpoll.valueOf[_variant]; }

    function share(address _voter) constant returns (uint)
    { return vpoll.shareOf[_voter]; }

    function poll(address _voter) constant returns (address)
    { return vpoll.pollOf[_voter]; }
}
