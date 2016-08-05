## Безопасные контракты

Советы:

- Избегайте внешних вызовов когда это возможно, очень часто они являются причиной уязвимости
- Отдавайте приоритет изменению состояния над внешним вызовом вызовом (включая `.send()`)
- Изолируйте внешние вызовы в отдельной транзакции, например, метод `withdraw` для вывода средств
- Будте внимательны при делении целых чисел (округление происходит к ближайшему целому)
- При делении на ноль возвращается **ноль**, проверяйте аргументы самостоятельно
- Будте внимательны к переполнению целых чисел (особенно в сравнениях) и приведению знаковых к беззнаковым в JS
- Будте осторожны с привязкой логики контракта ко времени блока, оно устанавливается майнером
- Подумайте о способе обновления контракта в будующем
- Используйте метки остановки работы контракта в случае чрезвычайной ситуации, например обнаружении уязвимости
- Разделяйте критически важные вызовы во времени, например, вывод большого количества средств не чаще раза в неделю
- Используйте [формальную верификацию](https://gist.github.com/chriseth/c4a53f201cd17fc3dd5f8ddea2aa3ff9) контрактов

## Известные атаки

### Атака по глубине стека

**Идея:** разрешенная глубина стека составляет 1024, вызовы глубже не быдут выполнены, однако транзакция не прервется; атакующий может вызвать код с глубиной стека 1023, в таком случае вызовы из уязвимого кода, например `send()` не будут исполнены.

```
// INSECURE
contract auction {
    mapping(address => uint) refunds;

    // [...]

    function withdrawRefund(address recipient) {
        uint refund = refunds[recipient];
        refunds[recipient] = 0;
        recipient.send(refund); // эта строка исполнится не так, как ожидается
    }
}
```

**Противодействие:** минимизация вызовов внутри методов, приоритет записи и учета над вызовом другого метода; а также `.send()` возвращает `false` если не может быть исполнена, необходимо при каждой отправке средств проверять возвращаемое значение.

### Условия гонки

**Идея:** внешний вызов может произвести неконтролируемые изменения в данных контракта.

```
// INSECURE
mapping (address => uint) private userBalances;

function withdrawBalance() public {
    uint amountToWithdraw = userBalances[msg.sender];
    // в этом месте внешний контракт может вызвать метод withdrawBalance снова
    if (!(msg.sender.call.value(amountToWithdraw)())) { throw; } 
    userBalances[msg.sender] = 0;
}
```

**Противодействие:** для недоверенного кода(`msg.sender`) приоритет в использовании `.send()` над `.call.value()`, так как количество газа для `.send()` очень ограничено и не может быть использовано для эксплуатации уязвимости.

### DoS при вызове исключения

**Идея:** работа контракта может быть заблокирована брокском исключения во внешнем вызываемом коде.

```
// INSECURE
contract Auction {
    address currentLeader;
    uint highestBid;

    function bid() {
        if (msg.value <= highestBid) { throw; }

        // если контракт в fallback вызовет исключение, новый лидер не сможет быть назначен 
        if (!currentLeader.send(highestBid)) { throw; }

        currentLeader = msg.sender;
        highestBid = msg.value;
    }
}
```

**Противодействие:** приоритет логирования и записи во внутренние структуры над непосредственной отправкой, например, введение вызова `withdraw` для доступа к вознаграждению из текущего примера.

### DoS при переполнении лимита газа

**Идея:** объем газа в блоке ограничен, если для транзакции требуется газа больше, чем помещается в блок - она никогда не будет исполнена.

```
struct Payee {
    address addr;
    uint256 value;
}
Payee payees[];
uint256 nextPayeeIndex;

function payOut() {
    uint256 i = 0;
    // при достаточно большом размере payees возможно превысить лимит газа
    while (i < payees.length) {
        payees[i].addr.send(payees[i].value);
        i++;
    }
}
```

**Противодействие:** избегать итерации по большим массивам данных, либо переносить перебор на программную логику вне контракта; если невозможно избавиться от перебора, необходимо разбить его на несколько шагов, либо выполнять действия по запросу, например, добавить метод `withdraw` для вывода средств.

## Разбор

### Token (Aira DAO Core)

```
/**
 * @title The root contract
 * @dev This contract is used as base of all contracts,
 *      e.g. it change default behaviour of fallback function 
 */
contract Object {
    /**
     * @dev Default fallback behaviour will throw sended ethers
     */
    function() { throw; }
}

/**
 * @title Contract for object that have an owner
 */
contract Owned is Object {
    /**
     * Contract owner address
     */
    address public owner;

    /**
     * @dev Store owner on creation
     */
    function Owned() { owner = msg.sender; }

    /**
     * @dev Delegate contract to another person
     * @param _owner is another person address
     */
    function delegate(address _owner) onlyOwner
    { owner = _owner; }

    /**
     * @dev Owner check modifier
     */
    modifier onlyOwner { if (msg.sender != owner) throw; _ }
    // Бросать исключение предпочтительнее для кода, инициирующего вызов
}

/**
 * @title Token contract represents any asset in digital economy
 */
contract Token is Owned {
    event Transfer(address indexed _from,  address indexed _to,      uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /* Short description of token */
    string public name;
    string public symbol;

    /* Total count of tokens exist */
    uint public totalSupply;

    /* Fixed point position */
    uint8 public decimals;
    
    /* Token approvement system */
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
 
    /**
     * @return available balance of `sender` account (self balance)
     */
    function getBalance() constant returns (uint)
    { return balanceOf[msg.sender]; }
 
    /**
     * @dev This method returns non zero result when sender is approved by
     *      argument address and target address have non zero self balance
     * @param _address target address 
     * @return available for `sender` balance of given address
     */
    function getBalance(address _address) constant returns (uint) {
        return allowance[_address][msg.sender]
             > balanceOf[_address] ? balanceOf[_address]
                                   : allowance[_address][msg.sender];
    }
 
    /* Token constructor */
    function Token(string _name, string _symbol, uint8 _decimals, uint _count) {
        name     = _name;
        symbol   = _symbol;
        decimals = _decimals;
        totalSupply           = _count;
        balanceOf[msg.sender] = _count;
    }
 
    /**
     * @dev Transfer self tokens to given address
     * @param _to destination address
     * @param _value amount of token values to send
     * @notice `_value` tokens will be sended to `_to`
     * @return `true` when transfer done
     */
    function transfer(address _to, uint _value) returns (bool) {
        if (balanceOf[msg.sender] >= _value) {
            balanceOf[msg.sender] -= _value;
            balanceOf[_to]        += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Transfer with approvement mechainsm
     * @param _from source address, `_value` tokens shold be approved for `sender`
     * @param _to destination address
     * @param _value amount of token values to send 
     * @notice from `_from` will be sended `_value` tokens to `_to`
     * @return `true` when transfer is done
     */
    function transferFrom(address _from, address _to, uint _value) returns (bool) {
        var avail = allowance[_from][msg.sender]
                  > balanceOf[_from] ? balanceOf[_from]
                                     : allowance[_from][msg.sender];
        if (avail >= _value) {
            allowance[_from][msg.sender] -= _value;
            balanceOf[_from] -= _value;
            balanceOf[_to]   += _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Give to target address ability for self token manipulation without sending
     * @param _address target address
     * @param _value amount of token values for approving
     */
    function approve(address _address, uint _value) {
        allowance[msg.sender][_address] += _value;
        Approval(msg.sender, _address, _value);
    }

    /**
     * @dev Reset count of tokens approved for given address
     * @param _address target address
     */
    function unapprove(address _address)
    { allowance[msg.sender][_address] = 0; }
}
```

- отсутсвуют внешние вызовы
- никакой арифметики в сравнениях
- переопределена fallback функция 

### ShareSale (Aira DAO Core)

```
/**
 * @title Contract for objects that can be morder
 */
contract Mortal is Owned {
    /**
     * @dev Destroy contract and scrub a data
     * @notice Only owner can kill me
     */
    function kill() onlyOwner
    { suicide(owner); }
}

/**
 * @title Contract for direct sale shares for cashflow 
 */
contract ShareSale is Mortal {
    // Assigned shares contract
    Token public shares;

    // Ether fund token 
    TokenEther public etherFund;

    // Target address for funds
    address public target;

    // Price of one share
    uint public priceWei;

    // Time of sale
    uint public closed = 0;

    /**
     * @dev Set price of one share in Wei
     * @param _price_wei is share price
     */
    function setPrice(uint _price_wei) onlyOwner
    { priceWei = _price_wei; }
    
    /**
     * @dev Create the contract for given cashflow and start price
     * @param _target is a target of funds
     * @param _etherFund is a ether wallet token
     * @param _shares is a shareholders token contract 
     * @param _price_wei is a price of one share
     * @notice After creation you should send shares to contract for sale
     */
    function ShareSale(address _target, address _etherFund,
                       address _shares, uint _price_wei) {
        target    = _target;
        etherFund = TokenEther(_etherFund);
        shares    = Token(_shares);
        priceWei  = _price_wei;
    }

    /**
     * @dev This fallback method receive ethers and exchange available shares 
     *      by price, setted by owner.
     * @notice only full packet of shares can be saled
     */
    function () {
        var value = shares.getBalance() * priceWei; 
        // при невозможности вызвать метод будетвозвращен 0, что приведет к занчению value=0

        if (  closed > 0 
           || msg.value < value
           || !msg.sender.send(msg.value - value)
           ) throw;
        // Проверка на присланное значение и на возврат лишних средств

        etherFund.refill.value(value)();
        // Перевод на счет контракта TokenEther средств
        // (!) потенциально уязвима к Call Depth attack
        // однако не может быть осуществлена, так как делее
        // происходит перевод средств, однако при ненулевом балансе
        // атака может быть выполнена 

        if (  !etherFund.transfer(target, value)
           || !shares.transfer(msg.sender, shares.getBalance())
           ) throw;
        // Проверка на перевод стредств

        closed = now;
        // Закрытие сделки
    }

    function kill() onlyOwner {
        // Save the shares
        if (!shares.transfer(owner, shares.getBalance())) throw;

        super.kill();
    }
}
```
