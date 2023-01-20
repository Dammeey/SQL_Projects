/* Build the query to generate a report about the most significant customers (which have maximum sales) through various sales channels. 
 * The 5 largest customers are required for each channel.
 * Column sales_percentage shows percentage of customer’s sales within channel sales
 */


SELECT channel_desc, 
		cust_last_name,
		cust_first_name,
		amount_sold,
		--channel_sales,
		TO_CHAR(ROUND(100 * amount_sold  / channel_sales , 5), '9.99999 %') AS sales_percentage
FROM (
		SELECT c.channel_desc,
				c2.cust_last_name,
				c2.cust_first_name,
				SUM(s.amount_sold) AS amount_sold,
				SUM(SUM(s.amount_sold)) OVER (PARTITION BY c.channel_desc) AS channel_sales,
				ROW_NUMBER() OVER (PARTITION BY c.channel_desc ORDER BY SUM(s.amount_sold) DESC ) AS col_rank
				
		FROM sh.channels c 
		JOIN sh.sales s 
		ON c.channel_id = s.channel_id 
		JOIN sh.customers c2 
		ON c2.cust_id = s.cust_id 
		
		GROUP BY c.channel_desc, c2.cust_last_name, c2.cust_first_name, c2.cust_id
		
) tab
WHERE col_rank <= 5;
--GROUP BY channel_desc, cust_last_name, cust_first_name, amount_sold

/* Compose query to retrieve data for report with sales totals for all products in Photo category in Asia (use data for 2000 year). 
 * Calculate report total (YEAR_SUM).
 */

SELECT *,
       COALESCE(q1, 0) + COALESCE(q2, 0) + COALESCE(q3, 0) + COALESCE(q4, 0) AS year_sum
FROM crosstab(
    'SELECT p.prod_name,
            t.calendar_quarter_number,
            SUM(s.amount_sold) AS amount_sold
    FROM sh.products p 
    JOIN sh.sales s 
    ON s.prod_id = p.prod_id 
    JOIN sh.customers c 
    ON s.cust_id = c.cust_id 
    JOIN sh.countries c2 
    ON c.country_id = c2.country_id 
    JOIN sh.times t 
    ON s.time_id = t.time_id 
    WHERE p.prod_category = ''Photo''
    AND c2.country_subregion = ''Asia''
    AND t.calendar_year = 2000
    AND t.calendar_quarter_number = ANY (''{1,2,3,4}'')
    GROUP BY p.prod_name,t.calendar_quarter_number
    ORDER BY p.prod_name, t.calendar_quarter_number'
) AS  ct (prod_name VARCHAR(50), q1 NUMERIC, q2 NUMERIC, q3 NUMERIC, q4 NUMERIC);



/* Build the query to generate a report about customers who were included into TOP 300 
 * (based on the amount of sales) in 1998, 1999 and 2001. 
 * This report should separate clients by sales channels, and, at the same time, 
 * channels should be calculated independently (i.e. only purchases made on selected channel are relevant).
 */

