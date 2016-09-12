# Smart contract ShareSale security check

- Семейство контрактов: [Aira DAO Core][1]
- Исходный код контракта: [ShareSale.sol](https://github.com/airalab/core/62c672732695b6429678bcd321520c41af109475/sol/cashflow/ShareSale.sol)

## Проверка общих [рекомендаций Airalab][2]

| № | Описание                                             | |
|---|:-----------------------------------------------------|:--------------------------:|
| 1 | Внешние вызовы                                       | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg)  |
| 2 | Изоляция внешних вызовов в отдельной транзакции      | ![good](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/check.svg) |
| 3 | Деление целых чисел                                  | ![good](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/check.svg)     |
| 4 | Деление на ноль                                      | ![good](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/check.svg)        |
| 5 | Переполнение переменных                              | ![danger](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/flame.svg)   |
| 6 | Приоритет изменения состояния над внешним вызовом    | ![good](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/check.svg) | 
| 7 | Перебор динамических массивов                        | ![good](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/check.svg) | 
| 8 | Привязка логики работы к метке времени               | ![good](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/check.svg) |
| 9 | Миграция данных контракта                            | ![good](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/check.svg)  |
|10 | Метки остановки работы                               | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg)|
|11 | Метки задежки по времени                             | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg)     |
|12 | Формальная верификация                               | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg)   |


## Известные атаки на контракты Ethereum платформы

| № | Описание                                             |  |
|---|:-----------------------------------------------------|:-------------------:|
| 1 | Атака по глубине стека                               | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg)   |
| 2 | Условия гонки                                        | ![good](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/check.svg)|
| 3 | DoS при исключении в стороннем коде                  | ![good](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/check.svg)     |
| 4 | DoS при выходе за лимит газа                         | ![good](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/check.svg) |

[1]: https://github.com/airalab/core 
[2]: https://github.com/airalab

## Проверка на известные атаки

## Комментарии по коду

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


