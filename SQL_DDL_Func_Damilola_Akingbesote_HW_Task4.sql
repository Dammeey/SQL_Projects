--  SOLUTION 1.

/* What operations do the following functions perform: 
 * You can find these functions in dvd_rental database.
film_in_stock - The function takes in 2 parameters film id and store id, 
                checks if the film id and store id are present in the inventory table,
                it then returns the inventory id 
                
film_not_in_stock - The function takes in 2 parameters film id and store id, 
                checks if the film id and store id are not present in the inventory table,
                it then returns the inventory id ,
                
inventory_in_stock - The function takes in parameter inventory id,
                     it does a count of the inventory_id in the rental table,
                     checks if the number of rentals is 0, if it is 0 then it returns TRUE(the item is in stock).
                     Secondly, it does a count of the rental_id in inventory table
                     where the return date is null.
                     if the count of rentals eith no return date is greater than 0, 
                     then it returns FALSE (i.e item is not in stock)
                     otherwise, it returns TRUE (i.e item is in stock)
                     
get_customer_balance - The function takes in parameter customer_id and effective_date,
                        Firstly, it calculates the rental fees for all previous rentals excluding null values,
                        Secondly, it uses the return_date and rental_date to calculate if the movies are overdue,
                        if the movies are overdue, it computes the number of days overdue multiplied by 1 dollar,
                        Thirdly, all the previous payments made by the customer are added together and
                        Lastly, the customer balance is calculated by adding the rental fees and overdue fees together
                        and subtracting the customer's previous payments from it
                         
inventory_held_by_customer - The function takes in parameter inventory_id and then 
                            returns the customer_id of customers with the inventory_id and no return_date, 
                            
rewards_report - The function takes in arguments min_monthly_purchases and min_dollar_amount
                and returns the customer information of all customers that meet the monthly 
                purchase requirements of in the last month
, 

last_day? - The function takes in an argument in form of a timestamp and then calls an immutable function
            that returns the same results given the same arguments forever. 
            The function returns the last day in the month of the provided timestamp.
            


*/

--SOLUTION 2

-- Why does ‘rewards_report’ function return 0 rows? 
-- Correct and recreate the function, so that it's able to return rows properly


-- The function is returning 0 rows because it last_month_start variable is starting from 
-- 3 months back which has no records in the payments table.
-- I have corrected the last_month_start variable to start from 1 month interval instead of 3

CREATE OR REPLACE FUNCTION public.rewards_report(min_monthly_purchases integer, min_dollar_amount_purchased numeric)
 RETURNS SETOF customer
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    last_month_start DATE;
    last_month_end DATE;
rr RECORD;
tmpSQL TEXT;
BEGIN

    /* Some sanity checks... */
    IF min_monthly_purchases = 0 THEN
        RAISE EXCEPTION 'Minimum monthly purchases parameter must be > 0';
    END IF;
    IF min_dollar_amount_purchased = 0.00 THEN
        RAISE EXCEPTION 'Minimum monthly dollar amount purchased parameter must be > $0.00';
    END IF;
    
    -- Here is my correction, the last_month_start has been changed from 3 months to 1 month
    last_month_start := CURRENT_DATE - '1 month'::interval;
    last_month_start := to_date((extract(YEAR FROM last_month_start) || '-' || extract(MONTH FROM last_month_start) || '-01'),'YYYY-MM-DD');
    last_month_end := LAST_DAY(last_month_start);

    /*
    Create a temporary storage area for Customer IDs.
    */
    CREATE TEMPORARY TABLE tmpCustomer (customer_id INTEGER NOT NULL PRIMARY KEY);

    /*
    Find all customers meeting the monthly purchase requirements
    */

    tmpSQL := 'INSERT INTO tmpCustomer (customer_id)
        SELECT p.customer_id
        FROM payment AS p
        WHERE DATE(p.payment_date) BETWEEN '||quote_literal(last_month_start) ||' AND '|| quote_literal(last_month_end) || '
        GROUP BY customer_id
        HAVING SUM(p.amount) > '|| min_dollar_amount_purchased || '
        AND COUNT(customer_id) > ' ||min_monthly_purchases ;

    EXECUTE tmpSQL;

    /*
    Output ALL customer information of matching rewardees.
    Customize output as needed.
    */
    FOR rr IN EXECUTE 'SELECT c.* FROM tmpCustomer AS t INNER JOIN customer AS c ON t.customer_id = c.customer_id' LOOP
        RETURN NEXT rr;
    END LOOP;

    /* Clean up */
    tmpSQL := 'DROP TABLE tmpCustomer';
    EXECUTE tmpSQL;

RETURN;
END
$function$
;

SELECT * 
FROM public.rewards_report(20, 300)


