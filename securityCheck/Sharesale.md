# Airalab smart contract "ShareSale.sol" security check
- Семейство контрактов: [Aira DAO Core](https://github.com/airalab/core)
- Исходный код контракта: [Sharesale.sol](sol/cashflow/ShareSale.sol)

## Проверка общих рекомендаций Airalab

Null

## Проверка на известные атаки

Null

## Комментарии по безопасности кода от разработчиков
```
function () {
    var value = shares.getBalance() * priceWei;
```
*При невозможности вызвать метод будет возвращен 0, что приведет к занчению value=0*

Source: [cashflow/ShareSale.sol#L51](https://github.com/airalab/core/blob/master/sol/cashflow/ShareSale.sol#L51)

==
```
if (  closed > 0
   || msg.value < value
   || !msg.sender.send(msg.value - value)
   ) throw;
```
*Проверка на присланное значение и на возврат лишних средств*

Source: [cashflow/ShareSale.sol#L54](https://github.com/airalab/core/blob/master/sol/cashflow/ShareSale.sol#L54)

==
```
etherFund.refill.value(value)();
```
*Перевод на счет контракта TokenEther средств (!) потенциально уязвима к Call Depth attack, однако не может быть осуществлена, так как делее происходит перевод средств. При ненулевом балансе атака может быть выполнена.*

Source: [cashflow/ShareSale.sol#L58](https://github.com/airalab/core/blob/master/sol/cashflow/ShareSale.sol#L58)

==
```
if (  !etherFund.transfer(target, value)
   || !shares.transfer(msg.sender, shares.getBalance())
   ) throw;
```
*Проверка на перевод стредств*

Source: [cashflow/ShareSale.sol#L60](https://github.com/airalab/core/blob/master/sol/cashflow/ShareSale.sol#L60)

==
```
closed = now;
```
*Закрытие сделки*

Source: [cashflow/ShareSale.sol#L64](https://github.com/airalab/core/blob/master/sol/cashflow/ShareSale.sol#L64)
