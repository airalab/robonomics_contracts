# Регламент проверки безопасности контрактов Airalab

Каждый контракт, который мы создаем проверяется разработчиком по данному регламенту, в результате проверки формируется документ, который необходимо расположить по следующему пути: [/airalab/core/securityCheck](https://github.com/airalab/core/tree/master/securityCheck)

**Результат проверки должен содержать 3 блока:**

**Блок 1: «Проверка общих рекомендаций Airalab».** В данном блоке должен быть описан результат проверки по каждому из пунктов, содержащихся в разделе: "[Обобщенные рекомендации к проверке](#%D0%9E%D0%B1%D0%BE%D0%B1%D1%89%D0%B5%D0%BD%D0%BD%D1%8B%D0%B5-%D1%80%D0%B5%D0%BA%D0%BE%D0%BC%D0%B5%D0%BD%D0%B4%D0%B0%D1%86%D0%B8%D0%B8-%D0%BA-%D0%BF%D1%80%D0%BE%D0%B2%D0%B5%D1%80%D0%BA%D0%B5)".

**Блок 2: «Проверка на известные атаки».** В данном блоке должен быть описан результат проверки по каждой из известных нам видов атак, содержащихся в разделе: "[Известные атаки](#%D0%98%D0%B7%D0%B2%D0%B5%D1%81%D1%82%D0%BD%D1%8B%D0%B5-%D0%B0%D1%82%D0%B0%D0%BA%D0%B8)".

**Блок 3: «Комментарии по коду».** Данный блок позволяет разработчику обратить внимание на потенциально уязвимые места или же акцентировать внимание пользователя на каких либо фрагментах кода.

Как пример результата проверки можно посмотреть следующий документ: [Smart contract «Token.sol» security check](https://github.com/airalab/core/blob/master/securityCheck/token.md).

Рекомендации/замечания разработчиков пишите в формате [issue в репозиторий Aira core на GutHub](https://github.com/airalab/core/issues).

Также любые вопросы в наш [канал друзей Airalab в Gitter](https://gitter.im/airalab/friends).

## Обобщенные рекомендации к проверке кода контрактов на Ethereum платформе
1. Избегайте внешних вызовов когда это возможно, очень часто они являются причиной уязвимости
2. Отдавайте приоритет изменению состояния над внешним вызовом вызовом (включая `.send()`)
3. Изолируйте внешние вызовы в отдельной транзакции, например, метод `withdraw` для вывода средств
4. Будте внимательны при делении целых чисел (округление происходит к ближайшему целому)
5. При делении на ноль возвращается **ноль**, проверяйте аргументы самостоятельно
6. Будте внимательны к переполнению целых чисел (особенно в сравнениях) и приведению знаковых к беззнаковым в JS
7. Будьте осторожны при переборе динамических массивов, это может потребовать большое количество газа
8. Будте осторожны с привязкой логики контракта ко времени блока, оно устанавливается майнером
9. Подумайте о способе обновления контракта в будующем
10. Используйте метки остановки работы контракта в случае чрезвычайной ситуации, например обнаружении уязвимости
11. Разделяйте критически важные вызовы во времени, например, вывод большого количества средств не чаще раза в неделю
12. Используйте [формальную верификацию](https://gist.github.com/chriseth/c4a53f201cd17fc3dd5f8ddea2aa3ff9) контрактов

## Известные атаки на контракты Ethereum платформы
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
// ATTACKER
contract xxx {
    function foo(address target, address recipient, uint iter) {
        if (iter < 1023) foo(target, recipient, iter+1);
        else auction(target).withdrawRefund(recipient);
    }
}
```

**Противодействие:** минимизация вызовов внутри методов, приоритет записи и учета над вызовом другого метода; а также `.send()` возвращает `false` если не может быть исполнена, необходимо при каждой отправке средств проверять возвращаемое значение.

### Условия гонки
**Идея:** внешний вызов может произвести неконтролируемые изменения в данных контракта.

```
// INSECURE
contract token {
  mapping (address => uint) private userBalances;

  function withdrawBalance() public {
    uint amountToWithdraw = userBalances[msg.sender];
    // в этом месте внешний контракт может вызвать метод withdrawBalance снова
    if (!(msg.sender.call.value(amountToWithdraw)())) { throw; }
    userBalances[msg.sender] = 0;
  }
}
/// ATTACKER
contract xxx {
  uint iter;
  address target;
  function foo(address _target) {
    iter = 0;
    target = _target;
    token(_target).withdrawBalance();
  }
  function () payable {
    if (iter < 10) // Withrawal 10 times
      token(_target).withdrawBalance();
  }
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
// ATTACKER
contract xxx {
  function () payable { throw; }
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

## Ссылки
1. [Ethereum Contract Security Techniques and Tips](https://github.com/ConsenSys/smart-contract-best-practices)
2. [Публикация в блоге Ethereum Christian Reitwiessner: Smart contract security](https://blog.ethereum.org/2016/06/10/smart-contract-security/)
3. [Публикация в блоге Ethereum Виталика Бутерина: Thinking About Smart Contract Security](https://blog.ethereum.org/2016/06/19/thinking-smart-contract-security/)
4. [Запись лекции по безопасности умных контрактов на Youtube: Smart contract security in Ethereum](https://www.youtube.com/watch?v=pv032ppbakA)
5. [Smart Contract Security in Ethereum](https://docs.google.com/presentation/d/1kS9mVOQNieloYByGQw3P-Yyup2BYE5tg7jOItMNnR0A/edit#slide=id.g15d26d8dbd_0_0)
