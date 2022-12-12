-- Choose your top-3 favorite movies and add them to 'film' table. 
-- Fill rental rates with 4.99, 9.99 and 19.99 and rental durations with 1, 2 and 3 weeks respectively.

INSERT INTO public.film (title, description, release_year, language_id, original_language_id,
                        rental_duration, rental_rate, length, replacement_cost, rating, last_update, special_features,
                        fulltext)
SELECT title, description, release_year, language_id, original_language_id::int,
        rental_duration, rental_rate, length, replacement_cost, rating::mpaa_rating, last_update, special_features::TEXT[],
        fulltext::tsvector FROM 
( SELECT 'MONEY HEIST' AS title,
        'Eight thieves take hostages and lock themselves in the Royal Mint of Spain as a criminal mastermind manipulates the police to carry out his plan'
                        AS description, 
        2017 AS release_year,
        (SELECT language_id 
        FROM "language" 
        WHERE "name" = 'English') AS language_id,
        NULL AS original_language_id,
        1 AS rental_duration,
        4.99 AS rental_rate,
        86 AS length,
        20.99 AS replacement_cost,
        'PG' AS  rating,
        current_date AS last_update,
        '{"Deleted Scenes","Behind the Scenes"}' AS special_features,
        '''academi'':1 ''battl'':15 ''canadian'':20 ''dinosaur'':2 ''drama'':5 ''epic'':4 ''feminist'':8 ''mad'':11 ''must'':14 ''rocki'':21 ''scientist'':12 ''teacher'':17' AS fulltext 
   
    UNION ALL 
    
    SELECT 'THE OLD GUARD' AS title,
        'A group of mercenaries, all centuries-old immortals with the ablity to heal themselves, discover someone is onto their secret.'
                        AS description, 
        2020 AS release_year,
        (SELECT language_id 
        FROM "language" 
        WHERE "name" = 'English') AS language_id,
        NULL AS original_language_id,     
        2 AS rental_duration,
        9.99 AS rental_rate,
        48 AS length,
        12.99 AS replacement_cost,
        'G' AS  rating,
        current_date AS last_update,
        '{Trailers,"Deleted Scenes"}' AS special_features,
        '''ace'':1 ''administr'':9 ''ancient'':19 ''astound'':4 ''car'':17 ''china'':20 ''databas'':8 ''epistl'':5 ''explor'':12 ''find'':15 ''goldfing'':2 ''must'':14' AS fulltext 

    UNION ALL 
    
    SELECT 'BLACK PREY' AS title,
       'After splitting with the Joker, Harley Quinn joins superheroines'
                        AS description, 
        2020 AS release_year,
        1 AS language_id,
        NULL AS original_language_id,
        21 AS rental_duration,
        19.99 AS rental_rate,
        50 AS length,
        18.99 AS replacement_cost,
        'NC-17' AS  rating,
        current_date AS last_update,
        '{Trailers,"Deleted Scenes"}' AS special_features,
        '''adapt'':1 ''astound'':4 ''baloon'':19 ''car'':11 ''factori'':20 ''hole'':2 ''lumberjack'':8,16 ''must'':13 ''reflect'':5 ''sink'':14' AS fulltext
) tt
        
WHERE title  NOT IN (
    SELECT title 
    FROM public.film

);
--
--VALUES (, , 2017, 1, NULL, 1, 4.99, 86, 20.99, 'PG', current_date , '{"Deleted Scenes","Behind the Scenes"}', '''academi'':1 ''battl'':15 ''canadian'':20 ''dinosaur'':2 ''drama'':5 ''epic'':4 ''feminist'':8 ''mad'':11 ''must'':14 ''rocki'':21 ''scientist'':12 ''teacher'':17'),
--        ('THE OLD GUARD', 'A group of mercenaries, all centuries-old immortals with the ablity to heal themselves, discover someone is onto their secret.', 2020, 1, NULL, 2, 9.99, 48, 12.99, 'G', current_date, '{Trailers,"Deleted Scenes"}', '''ace'':1 ''administr'':9 ''ancient'':19 ''astound'':4 ''car'':17 ''china'':20 ''databas'':8 ''epistl'':5 ''explor'':12 ''find'':15 ''goldfing'':2 ''must'':14'),
--        ('BLACK PREY', 'After splitting with the Joker, Harley Quinn joins superheroines', 2020, 1, NULL, 21, 19.99, 50, 18.99, 'NC-17', current_date , '{Trailers,"Deleted Scenes"}', '''adapt'':1 ''astound'':4 ''baloon'':19 ''car'':11 ''factori'':20 ''hole'':2 ''lumberjack'':8,16 ''must'':13 ''reflect'':5 ''sink'':14');


-- Add actors who play leading roles in your favorite movies to 'actor' and 'film_actor' tables
-- (6 or more actors in total).
   

INSERT INTO public.actor (first_name, last_name)

SELECT first_name, last_name 
FROM 
(
    SELECT 'ALVARO' AS first_name,
            'MORTE' AS last_name
            
    UNION ALL 
    SELECT 'URSULA' AS first_name,
            'CORBERO' AS last_name
            
    UNION ALL 
    SELECT 'BOB' AS first_name,
            'HARRIS' AS last_name
            
    UNION ALL 
    SELECT 'ANNIE' AS first_name,
            'NIGHTINGALE' AS last_name
            
    UNION ALL 
    SELECT 'JESSE' AS first_name,
            'WILLIAMS' AS last_name
            
    UNION ALL 
    SELECT 'MORGAN' AS first_name,
            'FREEMAN' AS last_name
    
) ss
WHERE (first_name,last_name) NOT IN (
    SELECT first_name, last_name  
    FROM public.actor

);

INSERT INTO public.film_actor (actor_id, film_id)

SELECT actor_id, film_id 
FROM 
(
SELECT a.actor_id, f.film_id
FROM actor a, film f 
WHERE (first_name, last_name) IN (('ALVARO','MORTE'), ('URSULA', 'CORBERO'))
AND upper(f.title) = ('MONEY HEIST')

UNION ALL

SELECT a.actor_id, f.film_id 
FROM actor a, film f 
WHERE (first_name, last_name) IN (('BOB', 'HARRIS') , ('ANNIE', 'NIGHTINGALE'))
AND upper(f.title) = ('THE OLD GUARD')

UNION ALL

SELECT a.actor_id, f.film_id 
FROM actor a, film f 
WHERE (first_name, last_name) IN (('JESSE', 'WILLIAMS'), ('MORGAN', 'FREEMAN'))
AND upper(f.title) = ('BLACK PREY')

) ww

WHERE (actor_id, film_id) NOT IN (
    SELECT actor_id, film_id
    FROM public.film_actor 
);

-- Add your favorite movies to any store's inventory.

INSERT INTO public.inventory (film_id, store_id)
SELECT f.film_id, s.store_id
FROM public.film f, public.store s 
WHERE f.title IN ('MONEY HEIST', 'THE OLD GUARD', 'BLACK PREY')
AND s.store_id = 1
AND film_id  NOT IN (
    SELECT film_id
    FROM public.inventory 
);

-- Alter any existing customer in the database who has at least 43 rental and 43 payment records. 
-- Change his/her personal data to yours (first name, last name, address, etc.). 
-- Do not perform any updates on 'address' table, as it can impact multiple records with the same address. 
-- Change customer's create_date value to current_date.
    

INSERT INTO public.address (address,district, city_id, postal_code, phone, last_update) 

SELECT address,district, city_id, postal_code, phone, last_update
FROM 
(
    SELECT '9 Griciupio g.' AS address,
            'Vilnius' AS district,
            (SELECT city_id FROM city WHERE upper(city) = 'VILNIUS' ) AS city_id,
            56349 AS postal_code,
            861972613 AS phone,
            current_date AS last_update
            
) asd

WHERE address NOT IN (
    SELECT address 
    FROM public.address
);

--VALUES ('9 Griciupio g.', 'Vilnius', 
--        (SELECT city_id FROM city WHERE upper(city) = 'VILNIUS' ), 56349, 861972613, current_date);

UPDATE public.customer c
SET store_id = 1,
    first_name = 'DAMILOLA',
    last_name = 'AKINGBESOTE',
    email = 'DAMILOLA.AKINGBESOTE@sakilacustomer.org',
    create_date = current_date,
    address_id  = (SELECT address_id FROM address 
                    WHERE address = '9 Griciupio g.')
WHERE c.customer_id IN (SELECT r.customer_id 
                    FROM rental r
                    GROUP BY r.customer_id
                    HAVING count(r.customer_id) >= 43
                    
                    UNION 
                    
                    SELECT p.customer_id
                    FROM payment p
                    GROUP BY customer_id 
                    HAVING count(p.customer_id) >= 43
                    LIMIT 1)
RETURNING *;
                
--Remove any records related to you (as a customer) from all tables except 'Customer' and 'Inventory'
WITH del_records AS
(SELECT  c.customer_id  
FROM public.customer c 
WHERE upper(c.first_name) = 'DAMILOLA'
AND upper(c.last_name) = 'AKINGBESOTE')

DELETE FROM public.payment p

WHERE EXISTS (
                SELECT customer_id  
                FROM del_records dr       
                WHERE p.customer_id  = dr.customer_id 
            )
RETURNING *;

WITH del_records AS
(SELECT  c.customer_id  
FROM public.customer c 
WHERE upper(c.first_name) = 'DAMILOLA'
AND upper(c.last_name) = 'AKINGBESOTE')


DELETE FROM public.rental r

WHERE EXISTS (
                SELECT customer_id  
                FROM del_records dr       
                WHERE r.customer_id  = dr.customer_id 
            )
RETURNING *;

              

-- Rent your favorite movies from the store they are in and pay for them 
--(add corresponding records to the database to represent this activity)
-- (Note: to insert the payment_date into the table payment, you can create a new partition 
-- (see the scripts to install the training database) or add records for the first half of 2017)


-- renting my favorite movies

INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT f.last_update AS rental_date,
       i.inventory_id,
       
       (SELECT  c.customer_id  
        FROM public.customer c 
        WHERE upper(c.first_name) = 'DAMILOLA'
        AND upper(c.last_name) = 'AKINGBESOTE'
        ORDER BY RANDOM()
        LIMIT 1),

       f.last_update + INTERVAL '1 week' * f.rental_duration,
       
       (SELECT s.manager_staff_id
       FROM public.store s
       JOIN customer c2
       ON c2.store_id = s.store_id
       WHERE upper(c2.first_name) = 'DAMILOLA'
        AND upper(c2.last_name) = 'AKINGBESOTE'
        ORDER BY RANDOM()
        LIMIT 1),

        current_date 

FROM film f
JOIN inventory i 
ON i.film_id = f.film_id 
WHERE f.title IN ('MONEY HEIST', 'THE OLD GUARD', 'BLACK PREY')
AND f.last_update NOT IN (
    SELECT rental_date
    FROM public.rental 
)
RETURNING *;

-- creating payment partition

CREATE TABLE IF NOT EXISTS public.payment_p2022 PARTITION OF public.payment 
    FOR VALUES FROM ('2022-01-01 00:00:00+03') TO ('2022-12-31 00:00:00+03');

ALTER TABLE public.payment_p2022 OWNER TO postgres;
GRANT ALL ON TABLE public.payment_p2022 TO postgres;

ALTER TABLE public.payment_p2022 
    ADD PRIMARY KEY (payment_id),
    ADD CONSTRAINT cust_fk FOREIGN KEY (customer_id) REFERENCES customer (customer_id),
    ADD CONSTRAINT staff_fk FOREIGN KEY (staff_id) REFERENCES staff (staff_id),
    ADD CONSTRAINT rent_fk FOREIGN KEY (rental_id) REFERENCES rental (rental_id);

-- paying for my movies

INSERT INTO public.payment_p2022  (customer_id, staff_id, rental_id, amount, payment_date)

SELECT c.customer_id, r.staff_id, r.rental_id, 
        (CASE 
            -- if the return date is exceeded i.e the person did not return the film on time
            -- then, the amount charged should be the price + number of days exceeded multiplied by 1.50 euros
            WHEN (r.rental_date + INTERVAL '1 week' * f.rental_duration) > r.return_date 
                THEN (f.rental_rate * f.rental_duration) +  
                (EXTRACT(DAY FROM (r.rental_date + INTERVAL '1 week' * f.rental_duration) - r.return_date) * 1.50)
            -- if the movie was returned on time, then the normal price is charged
            WHEN (r.rental_date + INTERVAL '1 week' * f.rental_duration) = r.return_date 
                THEN f.rental_rate * f.rental_duration
            -- if the movie is not returned, then an amount for replacement cost is added to the price
            WHEN r.return_date = NULL
                THEN f.rental_rate * f.rental_duration + f.replacement_cost
        END
        ) AS price,
        current_date
FROM public.customer c
JOIN public.rental r 
ON c.customer_id = r.customer_id 
JOIN public.inventory i 
ON i.inventory_id = r.inventory_id 
JOIN public.film f  
ON f.film_id = i.film_id 
WHERE c.customer_id IN (SELECT  c.customer_id  
                        FROM public.customer c 
                        WHERE upper(c.first_name) = 'DAMILOLA'
                        AND upper(c.last_name) = 'AKINGBESOTE') 
AND c.customer_id NOT IN (
    SELECT customer_id
    FROM public.payment_p2022
)
RETURNING *;



     
