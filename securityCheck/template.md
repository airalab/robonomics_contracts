# Smart contract {contract.name} security check

- Семейство контрактов: [Aira DAO Core][1]
- Исходный код контракта: [{contract.name}.sol](https://github.com/airalab/core/master/sol/{contract.package}/{contract.name}.sol)

## Проверка общих [рекомендаций Airalab][2]

| № | Описание                                             | |
|---|:-----------------------------------------------------|:--------------------------:|
| 1 | Внешние вызовы                                       | {recs.external_calls.img}  |
| 2 | Изоляция внешних вызовов в отдельной транзакции      | {recs.extcall_isolate.img} |
| 3 | Деление целых чисел                                  | {recs.integer_div.img}     |
| 4 | Деление на ноль                                      | {recs.zero_div.img}        |
| 5 | Переполнение переменных                              | {recs.var_overlflow.img}   |
| 6 | Приоритет изменения состояния над внешним вызовом    | {recs.state_over_call.img} | 
| 7 | Перебор динамических массивов                        | {recs.array_iteration.img} | 
| 8 | Привязка логики работы к метке времени               | {recs.timestamp_logic.img} |
| 9 | Миграция данных контракта                            | {recs.data_migration.img}  |
|10 | Метки остановки работы                               | {recs.emergency_breaks.img}|
|11 | Метки задежки по времени                             | {recs.time_breaks.img}     |
|12 | Формальная верификация                               | {recs.formal_verify.img}   |


## Известные атаки на контракты Ethereum платформы

| № | Описание                                             |  |
|---|:-----------------------------------------------------|:-------------------:|
| 1 | Атака по глубине стека                               | {att.depth_stack}   |
| 2 | Условия гонки                                        | {att.race_condition}|
| 3 | DoS при исключении в стороннем коде                  | {att.dos_throw}     |
| 4 | DoS при выходе за лимит газа                         | {att.dos_gas_limit} |

## Проверка на известные атаки

## Комментарии по коду


[1]: https://github.com/airalab/core 
[2]: https://github.com/airalab
