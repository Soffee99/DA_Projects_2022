1. Посчитайте, сколько компаний закрылось. 

SELECT COUNT(status)
FROM company
WHERE status LIKE '%closed%';

2. Отобразите количество привлечённых средств для новостных компаний США. Используйте данные из таблицы company. 
Отсортируйте таблицу по убыванию значений в поле funding_total.

SELECT SUM(funding_total) AS funding_total
FROM company
WHERE category_code LIKE '%news%'
  AND country_code LIKE '%USA%'
GROUP BY name
ORDER BY funding_total DESC;

3. Найдите общую сумму сделок по покупке одних компаний другими в долларах. Отберите сделки, которые осуществлялись только за наличные 
с 2011 по 2013 год включительно.

SELECT SUM(price_amount)
FROM acquisition
WHERE term_code LIKE 'ca%sh'
  AND EXTRACT(YEAR FROM CAST(acquired_at AS date)) BETWEEN 2011 AND 2013;
  
  
4. Отобразите имя, фамилию и названия аккаунтов людей в твиттере, у которых названия аккаунтов начинаются на 'Silver'. 

SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';


5. Выведите на экран всю информацию о людях, у которых названия аккаунтов в твиттере содержат подстроку 'money', а фамилия начинается на 'K'.

SELECT *
FROM people
WHERE twitter_username LIKE '%money%'
  AND last_name LIKE 'K%';
  
6. Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. 
Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы.

SELECT country_code,
       SUM(funding_total) AS total
FROM company
GROUP BY country_code
ORDER BY total DESC;

7. Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату. 
Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.

SELECT funded_at,
       MIN(raised_amount) AS min_raised_amoint,
       MAX(raised_amount) AS max_raised_amoint
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) <> 0 
   AND MIN(raised_amount) <> MAX(raised_amount);
  
8. Создайте поле с категориями:
   * Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
   * Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
Отобразите все поля таблицы fund и новое поле с категориями.

SELECT *,
       CASE
           WHEN invested_companies < 20 THEN 'low_activity'
           WHEN invested_companies >= 20 AND invested_companies < 100 THEN 'middle_activity'
           ELSE 'high_activity'
       END
FROM fund;

9. Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов, 
в которых фонд принимал участие. Выведите на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего.

SELECT CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
       ROUND(AVG(investment_rounds)) AS avg_rounds
FROM fund
GROUP BY activity
ORDER BY avg_rounds;

10. Выгрузите таблицу с десятью самыми активными инвестирующими странами. Активность страны определите по среднему количеству компаний, 
в которые инвестируют фонды этой страны. Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды, 
основанные с 2010 по 2012 год включительно. Исключите из таблицы страны с фондами, у которых минимальное число компаний, получивших инвестиции, 
равно нулю. Отсортируйте таблицу по среднему количеству компаний от большего к меньшему.
Для фильтрации диапазона по годам используйте оператор BETWEEN.

SELECT country_code,
       MIN(invested_companies) AS min_invested_company,
       MAX(invested_companies) AS max_invested_company,
       AVG(invested_companies) AS avg_invested_company
FROM fund
WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) BETWEEN 2010 AND 2012
GROUP BY country_code
HAVING MIN(invested_companies) > 0
ORDER BY avg_invested_company DESC
LIMIT 10;

11. Отобразите имя и фамилию всех сотрудников стартапов. Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта 
информация известна.

SELECT first_name,
       last_name,
       instituition
FROM people AS p
LEFT JOIN education AS e ON p.id=e.person_id;

12. Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники. Выведите название компании и число уникальных названий 
учебных заведений. Составьте топ-5 компаний по количеству университетов.

SELECT name,
       COUNT(DISTINCT instituition) AS instituition_count
FROM people AS p 
JOIN education AS e ON p.id=e.person_id
JOIN company AS c ON  c.id=p.company_id
GROUP BY name
ORDER BY instituition_count DESC
LIMIT 5;

13. Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.

SELECT DISTINCT name 
FROM company AS c
JOIN funding_round AS fr ON c.id=fr.company_id
WHERE status LIKE '%closed%'
  AND is_first_round = 1
  AND is_last_round = 1; 
  
14. Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.

WITH
closed_company AS (SELECT DISTINCT name 
                   FROM company AS c
                   JOIN funding_round AS fr ON c.id=fr.company_id
                   WHERE status LIKE '%closed%'
                     AND is_first_round = 1
                     AND is_last_round = 1)      
SELECT DISTINCT p.id
FROM people AS p
JOIN company AS c ON p.company_id=c.id
WHERE c.name IN (SELECT *
                 FROM closed_company);
                 
15. Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.

WITH
closed_company AS (SELECT DISTINCT name 
                   FROM company AS c
                   JOIN funding_round AS fr ON c.id=fr.company_id
                   WHERE status LIKE '%closed%'
                     AND is_first_round = 1
                     AND is_last_round = 1)      
SELECT DISTINCT p.id,
       e.instituition
FROM people AS p
JOIN company AS c ON p.company_id=c.id
JOIN education AS e ON p.id=e.person_id
WHERE c.name IN (SELECT *
                 FROM closed_company);
                 
16. Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания.

WITH
closed_company AS (SELECT DISTINCT name 
                   FROM company AS c
                   JOIN funding_round AS fr ON c.id=fr.company_id
                   WHERE status LIKE '%closed%'
                     AND is_first_round = 1
                     AND is_last_round = 1)      
SELECT DISTINCT p.id,
       COUNT(e.instituition)
FROM people AS p
JOIN company AS c ON p.company_id=c.id
JOIN education AS e ON p.id=e.person_id
WHERE c.name IN (SELECT *
                 FROM closed_company)
GROUP BY p.id;

