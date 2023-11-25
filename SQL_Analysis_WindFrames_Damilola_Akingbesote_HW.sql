
WITH cte AS (
SELECT country_region,
		calendar_year,
		channel_desc,
		amount_sold,
		--sales_percent,
		TO_CHAR((100 * am_sold  / channel_sales), '9,999,999,990.99') || ' %' AS "% BY CHANNELS",
		LAG(TO_CHAR((100 * am_sold  / channel_sales), '9,999,999,990.99') || ' %') OVER ( PARTITION BY country_region, channel_desc 
															ORDER BY calendar_year) AS "% PREVIOUS PERIOD"				
		
FROM (
		SELECT  c.country_region,
				t.calendar_year,
				c3.channel_desc,
				SUM(s.amount_sold) AS am_sold,
				TO_CHAR(SUM(s.amount_sold), '9,999,999,999 $') AS amount_sold,
				--(100 * am_sold  / channel_sales) AS sales_percent,
				SUM(SUM(s.amount_sold)) OVER (PARTITION BY t.calendar_year, c.country_region ORDER BY c.country_region
												GROUPS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS channel_sales
				
		FROM sh.countries c 
		JOIN sh.customers c2 
		ON c2.country_id = c.country_id 
		JOIN sh.sales s 
		ON c2.cust_id = s.cust_id 
		JOIN sh.times t 
		ON t.time_id = s.time_id 
		JOIN sh.channels c3 
		ON s.channel_id = c3.channel_id 
		WHERE c.country_region IN ('Americas', 'Asia', 'Europe')
		AND t.calendar_year IN ( 1998, 1999, 2000, 2001)
		GROUP BY country_region, calendar_year, channel_desc --, amount_sold
		ORDER BY country_region, calendar_year, channel_desc

) tab
--WHERE calendar_year  (1999,2000,2001)
ORDER BY country_region, calendar_year, channel_desc
)
--SELECT SPLIT_PART(TRIM(ccc."% BY CHANNELS"), ' ', 1)  FROM cte ccc;


SELECT * ,
    TO_CHAR((SPLIT_PART(TRIM(cc."% BY CHANNELS"), ' ', 1)::NUMERIC) 
    - (SPLIT_PART(TRIM("% PREVIOUS PERIOD"), ' ', 1)::NUMERIC), '9,999,999,990.99') || ' %' AS "% DIFF"
FROM cte cc
WHERE calendar_year IN (1999,2000,2001);


/*Build the query to generate a sales report for the 49th, 50th and 51st weeks of 1999. 
 * 
 *	Add column CUM_SUM for accumulated amounts within weeks. 
 *  For each day, display the average sales for the previous, current and next days (centered moving average, CENTERED_3_DAY_AVG column). 
 *  For Monday, calculate average weekend sales + Monday + Tuesday. For Friday, calculate the average sales for Thursday + Friday + weekends.
*/

WITH sales_report AS (
SELECT *,
		CASE WHEN day_name = 'Monday' 
				THEN AVG(SUM(sales)) OVER (ORDER BY time_id RANGE BETWEEN
																		INTERVAL '2' DAY PRECEDING AND 
																		INTERVAL '1' DAY FOLLOWING)
			WHEN day_name = 'Friday' 
				THEN AVG(SUM(sales)) OVER (ORDER BY time_id RANGE BETWEEN
																		INTERVAL '1' DAY PRECEDING AND 
																		INTERVAL '2' DAY FOLLOWING)
																		
			ELSE AVG(SUM(sales)) OVER (ORDER BY time_id RANGE BETWEEN
																		INTERVAL '1' DAY PRECEDING AND 
																		INTERVAL '1' DAY FOLLOWING)
																		
			END AS day_avg
FROM (
		SELECT t.calendar_week_number,
				t.time_id,
				t.day_name,
				SUM(s.amount_sold) AS sales,
				SUM(SUM(s.amount_sold))	OVER (PARTITION BY t.calendar_week_number ORDER BY t.time_id
												RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_sales
				
		FROM sh.times t 
		JOIN sh.sales s 
		ON s.time_id = t.time_id 
		WHERE t.calendar_year = 1999
		AND t.calendar_week_number IN (49, 50, 51)
		GROUP BY t.calendar_week_number,t.time_id, t.day_name
) tab2

GROUP BY calendar_week_number, time_id, day_name, sales, cum_sales
)

SELECT calendar_week_number, 
		time_id, 
		day_name, 
		sales, 
		cum_sales,
		ROUND(day_avg, 2) AS centered_3_day_avg
		
FROM sales_report;
		


/* Prepare 3 examples of using window functions with a frame clause (RANGE, ROWS, and GROUPS modes) 
 * Explain why you used a particular type of frame in each example. 
 * It can be one query or 3 separate queries.
 */
 
/* I used the rows to get the total sum of 3 rows behind the current row
 * 
 * I used the range mode to get the sum of the amounts between 3 groups above the current row
 * 
 * I used the groups mode to get the max of the channel sales between 3 groups above the current row and to ensure continuity incase a group is skipped
 */ 

SELECT channel_desc, 
		cust_last_name,
		cust_first_name,
		amount_sold,
		channel_sales,
		total_sales_range,
		
		MAX(channel_sales) OVER (ORDER BY channel_sales GROUPS BETWEEN 3 PRECEDING 
																		AND CURRENT ROW) AS total_sales_group

 	
FROM (
		SELECT c.channel_desc,
				c2.cust_last_name,
				c2.cust_first_name,
				SUM(s.amount_sold) AS amount_sold,
				SUM(SUM(s.amount_sold)) OVER (PARTITION BY c.channel_desc ORDER BY s.amount_sold ROWS BETWEEN 3 PRECEDING 
																					AND CURRENT ROW) AS channel_sales,
				SUM(s.amount_sold) OVER (ORDER BY s.amount_sold RANGE BETWEEN 3 PRECEDING 
																					AND CURRENT ROW) AS total_sales_range,
				ROW_NUMBER() OVER (PARTITION BY c.channel_desc ORDER BY SUM(s.amount_sold) DESC ) AS col_rank
				
		FROM sh.channels c 
		JOIN sh.sales s 
		ON c.channel_id = s.channel_id 
		JOIN sh.customers c2 
		ON c2.cust_id = s.cust_id 
		
		GROUP BY c.channel_desc, c2.cust_last_name, c2.cust_first_name, c2.cust_id, s.amount_sold
		
) tab
WHERE col_rank <= 5

GROUP BY channel_desc, cust_last_name, cust_first_name, amount_sold, channel_sales, total_sales_range;
