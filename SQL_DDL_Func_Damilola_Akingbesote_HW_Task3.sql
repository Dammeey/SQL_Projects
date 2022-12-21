-- Create a function that will return the most popular film for each country (where country is an input paramenter).

CREATE OR REPLACE FUNCTION public.add_movie(mov_title VARCHAR(255),
                                    release_yr BIGINT DEFAULT EXTRACT(YEAR FROM CURRENT_DATE),
                                    mov_lang VARCHAR(255) DEFAULT 'RUSSIAN')
RETURNS BIGINT
AS $$

DECLARE 
    movie_id BIGINT;
BEGIN 
       -- RETURN QUERY 
--        INSERT INTO "language" ("name") 
--            SELECT 'Russian'
--        WHERE NOT EXISTS (
--            SELECT 1 FROM "language" l WHERE "name"='Russian'
--        );
    
        SELECT film.film_id INTO movie_id
        FROM film
        WHERE film.title = mov_title;
        IF movie_id IS NOT NULL THEN -- movie EXISTS
        RAISE NOTICE 'Film with % already exists', mov_title;
    
        ELSE 
        
        INSERT INTO public.film (title, description, release_year, language_id, original_language_id,
                                rental_duration, rental_rate, "length", replacement_cost, rating, last_update,
                                special_features, fulltext)
        
        SELECT f.title, 
                f.description, 
                release_yr, 
                (SELECT l2.language_id 
                FROM public."language" l2
                WHERE UPPER(l2."name") = mov_lang), 
                f.original_language_id,
                f.rental_duration, 
                f.rental_rate, 
                f."length", 
                f.replacement_cost, 
                f.rating, 
                f.last_update,
                f.special_features, 
                f.fulltext
        FROM public.film f 
        WHERE f.title = mov_title
        --AND f.title NOT IN (SELECT f.title FROM public.film) 
        RETURNING film_id INTO movie_id;
        --RAISE NOTICE 'New Movie % Added! ID = %', title, movie_id;
        END IF; 
        RETURN movie_id;
        

END;
$$

LANGUAGE plpgsql; 

SELECT * 
FROM public.add_movie('YOUTH KICK', 2019, 'ENGLISH')


--DROP FUNCTION add_movie(varchar(255), bigint, varchar(255))
