
WITH sales_rank AS (
	SELECT channel_desc,
			country_region,
			max_sales AS max_sales,
			SUM(SUM(max_sales)) OVER (PARTITION BY channel_desc) AS channel_sales,
			RANK() OVER (PARTITION BY channel_desc ORDER BY max_sales DESC) AS col_rank
			
							
	FROM (
			SELECT  c3.channel_desc,
					c.country_region,
					--SUM(s.amount_sold) AS nnsales,
					--TO_CHAR(SUM(s.amount_sold), '9,999,999,990.99') AS amount_sold,
					MAX(SUM(s.quantity_sold)) OVER (PARTITION BY c3.channel_desc, c.country_region) AS max_sales
					
	
			FROM sh.countries c 
			JOIN sh.customers c2 
			ON c2.country_id = c.country_id 
			JOIN sh.sales s 
			ON c2.cust_id = s.cust_id 
			JOIN sh.times t 
			ON t.time_id = s.time_id 
			JOIN sh.channels c3 
			ON s.channel_id = c3.channel_id 
			GROUP BY  channel_desc, country_region
	--ORDER BY country_region, calendar_year, channel_desc
			
	) sales_tab
	GROUP BY  channel_desc, country_region, max_sales
)

SELECT channel_desc, 
		country_region, 
		TO_CHAR(max_sales, '9999999990.99') AS sales,
		--channel_sales,
		TO_CHAR((100 * max_sales  / channel_sales), '9,999,999,990.99') || ' %'  AS "SALES %"
		
FROM sales_rank
WHERE col_rank = 1
ORDER BY max_sales DESC









WITH sales_by_year AS (
    SELECT p.prod_subcategory, t.calendar_year, SUM(s.amount_sold) AS sales
    FROM sh.products p
    JOIN sh.sales s ON s.prod_id = p.prod_id
    JOIN sh.times t ON t.time_id = s.time_id
    WHERE t.calendar_year BETWEEN 1998 AND 2001
    GROUP BY p.prod_subcategory, t.calendar_year
)
SELECT DISTINCT sby1.prod_subcategory
FROM sales_by_year sby1
JOIN sales_by_year sby2 
ON sby1.prod_subcategory = sby2.prod_subcategory 
AND sby1.calendar_year = 2001 
AND sby2.calendar_year = 2000 
AND sby1.sales > sby2.sales
JOIN sales_by_year sby3 
ON sby2.prod_subcategory = sby3.prod_subcategory 
AND sby2.calendar_year = 2000 
AND sby3.calendar_year = 1999 
AND sby2.sales > sby3.sales
JOIN sales_by_year sby4 
ON sby3.prod_subcategory = sby4.prod_subcategory 
AND sby3.calendar_year = 1999 
AND sby4.calendar_year = 1998 
AND sby3.sales > sby4.sales



WITH sales_by_year AS (
    SELECT p.prod_subcategory, t.calendar_year, SUM(s.amount_sold) AS sales,
           LAG(SUM(s.amount_sold)) OVER (PARTITION BY p.prod_subcategory ORDER BY t.calendar_year) AS prev_year_sales
           
    FROM sh.products p
    JOIN sh.sales s ON s.prod_id = p.prod_id
    JOIN sh.times t ON t.time_id = s.time_id
    WHERE t.calendar_year BETWEEN 1998 AND 2001
    GROUP BY p.prod_subcategory, t.calendar_year
)
SELECT prod_subcategory
FROM sales_by_year
WHERE calendar_year = 2001
AND prev_year_sales < sales
AND calendar_year -1 = 2000
AND prev_year_sales < sales
AND calendar_year -2 = 1999
AND prev_year_sales < sales
GROUP BY prod_subcategory 






