/*. Implement role-based authentication model for dvd_rental database:
 * • Create group roles: DB developer, backend tester (read-only), customer (read-only for film and actor)
 * • Create personalized role for any customer already existing in the dvd_rental database. 
 * Role name must be client_{first_name}_{last_name} (omit curly brackets). 
 * Customer's payment and rental history must not be empty.
 *  • Assign proper privileges to each role.
 * • Verify that all roles are working as intended.

*/

--REASSIGN OWNED BY db_developer TO postgres;  -- or some other trusted role
--DROP OWNED BY db_developer;
--DROP ROLE db_developer;

CREATE ROLE db_developer WITH 
    CREATEDB
    CREATEROLE
    INHERIT
    LOGIN
    REPLICATION
    BYPASSRLS
    CONNECTION LIMIT -1;

GRANT ALL PRIVILEGES ON DATABASE postgres TO db_developer;
GRANT USAGE ON SCHEMA public TO db_developer;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO db_developer;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO db_developer;

-- testing the db_developer role
SET ROLE db_developer;

SELECT current_user;

SELECT * FROM public.rental;

INSERT INTO public."language" (name)
SELECT 'Lithuanian' AS name;

SELECT * FROM public."language";

DELETE FROM public."language" 
WHERE "name" = 'Lithuanian';

--creating role backend_tester
CREATE ROLE backend_tester;
GRANT CONNECT ON DATABASE postgres TO backend_tester;
GRANT USAGE ON SCHEMA public TO backend_tester;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO backend_tester;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO backend_tester;

--SET ROLE postgres;
-- testing the backend_tester role
SET ROLE backend_tester;

SELECT current_user;

SELECT * FROM public.actor;

--creating role customer
CREATE ROLE customer;
GRANT CONNECT ON DATABASE postgres TO customer;
GRANT USAGE ON SCHEMA public TO customer;
GRANT SELECT ON TABLE public.film TO customer;
GRANT SELECT ON TABLE public.actor TO customer;

--testing the customer role
SET ROLE customer;

SELECT current_user;

SELECT * FROM public.film;
SELECT * FROM public.actor;

--DROP ROLE customer;


/* • Create personalized role for any customer already existing in the dvd_rental database. 
 * Role name must be client_{first_name}_{last_name} (omit curly brackets). 
 * Customer's payment and rental history must not be empty.
 */

SELECT * --c.first_name || ' ' || c.last_name 
FROM public.customer c 
WHERE EXISTS (SELECT 1
                FROM rental r  
                WHERE r.customer_id = c.customer_id)
AND EXISTS (SELECT 1
        FROM payment p
        WHERE p.customer_id = c.customer_id);
        


--creating personalized group role
--CREATE ROLE client_group;
--GRANT CONNECT ON DATABASE postgres TO client_group;
--GRANT USAGE ON SCHEMA public TO client_group;
--GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO client_group;
--GRANT SELECT ON ALL TABLES IN SCHEMA public TO client_group;

--creating personalized role - client_holly_fox
CREATE ROLE client_holly_fox;
GRANT customer TO client_holly_fox;
GRANT SELECT ON TABLE public.rental TO client_holly_fox; 
GRANT SELECT ON TABLE public.payment TO client_holly_fox; 
GRANT SELECT ON TABLE public.customer TO client_holly_fox; 

--testing the client_holly_fox role
SET ROLE client_holly_fox;

SELECT current_user;

SELECT * FROM public.payment;
SELECT * FROM public.actor;

--REASSIGN OWNED BY client_holly_fox TO postgres;  -- or some other trusted role
--DROP OWNED BY client_holly_fox;
--DROP ROLE client_holly_fox;

--ALTER TABLE public.rental DISABLE ROW LEVEL SECURITY;
--ALTER TABLE public.payment DISABLE ROW LEVEL SECURITY;

--SET ROLE postgres;