--WITH cte AS (
--		SELECT c.channel_desc, 
--						c2.cust_id, 
--						c2.cust_last_name,
--						c2.cust_first_name,
--						SUM(s.amount_sold) AS amount_sold,
--						ROW_NUMBER() OVER (PARTITION BY c.channel_desc ORDER BY SUM(s.amount_sold) DESC ) AS col_rank,
--						t.calendar_year
--				FROM sh.channels c
--				JOIN sh.sales s 
--				ON c.channel_id = s.channel_id 
--				JOIN sh.customers c2 
--				ON c2.cust_id = s.cust_id
--				JOIN sh.times t 
--				ON s.time_id = t.time_id 
--				WHERE t.calendar_year = 1998
--				GROUP BY c.channel_desc, c2.cust_id, c2.cust_last_name, c2.cust_first_name, t.calendar_year
--		
--		UNION ALL
--
--		SELECT c.channel_desc, 
--			c2.cust_id, 
--			c2.cust_last_name,
--			c2.cust_first_name,
--			SUM(s.amount_sold) AS amount_sold,
--			ROW_NUMBER() OVER (PARTITION BY c.channel_desc ORDER BY SUM(s.amount_sold) DESC ) AS col_rank,
--			t.calendar_year
--		FROM sh.channels c
--		JOIN sh.sales s 
--		ON c.channel_id = s.channel_id 
--		JOIN sh.customers c2 
--		ON c2.cust_id = s.cust_id
--		JOIN sh.times t 
--		ON s.time_id = t.time_id 
--		WHERE t.calendar_year = 1999
--		GROUP BY c.channel_desc, c2.cust_id, c2.cust_last_name, c2.cust_first_name, t.calendar_year
--
--		UNION ALL 
--		
--		SELECT c.channel_desc, 
--				c2.cust_id, 
--				c2.cust_last_name,
--				c2.cust_first_name,
--				SUM(s.amount_sold) AS amount_sold,
--				ROW_NUMBER() OVER (PARTITION BY c.channel_desc ORDER BY SUM(s.amount_sold) DESC ) AS col_rank,
--				t.calendar_year
--		FROM sh.channels c
--		JOIN sh.sales s 
--		ON c.channel_id = s.channel_id 
--		JOIN sh.customers c2 
--		ON c2.cust_id = s.cust_id
--		JOIN sh.times t 
--		ON s.time_id = t.time_id 
--		WHERE t.calendar_year = 2001
--		GROUP BY c.channel_desc, c2.cust_id, c2.cust_last_name, c2.cust_first_name, t.calendar_year
--)
--
--
--
--SELECT 	DISTINCT ON (c1.cust_id)
--		channel_desc,
--		c1.cust_id,
--		cust_last_name,
--		cust_first_name, 
--		zz.amount_sold
--		
--		
--FROM cte c1 
--JOIN (
--		SELECT cust_id, COUNT(DISTINCT calendar_year) AS cnt, 
--		sum(amount_sold)  AS amount_sold
--		FROM cte c2
--		WHERE c2.calendar_year IN (1998, 1999, 2001)
--		GROUP BY channel_desc, cust_id
--	) zz ON zz.cust_id = c1.cust_id
--WHERE col_rank <= 300
--AND zz.cnt = 3
--AND cust_last_name = 'Kane'
--GROUP BY 
--		channel_desc,
--		c1.cust_id,
--		cust_last_name,
--		cust_first_name, 
--		zz.amount_sold
		

WITH cte AS (
		SELECT c.channel_desc,
				c2.cust_id,
				c2.cust_last_name,
				c2.cust_first_name,
				SUM(s.amount_sold) AS amount_sold,
				ROW_NUMBER() OVER (PARTITION BY c.channel_desc, t.calendar_year ORDER BY SUM(s.amount_sold) DESC ) AS col_rank,
				t.calendar_year
		FROM sh.channels c
		JOIN sh.sales s
		ON c.channel_id = s.channel_id
		JOIN sh.customers c2
		ON c2.cust_id = s.cust_id
		JOIN sh.times t
		ON s.time_id = t.time_id
		WHERE t.calendar_year = 1998 OR t.calendar_year = 1999 OR t.calendar_year = 2001
		GROUP BY c.channel_desc, c2.cust_id, c2.cust_last_name, c2.cust_first_name, t.calendar_year
)

SELECT channel_desc, 
		cust_id, 
		cust_last_name, 
		cust_first_name, 
		SUM(amount_sold) AS amount_sold
FROM cte
WHERE col_rank <= 300
GROUP BY channel_desc, cust_id, cust_last_name, cust_first_name
HAVING COUNT(DISTINCT calendar_year) = 3
ORDER BY amount_sold DESC;





/* Build the query to generate the report about sales in America and Europe:
 * Conditions:
• TIMES.CALENDAR_MONTH_DESC: 2000-01, 2000-02, 2000-03
• COUNTRIES.COUNTRY_REGION: Europe, Americas.
 */


SELECT *
FROM crosstab(
		'SELECT t.calendar_month_desc,
				p.prod_category,
				c2.country_region,
				SUM(s.amount_sold) as channel_sales
		FROM sh.times t
		JOIN sh.sales s 
		ON t.time_id = s.time_id 
		JOIN sh.products p 
		ON p.prod_id = s.prod_id 
		JOIN sh.customers c 
		ON s.cust_id = c.cust_id 
		JOIN sh.countries c2 
		ON c.country_id = c2.country_id 
		WHERE t.calendar_month_desc = ANY(''{2000-01, 2000-02, 2000-03}'')
		AND c2.country_region = ANY(''{Europe, Americas}'')
		GROUP BY p.prod_category, t.calendar_month_desc, c2.country_region
		',	
		'VALUES (''Americas''), (''Europe'')'

) AS ct2 (calendar_month_desc VARCHAR(8), prod_category VARCHAR(50),  "Americas SALES" NUMERIC, "Europe SALES" NUMERIC)

ORDER BY calendar_month_desc, prod_category;




