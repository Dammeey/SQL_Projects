-- All comedy movies released between 2000 and 2004, alphabetical

SELECT  f.title, f.release_year, c."name" -- selecting the appropriate columns
FROM public.film f									-- from the films table
INNER JOIN public.film_category fc  		-- joined the columns on the film category and category table
ON f.film_id = fc.film_id 
INNER JOIN public.category c 
ON fc.category_id = c.category_id 
WHERE  c."name" = 'Comedy' AND f.release_year BETWEEN 2000 AND 2004 -- filtered the data by comedy and the release year
ORDER BY f.title;					--order the data by the title in ascending order


-- Revenue of every rental store for year 2017 (columns: address and address2 – as one column, revenue)
SELECT  CONCAT(a.address, ' ', a.address2) AS rental_store, sum(amount) as revenue -- selecting the appropriate columns and also adding up the amounts column
FROM public.payment p															-- from the payment table
INNER JOIN public.rental r 						-- joinning the rental table with the payments table using rental_id
ON p.rental_id = r.rental_id 						
INNER JOIN public.customer c 
ON c.customer_id = r.customer_id
INNER JOIN public.store s 
ON s.store_id = c.store_id 
INNER JOIN public.address a 
ON s.address_id = a.address_id 
WHERE EXTRACT(YEAR FROM p.payment_date) = 2017 -- filtering the year with 2017
GROUP BY rental_store;							-- grouping the year with rental store


-- Top-3 actors by number of movies they took part in 
-- (columns: first_name, last_name, number_of_movies, 
-- sorted by number_of_movies in descending order)
--SELECT a.first_name, a.last_name, nn.number_of_movies			
--FROM public.actor a
--JOIN (SELECT fa.actor_id, COUNT(*) AS number_of_movies
--			FROM public.film_actor fa  
--			GROUP BY fa.actor_id
--			) nn
--ON a.actor_id = nn.actor_id
--WHERE a.actor_id = nn.actor_id
--ORDER BY nn.number_of_movies desc
--FETCH FIRST 3 ROWS WITH TIES;

SELECT a.first_name, a.last_name, COUNT(*) AS number_of_movies         
FROM public.actor a
JOIN public.film_actor fa            
ON a.actor_id = fa.actor_id
GROUP BY fa.actor_id, a.first_name, a.last_name
ORDER BY number_of_movies DESC
FETCH FIRST 3 ROWS WITH TIES;

-- Number of comedy, horror and action movies per year 
-- (columns: release_year, number_of_action_movies, number_of_horror_movies, number_of_comedy_movies), 
-- sorted by release year in descending order 

SELECT f.release_year,
		SUM(CASE WHEN c."name" = 'Action' THEN 1 ELSE 0 END) AS number_of_action_movies,
    	SUM(case WHEN c."name" = 'Horror' THEN 1 ELSE 0 END) AS number_of_horror_movies,
    	SUM(case WHEN c."name" = 'Comedy' THEN 1 ELSE 0 END) AS number_of_comedy_movies
FROM public.film f 
INNER JOIN public.film_category fc 
ON f.film_id = fc.film_id 
INNER JOIN public.category c 
ON fc.category_id = c.category_id 
WHERE c."name" IN ('Comedy', 'Horror','Action')
GROUP BY f.release_year
ORDER BY f.release_year DESC;


-- Which staff members made the highest revenue 
-- for each store and 
-- deserve a bonus for 2017 year?
WITH staff_bonus AS 
(SELECT s.store_id, --CONCAT(a.address, ' ', a.address2) AS store_address,
                    s.first_name || ' ' || s.last_name as staff_member, 
                    SUM(p.amount) as revenue_made
--FROM public.address a
FROM public.staff s 
JOIN public.payment p
ON s.staff_id = p.staff_id
--JOIN address a
--ON a.address_id = s.address_id 
WHERE EXTRACT(YEAR FROM p.payment_date) = 2017 
AND s.store_id IN (SELECT s.store_id
					FROM public.payment p2
					JOIN public.rental r 
					ON p2.rental_id = r.rental_id 
					JOIN public.customer c 
					ON p2.customer_id = r.customer_id 
					JOIN public.store s2 
					ON s2.store_id = c.store_id 
					GROUP BY s.store_id
					)
GROUP BY s.store_id, staff_member)

SELECT DISTINCT ON (store_id) sb.store_id,
                CONCAT(a.address, ' ', a.address2) AS store_address,
                    sb.staff_member, sb.revenue_made
FROM staff_bonus sb
JOIN public.store s 
ON s.store_id = sb.store_id
JOIN public.address a 
ON s.address_id = a.address_id
ORDER BY store_id, revenue_made DESC; 

-- Which 5 movies were rented more than others and what's expected audience age for those movies?
SELECT f.title, COUNT(r.inventory_id) AS rental_times, f.rating
FROM public.film f 
INNER JOIN public.inventory i 
ON f.film_id = i.film_id
INNER JOIN public.rental r 
ON r.inventory_id = i.inventory_id 
GROUP BY f.title, f.rating 
ORDER BY rental_times DESC
FETCH FIRST 5 ROWS WITH TIES;

-- Which actors/actresses didn't act for a longer period of time than others?
SELECT a.first_name || '' || a.last_name as actors_actresses, 
		max(f.release_year) - min(f.release_year) as acting_period, count(fa.film_id) as num_of_movies
FROM public.actor a 
INNER JOIN film_actor fa  
ON fa.actor_id  = a.actor_id 
INNER JOIN film f 
ON f.film_id = fa.film_id 
GROUP BY actors_actresses
ORDER BY acting_period;

WITH movie_release AS 
(SELECT fa.actor_id, f.release_year
FROM public.film_actor fa 
JOIN public.film f 
ON f.film_id = fa.film_id
ORDER BY fa.actor_id,release_year DESC),

movie_break AS 
(SELECT  DISTINCT mr.actor_id, mr.release_year, max(mr2.release_year) AS following_year,
                mr.release_year - max(mr2.release_year) AS break_period
FROM movie_release mr
JOIN movie_release mr2
ON mr.actor_id = mr2.actor_id AND mr.release_year > mr2.release_year
GROUP BY mr.actor_id, mr.release_year
ORDER BY mr.actor_id, mr.release_year DESC)

SELECT a.first_name || ' ' || a.last_name AS actors, max(mb.break_period) AS break_period
FROM movie_break mb
JOIN public.actor a
ON mb.actor_id = a.actor_id 
GROUP BY actors, mb.actor_id
ORDER BY break_period DESC
FETCH FIRST 1 ROW ONLY;
 





