/* Create one function that reports all information for a particular client and timeframe:
• Customer's name, surname and email address;
• Number of films rented during specified timeframe;
• Comma-separated list of rented films at the end of specified time period;
• Total number of payments made during specified time period;
• Total amount paid during specified time period;
Function's input arguments: client_id, left_boundary, right_boundary.

The function must analyze specified timeframe [left_boundary, right_boundary] 
and output specified information for this timeframe.
Function's result format: table with 2 columns ‘metric_name’ and ‘metric_value’.

*/

CREATE OR REPLACE FUNCTION get_client_info (client_id BIGINT,   
                                left_boundary TIMESTAMP, 
                                right_boundary TIMESTAMP )
RETURNS TABLE (
                metric_name TEXT,
                metric_value TEXT
             ) 
    
LANGUAGE plpgsql

AS $$ 
DECLARE 
    cust_id BIGINT;
BEGIN 
	
	
    IF NOT EXISTS (SELECT c.customer_id
    				FROM public.customer c
    				JOIN public.rental r
    				ON r.customer_id  = c.customer_id 
    				WHERE c.customer_id  = client_id
    				AND r.rental_date BETWEEN left_boundary AND right_boundary) THEN -- client does not EXISTS
        RAISE NOTICE 'Client with id % does not exists', client_id;
	
   	ELSE 
   	
    RETURN QUERY
    WITH client_details AS 
    (SELECT c.first_name || ' ' || c.last_name || ', ' || c.email AS customer_details,  
            count(f.title) AS num_of_films_rented,
            string_agg(DISTINCT f.title, ',') AS rented_films_title,
            count(p.payment_id) AS num_of_payments,
            sum(p.amount) AS payments_amount
    FROM public.customer c
    JOIN public.rental r 
    ON r.customer_id = c.customer_id 
    JOIN public.inventory i 
    ON i.inventory_id = r.inventory_id 
    JOIN public.film f 
    ON f.film_id = i.film_id 
    JOIN public.payment p 
    ON p.rental_id = r.rental_id 
    WHERE r.rental_date BETWEEN left_boundary AND right_boundary 
    AND  c.customer_id = client_id
    GROUP BY customer_details)
    
    
    SELECT  'customers info' AS metric_name, 
    		cd.customer_details AS metric_value
    FROM client_details cd
   
    UNION ALL
   
    SELECT  'num. of films rented' AS metric_name, 
    		CAST(cd.num_of_films_rented AS VARCHAR(255)) AS metric_value
    FROM client_details cd
   
    UNION ALL
   
    SELECT  'rented films titles' AS metric_name, 
    		CAST(cd.rented_films_title AS VARCHAR(255)) AS metric_value
    FROM client_details cd
    
    UNION ALL
   
    SELECT  'num. of payments' AS metric_name, 
    		CAST(cd.num_of_payments AS VARCHAR(255)) AS metric_value
    FROM client_details cd
    
    UNION ALL
   
    SELECT  'payments amount' AS metric_name, 
    		CAST(cd.payments_amount AS VARCHAR(255)) AS metric_value
    FROM client_details cd;
    
	END IF; 
          
END;
$$;


SELECT * 
FROM get_client_info(355, '2005-01-01 00:00:00+03', '2022-08-28 00:00:00+03');

--DROP FUNCTION get_client_info(bigint,timestamp,timestamp)





--    SELECT t.metric_name, t.metric_value
--    FROM client_details cd
--    
--        CROSS JOIN LATERAL (
--            VALUES 
--            ('customers info', cd.customer_details),
--            ('num. of films rented', CAST(cd.num_of_films_rented AS VARCHAR(255))),
--            ('rented films titles', CAST(cd.rented_films_title AS VARCHAR)),
--            ('num. of payments', CAST(cd.num_of_payments AS VARCHAR(255))),
--            ('payments amount', CAST(cd.payments_amount AS VARCHAR(255)))
--        ) AS t(metric_name, metric_value);
    