# turd
Portfolio rebalancer for T-invest API

Как должен работать ребалансировщик:
1. Есть портфель акций, у них есть стоимость, у каждой акции есть доля в портфеле
2. Стоимость акций меняется и балансировщик при некоторых условиях продает и покупает акции
3. Условия могут быть разные, для TURD на lua это был индикатор из двух экспоненциальных скользящих средних, 12 пятиминуток и, кажется, 100 пятиминуток
4. Плюс пороги, следование трендам и прочее.

В этот раз я хочу получить что-то более интеллектуальное, с сохраненными данными, аналитикой сделок, веб-интерфейсом для мониторинга (не будет ведь никакого QUIK).
С возможностью ликвидировать или заменить позицию и прочее.

Если дела пойдут, можно будет через эту же штуку встроить мониторинг облигаций и т.п.