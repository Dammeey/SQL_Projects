-- Top-3 most selling movie categories of all time 
-- and total dvd rental income for each category.
-- Only consider dvd rental customers from the USA

SELECT c."name", sum(p.amount) as rental_income
FROM public.category c
JOIN public.film_category fc
ON c.category_id = fc.category_id
JOIN public.inventory i 
ON fc.film_id = i.film_id 
JOIN public.rental r 
ON i.inventory_id = r.inventory_id
JOIN public.payment p
ON r.rental_id = p.rental_id 
WHERE r.customer_id in (SELECT c2.customer_id 
						FROM public.customer c2
						JOIN public.address a
						ON a.address_id = c2.address_id
						JOIN public.city c3
						ON c3.city_id = a.city_id
						JOIN public.country c4
						ON c4.country_id = c3.country_id
						WHERE c4.country = 'United States')

GROUP BY c."name"  
ORDER BY rental_income DESC 																						
FETCH FIRST 3 ROWS WITH TIES;  


-- For each client, 
-- display a list of horrors that he had ever rented (in one column, separated by commas), 
-- and the amount of money that he paid for it

SELECT  cl."name" AS name,
		--c2.first_name || ' ' || c2.last_name AS client, 
		STRING_AGG(DISTINCT f.title, ',') AS rented_horror_movies, 
		SUM(p.amount) AS amount_paid
FROM public.film_category fc
JOIN public.category c 
ON fc.category_id = c.category_id 
JOIN public.film f 
ON fc.film_id = f.film_id 
JOIN public.inventory i 
ON fc.film_id  = i.film_id 
JOIN public.rental r 
ON r.inventory_id = i.inventory_id 
JOIN public.payment p  
ON p.rental_id = r.rental_id 
JOIN public.customer c2 
ON c2.customer_id = r.customer_id 
JOIN public.customer_list cl 
ON r.customer_id = cl.id
WHERE c.name = 'Horror'
GROUP BY cl."name";