17. Дополните предыдущий запрос и выведите среднее число учебных заведений, которые окончили сотрудники разных компаний. 
Нужно вывести только одну запись, группировка здесь не понадобится.

WITH
closed_company AS (SELECT DISTINCT name 
                   FROM company AS c
                   JOIN funding_round AS fr ON c.id=fr.company_id
                   WHERE status LIKE '%closed%'
                     AND is_first_round = 1
                     AND is_last_round = 1)  
SELECT AVG(temp.count)    
FROM
(SELECT DISTINCT p.id,
       COUNT(e.instituition)
FROM people AS p
JOIN company AS c ON p.company_id=c.id
JOIN education AS e ON p.id=e.person_id
WHERE c.name IN (SELECT *
                 FROM closed_company)
GROUP BY p.id) AS temp;

18. Напишите похожий запрос: выведите среднее число учебных заведений, которые окончили сотрудники компании Facebook.

WITH
closed_company AS (SELECT DISTINCT name 
                   FROM company AS c
                   JOIN funding_round AS fr ON c.id=fr.company_id
                   WHERE name LIKE '%Facebook%')  
SELECT AVG(temp.count)    
FROM
(SELECT DISTINCT p.id,
       COUNT(e.instituition)
FROM people AS p
JOIN company AS c ON p.company_id=c.id
JOIN education AS e ON p.id=e.person_id
WHERE c.name IN (SELECT *
                 FROM closed_company)
GROUP BY p.id) AS temp;

19. Составьте таблицу из полей:
   * name_of_fund — название фонда;
   * name_of_company — название компании;
   * amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.

SELECT f.name AS name_of_fund,
       c.name AS name_of_company,
       fr.raised_amount AS amount
FROM investment AS i 
JOIN company AS c ON i.company_id=c.id
JOIN fund AS f ON i.fund_id=f.id
JOIN funding_round AS fr ON i.funding_round_id=fr.id
WHERE c.milestones > 6 
  AND EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) BETWEEN 2012 AND 2013;
  
20. Выгрузите таблицу, в которой будут такие поля:
   * название компании-покупателя;
   * сумма сделки;
   * название компании, которую купили;
   * сумма инвестиций, вложенных в купленную компанию;
   * доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
Не учитывайте те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы.
Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в алфавитном порядке. Ограничьте таблицу 
первыми десятью записями.

SELECT c_ing.name AS acquiring_company_id,
       a.price_amount,
       c_ed.name AS acquired_company_id,
       c_ed.funding_total,
       ROUND(a.price_amount / c_ed.funding_total) AS share
FROM acquisition AS a
LEFT JOIN company AS c_ing ON a.acquiring_company_id=c_ing.id
LEFT JOIN company AS c_ed ON a.acquired_company_id=c_ed.id
WHERE a.price_amount <> 0 
  AND c_ed.funding_total <> 0
ORDER BY a.price_amount DESC,
         acquired_company_id ASC
LIMIT 10;

21. Выгрузите таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно. 
Выведите также номер месяца, в котором проходил раунд финансирования.

SELECT name,
       EXTRACT(MONTH FROM CAST(funded_at AS date))
FROM company AS c
LEFT JOIN funding_round AS fr ON c.id=fr.company_id
WHERE category_code LIKE '%social%'
  AND EXTRACT(YEAR FROM CAST(funded_at AS date)) BETWEEN 2010 AND 2013;
  
22. Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируйте данные по номеру месяца и получите таблицу,
в которой будут поля:
   * номер месяца, в котором проходили раунды;
   * количество уникальных названий фондов из США, которые инвестировали в этом месяце;
   * количество компаний, купленных за этот месяц;
   * общая сумма сделок по покупкам в этом месяце.

WITH
acq_company AS (SELECT EXTRACT(MONTH FROM acquired_at) AS month,
       COUNT(acquired_company_id) AS count_acquired_companies,
       SUM(price_amount) AS total_sum
FROM acquisition 
WHERE EXTRACT(YEAR FROM acquired_at) BETWEEN 2010 AND 2013
GROUP BY month),
funds AS (SELECT EXTRACT(MONTH FROM fr.funded_at) AS month,
       COUNT(DISTINCT f.name) AS uniq_funds
FROM funding_round AS fr
LEFT JOIN investment AS i ON fr.id=i.funding_round_id
LEFT JOIN fund AS f ON i.fund_id=f.id
WHERE EXTRACT(YEAR FROM fr.funded_at) BETWEEN 2010 AND 2013
  AND country_code LIKE '%USA%'
GROUP BY month)
SELECT ac.month,
       uniq_funds,
       count_acquired_companies,
       total_sum
FROM acq_company AS ac
LEFT JOIN funds AS fs ON ac.month=fs.month;

23. Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. 
Данные за каждый год должны быть в отдельном поле. Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.

year11 AS (SELECT country_code,
                     AVG(funding_total) AS avg_funding_2011
              FROM company
              WHERE EXTRACT(YEAR FROM founded_at) = '2011'
              GROUP BY country_code),
year12 AS (SELECT country_code,
                     AVG(funding_total) AS avg_funding_2012
              FROM company
              WHERE EXTRACT(YEAR FROM founded_at) = '2012'
              GROUP BY country_code),    
year13 AS (SELECT country_code,
                     AVG(funding_total) AS avg_funding_2013
              FROM company
              WHERE EXTRACT(YEAR FROM founded_at) = '2013'
              GROUP BY country_code)              
SELECT year11.country_code,
       avg_funding_2011,
       avg_funding_2012,
       avg_funding_2013
FROM year11
JOIN year12 ON year11.country_code=year12.country_code
JOIN year13 ON year12.country_code=year13.country_code
ORDER BY avg_funding_2011 DESC; 
