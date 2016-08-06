# Smart contract "Token.sol" security check
- Семейство контрактов: [Aira DAO Core](https://github.com/airalab/core)
- Исходный код контракта: [Sharesale.sol](sol/token/Token.sol)

## Проверка общих рекомендаций Airalab
- отсутсвуют внешние вызовы
- никакой арифметики в сравнениях
- переопределена fallback функция

## Проверка на известные атаки

Null

## Комментарии по коду

```
modifier onlyOwner { if (msg.sender != owner) throw; _ }
```
*Бросать исключение предпочтительнее для кода, инициирующего вызов*

Source: [common/Owned.sol#L27](https://github.com/airalab/core/blob/master/sol/common/Owned.sol#L27)
