/* Build the query to generate sales report for 1999 and 2000 in the context of quarters and product categories. 
 * In the report you should analyze the sales of products from the categories 'Electronics', 'Hardware' and 'Software/Other', 
 * through the channels 'Partners' and 'Internet':
 * 
 */

WITH cte AS (
SELECT *,
		--first_quarter_sales,
		LAG(first_quarter_sales) OVER (PARTITION BY calendar_year, prod_category ORDER BY calendar_quarter_desc ) AS q1_sales,
		SUM(sales$) OVER (PARTITION BY calendar_year ORDER BY calendar_quarter_desc) AS cumulative_sales

FROM ( 
		SELECT  		t.calendar_year, 
						t.calendar_quarter_desc,
						p.prod_category,
						ROUND(SUM(s.amount_sold),2) AS sales$,
						FIRST_VALUE(SUM(s.amount_sold)) 
							OVER w AS first_quarter_sales
						
		FROM sh.times t 
		JOIN sh.sales s 
		ON t.time_id = s.time_id 
		JOIN sh.products p 
		ON p.prod_id = s.prod_id 
		JOIN sh.channels c 
		ON c.channel_id = s.channel_id 
		WHERE t.calendar_year IN (1999, 2000)
		AND p.prod_category IN ('Electronics', 'Hardware', 'Software/Other')
		AND c.channel_desc IN ('Partners','Internet')
		GROUP BY t.calendar_year, t.calendar_quarter_desc, p.prod_category
		WINDOW w AS (PARTITION BY calendar_year, prod_category ORDER BY calendar_quarter_desc
					GROUPS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
		ORDER BY t.calendar_year, t.calendar_quarter_desc, sales$ DESC 
) tab1
--GROUP BY calendar_year, calendar_quarter_desc
ORDER BY calendar_year, calendar_quarter_desc, sales$ DESC 

)

SELECT 	calendar_year, 
		calendar_quarter_desc,
		prod_category,
		sales$,
		CASE WHEN q1_sales IS NULL
			THEN 'N/A'
		ELSE TO_CHAR(((sales$ - q1_sales)/q1_sales) * 100, '9,999,999,990.99') || ' %' 

		END AS diff_percent,
		cumulative_sales
		

		--SUM(sales$) OVER (PARTITION BY calendar_quarter_desc ORDER BY calendar_quarter_desc
						--RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_sum$
FROM cte

--GROUP BY calendar_year, calendar_quarter_desc, prod_category, sales$, q1_sales


