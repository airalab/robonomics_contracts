import 'token/Token.sol';

contract IPO {
    /* The IPO public token */
    Token public invest;

    /* The IPO shares token */
    Token public shares;

    /* This field has `true` when IPO is closed */
    bool public closed = false;

    function IPO(Token _invest, uint _shares) {
        invest = _invest;
        shares = new Token("IPO shares", "S");
        shares.emission(_shares);
    }

    function sign(uint _value);
}
