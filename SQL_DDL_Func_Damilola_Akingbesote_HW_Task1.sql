-- Create a function that will return the most popular film for each country (where country is an input paramenter).

CREATE OR REPLACE FUNCTION public.popular_film(countryy TEXT[])
RETURNS TABLE (
                country VARCHAR(50),
                film VARCHAR(50),
                rating VARCHAR(20),
                movie_language VARCHAR(20),
                length_ BIGINT,
                release_year YEAR
                --countt INTEGER
             )  

AS $$

BEGIN 
        RETURN QUERY    
        WITH movies_cte AS
        (SELECT c3.country_id,
                c3.country::VARCHAR(50), 
                f.title::VARCHAR(50) AS film, 
                CAST(f.rating AS VARCHAR(20)),
                CAST(l."name" AS VARCHAR(20)) AS movie_language, 
                CAST(f."length" AS BIGINT), 
                CAST(f.release_year AS YEAR), 
                CAST(count(r.rental_id) AS INTEGER) AS rental_cnt
        FROM public.film f
        INNER JOIN public."language" l
        ON f.language_id = l.language_id
        INNER JOIN public.inventory i
        ON f.film_id = i.film_id
        INNER JOIN public.rental r
        ON i.inventory_id = r.inventory_id
        INNER JOIN public.customer c
        ON r.customer_id = c.customer_id
        INNER JOIN public.address a
        ON c.address_id = a.address_id
        INNER JOIN public.city c2
        ON a.city_id = c2.city_id
        INNER JOIN public.country c3
        ON c2.country_id = c3.country_id
        WHERE c3.country = ANY(countryy)
        GROUP BY f.film_id, l.language_id, c3.country_id)
        
        
        SELECT m.country, m.film, m.rating, m.movie_language, m."length", m.release_year --, m.rental_cnt
        FROM movies_cte m
        WHERE rental_cnt = (SELECT max(rental_cnt) 
        					FROM movies_cte mc2 
        					WHERE m.country_id = mc2.country_id)
       GROUP BY m.country, m.film, m.rating, m.movie_language, m."length", m.release_year --, m.rental_cnt
       ORDER BY m.country;
      
    
--        SELECT DISTINCT ON (pf.country) pf.country , pf.film, pf.movie_count,
--                CAST(pf.rating AS TEXT), CAST(pf.movie_language AS TEXT), 
--                CAST(pf."length" AS TEXT), CAST(pf.release_year AS TEXT)
--        FROM pop_film pf 
----        WHERE movie_count = (
----            SELECT MAX(movie_count)
----            FROM pop_film
----        )
--        ORDER BY pf.country, pf.movie_count DESC 
END;
$$

LANGUAGE plpgsql;

SELECT * 
FROM public.popular_film(ARRAY['Canada', 'Brazil', 'South Korea', 'Finland']);

-- DROP FUNCTION popular_film(text[])
