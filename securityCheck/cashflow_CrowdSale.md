# Smart contract CrowdSale security check

- Семейство контрактов: [Aira DAO Core][1]
- Исходный код контракта: [CrowdSale.sol](https://github.com/airalab/core/62c672732695b6429678bcd321520c41af109475/sol/cashflow/CrowdSale.sol)

## Проверка общих [рекомендаций Airalab][2]

| № | Описание                                             | |
|---|:-----------------------------------------------------|:--------------------------:|
| 1 | Внешние вызовы                                       | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg)  |
| 2 | Изоляция внешних вызовов в отдельной транзакции      | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg) |
| 3 | Деление целых чисел                                  | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg)     |
| 4 | Деление на ноль                                      | ![danger](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/flame.svg)        |
| 5 | Переполнение переменных                              | ![danger](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/flame.svg)   |
| 6 | Приоритет изменения состояния над внешним вызовом    | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg) | 
| 7 | Перебор динамических массивов                        | ![good](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/check.svg) | 
| 8 | Привязка логики работы к метке времени               | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg) |
| 9 | Миграция данных контракта                            | ![good](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/check.svg)  |
|10 | Метки остановки работы                               | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg)|
|11 | Метки задежки по времени                             | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg)     |
|12 | Формальная верификация                               | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg)   |


## Известные атаки на контракты Ethereum платформы

| № | Описание                                             |  |
|---|:-----------------------------------------------------|:-------------------:|
| 1 | Атака по глубине стека                               | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg)   |
| 2 | Условия гонки                                        | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg)|
| 3 | DoS при исключении в стороннем коде                  | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg)     |
| 4 | DoS при выходе за лимит газа                         | ![warning](https://cdn.rawgit.com/primer/octicons/62c672732695b6429678bcd321520c41af109475/build/svg/issue-opened.svg) |

## Проверка на известные атаки

## Комментарии по коду


[1]: https://github.com/airalab/core 
[2]: https://github.com/airalab
