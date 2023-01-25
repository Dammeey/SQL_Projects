
--1.	What 3 countries has the highest number of sales?

SELECT c.country_name, COUNT(s.quantity_sold) AS no_of_sales
FROM sh.countries c
JOIN sh.customers c2
ON c.country_id = c2.country_id 
JOIN sh.sales s
ON s.cust_id = c2.cust_id 
GROUP BY  c.country_name, s.quantity_sold 
ORDER BY no_of_sales  DESC 
FETCH FIRST 3 ROWS WITH TIES;

-- 2.	What channel generates the most and the least income for products over the years?

SELECT c.channel_desc, c.channel_class, SUM(s.quantity_sold * s.amount_sold) AS income
FROM sh.channels c 
JOIN sh.sales s  
ON s.channel_id = c.channel_id 
GROUP BY c.channel_desc, c.channel_class, s.quantity_sold 
ORDER BY income DESC;



-- 3.	In what month of the year do they make the highest total profits? 


SELECT DISTINCT t1.calendar_year, t1.calendar_month_name, MAX(p.total_cost) AS profit
FROM sh.times t1
JOIN sh.profits p 
ON t1.time_id = p.time_id 
GROUP BY  t1.calendar_month_name, t1.calendar_year
HAVING MAX(p.total_cost) IN (SELECT MAX(profit) FROM
				(SELECT t1.calendar_year, t1.calendar_month_name, MAX(p2.total_cost) AS profit
				FROM sh.times t2
				JOIN sh.profits p2
				ON t2.time_id = p2.time_id 
				WHERE t1.calendar_year = t2.calendar_year 
				GROUP BY  t2.calendar_month_name, t2.calendar_year) aa )
ORDER BY t1.calendar_year;



