1. Посчитайте, сколько компаний закрылось 

SELECT COUNT(status)
FROM company
WHERE status LIKE '%closed%';

2. Отобразите количество привлечённых средств для новостных компаний США. Используйте данные из таблицы company. Отсортируйте таблицу по убыванию значений в поле funding_total

SELECT SUM(funding_total) AS funding_total
FROM company
WHERE category_code LIKE '%news%'
  AND country_code LIKE '%USA%'
GROUP BY name
ORDER BY funding_total DESC;**
