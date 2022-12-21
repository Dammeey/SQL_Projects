-- Create a function that will return a list of films by part of the title in stock 
-- (for example, films with the word 'love' in the title)
-- The function should return the result set in the following view 
-- (notice: row_num field is generated counter field (1,2, …, 100, 101, …))

CREATE OR REPLACE FUNCTION public.films_in_stock_by_title(word VARCHAR(255))
RETURNS TABLE (
                row_num BIGINT,
                film VARCHAR(255),
                movie_language VARCHAR(255),
                customer_name VARCHAR(255),
                rental_date DATE
                
             )  

AS $$

BEGIN 
        RETURN QUERY 
        WITH films_table AS (
        SELECT CAST(r.rental_id AS BIGINT) , 
                (v1.title::VARCHAR(255)) AS film_title, 
               CAST(l."name" AS VARCHAR(255)) AS movie_language, 
              CAST(c.first_name || ' ' || c.last_name AS VARCHAR(255)) AS customer_name, 
              CAST(r.rental_date AS DATE)
        FROM public.film v1
        JOIN public."language" l 
        ON l.language_id = v1.language_id 
        JOIN public.inventory i 
        ON i.film_id = v1.film_id 
        JOIN public.rental r 
        ON r.inventory_id = i.inventory_id 
        JOIN public.customer c
        ON c.customer_id = r.customer_id 
        WHERE v1.title LIKE (word)
        GROUP BY  r.rental_id , v1.title, l."name", c.first_name ,c.last_name , r.rental_date
        )
        
        SELECT (SELECT count(*)
                FROM films_table ft2
                WHERE ft2.rental_id <= ft1.rental_id),
                ft1.film_title,
                ft1.movie_language,
                ft1.customer_name,
                ft1.rental_date
        FROM films_table ft1
        ORDER BY ft1.rental_id;
        
END;
$$

LANGUAGE plpgsql;

SELECT * 
FROM public.films_in_stock_by_title('%LOVE%');

--DROP FUNCTION public.films_in_stock_by_title(VARCHAR(255))