-- SOLUTION 3

-- Is there any function that can potentially be removed from the dvd_rental codebase? 
-- If so, which one and why?

/*
 * The group_concat function can be potentially removed from the dvd_rental database as it just
 * an aggregate function that is doing nothing.
 * 
 */
 */

 
 -- SOLUTION 4
 
-- * The ‘get_customer_balance’ function describes the business requirements 
-- for calculating the client balance. 
-- Unfortunately, not all of them are implemented in this function. 
-- Try to change function using the requirements from the comments.

 CREATE OR REPLACE FUNCTION public.get_customer_balance(p_customer_id integer, p_effective_date timestamp with time zone)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
       --#OK, WE NEED TO CALCULATE THE CURRENT BALANCE GIVEN A CUSTOMER_ID AND A DATE
       --#THAT WE WANT THE BALANCE TO BE EFFECTIVE FOR. THE BALANCE IS:
       --#   1) RENTAL FEES FOR ALL PREVIOUS RENTALS
       --#   2) ONE DOLLAR FOR EVERY DAY THE PREVIOUS RENTALS ARE OVERDUE
       --#   3) IF A FILM IS MORE THAN RENTAL_DURATION * 2 OVERDUE, CHARGE THE REPLACEMENT_COST
       --#   4) SUBTRACT ALL PAYMENTS MADE BEFORE THE DATE SPECIFIED
DECLARE
    v_rentfees DECIMAL(5,2); --#FEES PAID TO RENT THE VIDEOS INITIALLY
    v_overfees INTEGER;      --#LATE FEES FOR PRIOR RENTALS
    v_replace_cost DECIMAL(5,2); --#REPLACEMENT COST FOR OVERDUE
    v_payments DECIMAL(5,2); --#SUM OF PAYMENTS MADE PREVIOUSLY
BEGIN
    SELECT COALESCE(SUM(film.rental_rate),0) INTO v_rentfees
    FROM film, inventory, rental
    WHERE film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_date <= p_effective_date
      AND rental.customer_id = p_customer_id;

    SELECT COALESCE(SUM(CASE 
                           WHEN (rental.return_date - rental.rental_date) > (film.rental_duration * '1 day'::interval)
                           THEN EXTRACT(epoch FROM ((rental.return_date - rental.rental_date) - (film.rental_duration * '1 day'::interval)))::INTEGER / 86400 -- * 1 dollar
                           ELSE 0
                        END),0) 
    INTO v_overfees
    FROM rental, inventory, film
    WHERE film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_date <= p_effective_date
      AND rental.customer_id = p_customer_id;
    
    
    SELECT COALESCE(SUM(CASE
                            WHEN rental.return_date > (rental.return_date + film.rental_duration * INTERVAL '2 days')--(film.rental_duration * INTERVAL '1 day') 
                            THEN film.replacement_cost 
                            ELSE 0
                        END), 0) 
    INTO v_replace_cost
    FROM rental, inventory, film
    WHERE film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_date <= p_effective_date
      AND rental.customer_id = p_customer_id;
  
    SELECT COALESCE(SUM(payment.amount),0) INTO v_payments
    FROM payment
    WHERE payment.payment_date <= p_effective_date
    AND payment.customer_id = p_customer_id;

    RETURN v_rentfees + v_overfees + v_replace_cost - v_payments;
END
$function$
;

SELECT *
FROM public.get_customer_balance(172, '2022-01-01');


-- SOLUTION 5

-- * How do ‘group_concat’ and ‘_group_concat’ functions work? 
-- (database creation script might help) Where are they used?

/* The _group_concat function checks if the arguments do not have null values and joins them together.
 * If one of the arguments is a null value, it returns the other not-null argument
 * The group_concat aggregate function on the other hand uses the _group_concat function as a 
 * state transition function and aggregates all the text as a list
 * 
 * The functions were used in the actor_info, film_list, nicer_but_slower_film_list VIEWS
 */


-- SOLUTION 6

-- * What does ‘last_updated’ function do? Where is it used? 
/* The last_updated function is used to set the last_update value to the current timestamp
 * 
 * It  is used to trigger and insert the current timestamp values of the last_update column 
 * in the database tables 
 * 
 */

-- SOLUTION 7
/* * What is tmpSQL variable for in ‘rewards_report’ function? 
 * Can this function be recreated without EXECUTE statement and dynamic SQL?
 * Why?
 * 
 * The tmpSQL is used for inserting the records of customers that meet the 
 * monthly purchase requirements in the last month into the temporary tmpCustomer table
 * 
 * Yes, the function can be recreated without EXECUTE statement and dynamic SQL since the
 * SQL statements that an application has to execute are known at the time the application is written
 */
