-- Read about row-level security (https://www.postgresql.org/docs/12/ddl-rowsecurity.html) 
-- and configure it for your database, 
-- so that the customer can only access his own data in "rental" and "payment" tables 
-- (verify using the personalized role you previously created).

--CREATE TABLE accounts (manager text, company text, contact_email text);

ALTER TABLE public.rental ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment ENABLE ROW LEVEL SECURITY;                 
                        
                        
--more general policy
CREATE POLICY client_rental
ON public.rental FOR SELECT
TO client_group
USING (customer_id = (SELECT customer_id
                        FROM customer
                        WHERE 'client'||'_'||lower(first_name)||'_'||lower(last_name) like current_user));
                        
CREATE POLICY client_payment
ON public.payment FOR SELECT
TO client_group
USING (customer_id = (SELECT customer_id
                        FROM customer
                        WHERE 'client'||'_'||lower(first_name)||'_'||lower(last_name) like current_user));

--testing the client_holly_fox role
SET ROLE client_holly_fox;

SELECT current_user;

SELECT * FROM public.rental;
SELECT * FROM public.payment;

--SET ROLE postgres;
--DROP POLICY client_rental ON public.rental;
--DROP POLICY client_payment ON public.payment;