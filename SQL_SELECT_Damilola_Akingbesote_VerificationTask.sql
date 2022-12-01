-- Top-3 most selling movie categories of all time 
-- and total dvd rental income for each category.
-- Only consider dvd rental customers from the USA

select c."name", sum(p.amount) as rental_income
from category c
join film_category fc
on c.category_id = fc.category_id
join inventory i 
on fc.film_id = i.film_id 
join rental r 
on i.inventory_id = r.inventory_id
join payment p
on r.rental_id = p.rental_id 
where r.customer_id in (select c2.customer_id 
						from customer c2
						join address a
						on a.address_id = c2.address_id
						join city c3
						on c3.city_id = a.city_id
						join country c4
						on c4.country_id = c3.country_id
						where c4.country = 'United States')

group by c."name"  
order by rental_income desc																						
limit 3;  


-- For each client, 
-- display a list of horrors that he had ever rented (in one column, separated by commas), 
-- and the amount of money that he paid for it

select  c2.first_name || ' ' || c2.last_name as client, 
		string_agg(distinct f.title, ',') as rented_horror_movies, 
		sum(p.amount) as amount_paid
FROM rental r
left join customer c2 
on c2.customer_id = r.customer_id 
left join inventory i 
on r.inventory_id = i.inventory_id 
left join film f 
on i.film_id = f.film_id 
left join film_category fc
on f.film_id = fc.film_id 
left join category c 
on fc.category_id = c.category_id 
left join payment p 
on p.customer_id = c2.customer_id 
where c.name = 'Horror'
group by client;
