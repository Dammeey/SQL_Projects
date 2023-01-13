CREATE DATABASE appliances_store;


CREATE SCHEMA IF NOT EXISTS hs_appliances_store AUTHORIZATION postgres;



	CREATE TABLE IF NOT EXISTS hs_appliances_store.brand
    
	    (
	        id BIGSERIAL PRIMARY KEY,
	        brand_name VARCHAR(255) NOT NULL
	       
	    );
	   
	CREATE TABLE IF NOT EXISTS hs_appliances_store.supplier
	    
	    (
	        id BIGSERIAL PRIMARY KEY,
	        first_name VARCHAR(55) NOT NULL,
	        last_name VARCHAR(55) NOT NULL,
	        address VARCHAR(255) NOT NULL,
	        contact_no BIGINT NOT NULL
	    );
	   
	   
	CREATE TABLE IF NOT EXISTS hs_appliances_store.category_type
    
	    (
	        id BIGSERIAL PRIMARY KEY,	        
	        type_name VARCHAR(255) NOT NULL
	        
	    );
	   
	CREATE TABLE IF NOT EXISTS hs_appliances_store.category
    
	    (
	        id BIGSERIAL PRIMARY KEY,
	        supplier_id BIGINT NOT NULL REFERENCES hs_appliances_store.supplier,   
	        category_name VARCHAR(255) NOT NULL,
	        category_type BIGINT NOT NULL REFERENCES hs_appliances_store.category_type
	        
	        
	    );
	   
	   
	CREATE TABLE IF NOT EXISTS hs_appliances_store.product
	    
	    (
	        id BIGSERIAL PRIMARY KEY,
	        category_id BIGINT NOT NULL REFERENCES hs_appliances_store.category,
	        description TEXT NOT NULL,
	        product_name VARCHAR(255) NOT NULL,
	        brand BIGINT NOT NULL REFERENCES hs_appliances_store.brand,
	        supplier BIGINT NOT NULL REFERENCES hs_appliances_store.supplier,
	        price BIGINT NOT NULL
	        
	        
	    );
	   
	
	   
	CREATE TABLE IF NOT EXISTS hs_appliances_store.orders
    
	    (
	        id BIGSERIAL PRIMARY KEY,
	        order_date DATE NOT NULL
	    );
	   
	   
	CREATE TABLE IF NOT EXISTS hs_appliances_store.order_detail
    
	    (
	        id BIGSERIAL PRIMARY KEY,
	        product_id BIGINT NOT NULL REFERENCES hs_appliances_store.product,
	        order_id BIGINT NOT NULL REFERENCES hs_appliances_store.orders,   
	        product_quantity BIGINT NOT NULL
	        
	        
	    );
	   
	
   
	CREATE TABLE IF NOT EXISTS hs_appliances_store.product_supplier
    
	    (
	        id BIGSERIAL PRIMARY KEY,
	        product_id BIGINT NOT NULL REFERENCES hs_appliances_store.product,
	        supplier_id BIGINT NOT NULL REFERENCES hs_appliances_store.supplier,   
	        supply_date DATE NOT NULL
	        
	        
	    );
   
  
	CREATE TABLE IF NOT EXISTS hs_appliances_store.customer
	    
	    (
	        id BIGSERIAL PRIMARY KEY,
	        first_name VARCHAR(55) NOT NULL,
	        last_name VARCHAR(55) NOT NULL,
	        address VARCHAR(255) NOT NULL,
	        contact_no BIGINT NOT NULL
	    );
	   
	CREATE TABLE IF NOT EXISTS hs_appliances_store.purchase
    
	    (
	        id BIGSERIAL PRIMARY KEY,
	        product_id BIGINT NOT NULL REFERENCES hs_appliances_store.product,
	        customer_id BIGINT NOT NULL REFERENCES hs_appliances_store.customer,   
	        purchase_date DATE NOT NULL
	        
	        
	    );
	   
	
	   
	CREATE TABLE IF NOT EXISTS hs_appliances_store.supplier_category
    
	    (
	        id BIGSERIAL PRIMARY KEY,
	        category_id BIGINT NOT NULL REFERENCES hs_appliances_store.category,
	        supplier_id BIGINT NOT NULL REFERENCES hs_appliances_store.supplier,   
	        supply_date DATE NOT NULL
	        
	        
	    );
	   
	CREATE TABLE IF NOT EXISTS hs_appliances_store.payment
    
	    (
	        id BIGSERIAL PRIMARY KEY,
	        customer_id BIGINT NOT NULL REFERENCES hs_appliances_store.customer,
	        amount BIGINT NOT NULL,   
	        transaction_date DATE NOT NULL,
	        status VARCHAR(20)
	        
	        
	    );
	   
	   
	   
ALTER TABLE hs_appliances_store.orders
ALTER COLUMN order_date SET DEFAULT CURRENT_DATE;

ALTER TABLE hs_appliances_store.product_supplier
ALTER COLUMN supply_date SET DEFAULT CURRENT_DATE;

ALTER TABLE hs_appliances_store.purchase
ALTER COLUMN purchase_date SET DEFAULT CURRENT_DATE;

ALTER TABLE hs_appliances_store.supplier_category
ALTER COLUMN supply_date SET DEFAULT CURRENT_DATE;

ALTER TABLE hs_appliances_store.payment
ADD CHECK (status IN ('SUCCESSFUL', 'NOT-SUCCESSFUL'));

ALTER TABLE hs_appliances_store.order_detail
ADD CHECK (product_quantity != 0);

ALTER TABLE hs_appliances_store.product
ADD CHECK (price > 0);


/* Add fictional data to your database (5+ rows per table, 50+ rows total across all tables). 
 * Save your data as DML scripts. Make sure your surrogate keys' values 
 * are not included in DML scripts (they should be created runtime by the database, as well as DEFAULT values where appropriate). 
 * DML scripts must successfully pass all previously created constraints.
 */



INSERT INTO hs_appliances_store.brand (brand_name)
SELECT brand_name FROM 
(SELECT 'LG' AS brand_name 
               
UNION ALL

SELECT 'Samsung' AS brand_name 

UNION ALL

SELECT 'KitchenAid' AS brand_name 

UNION ALL

SELECT 'Frigidaire' AS brand_name 

UNION ALL

SELECT 'Bosch' AS brand_name 

) t1
WHERE brand_name NOT IN (
    SELECT brand_name  
    FROM hs_appliances_store.brand
);


INSERT INTO hs_appliances_store.supplier (first_name,last_name, address, contact_no)
SELECT first_name,last_name, address, contact_no FROM 
(SELECT 'Romualdas' AS first_name,
    	'Gavelis' AS last_name,
    	'Vilniaus g. 33, Vilnius' AS address,
    	868641091 AS contact_no
               
UNION ALL

SELECT 'Domas' AS first_name,
    	'Kasperunas' AS last_name,
    	'Pramones g. 8, Kaunas' AS address,
    	 861637229 AS contact_no

UNION ALL

SELECT 'Domas' AS first_name,
    	'Judickas' AS last_name,
    	'Laisves al. 84-4, Kaunas' AS address,
    	852404391 AS contact_no

UNION ALL

SELECT 'Faustas' AS first_name,
    	'Kemezys' AS last_name,
    	'Savanorių pr. 284, Kaunas' AS address,
    	852385090 AS contact_no

UNION ALL

SELECT 'Ulijonas' AS first_name,
    	'Nainys' AS last_name,
    	'Tilzes g. 13, Vilnius' AS address,
    	844661185 AS contact_no

) t2
    
WHERE (first_name, last_name) NOT IN (
	SELECT first_name, last_name
    FROM hs_appliances_store.supplier
);


INSERT INTO hs_appliances_store.category_type (type_name)
SELECT type_name FROM 
(SELECT 'Washing Machine' AS type_name 
               
UNION ALL

SELECT 'Refridgerator' AS type_name  

UNION ALL

SELECT 'Kettle' AS type_name 

UNION ALL

SELECT 'Iron' AS type_name 

UNION ALL

SELECT 'Toasters' AS type_name 

) t3
WHERE type_name NOT IN (
    SELECT type_name  
    FROM hs_appliances_store.category_type
);

INSERT INTO hs_appliances_store.category (supplier_id, category_name, category_type)
SELECT supplier_id, category_name, category_type FROM 
(SELECT (SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Romualdas Gavelis') AS supplier_id,
		'small appliances' AS category_name,
		(SELECT id 
		FROM hs_appliances_store.category_type
		WHERE type_name = 'Toasters') AS category_type
               
UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Domas Kasperunas') AS supplier_id,
		'major appliances' AS category_name,
		(SELECT id 
		FROM hs_appliances_store.category_type
		WHERE type_name = 'Refridgerator') AS category_type

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Domas Judickas') AS supplier_id,
		'consumer electronics' AS category_name,
		(SELECT id 
		FROM hs_appliances_store.category_type
		WHERE type_name = 'Kettle') AS category_type

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Faustas Kemezys') AS supplier_id,
		'consumer electronics' AS category_name,
		(SELECT id 
		FROM hs_appliances_store.category_type
		WHERE type_name = 'Toasters') AS category_type 

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Ulijonas Nainys') AS supplier_id,
		'major appliances' AS category_name,
		(SELECT id 
		FROM hs_appliances_store.category_type
		WHERE type_name = 'Washing Machine') AS category_type 

) t4
WHERE (category_name, category_type) NOT IN (
    SELECT category_name, category_type 
    FROM hs_appliances_store.category
);

INSERT INTO hs_appliances_store.product (category_id, description, product_name, brand, supplier, price)
SELECT category_id, description, product_name, brand, supplier, price FROM 
(SELECT (SELECT id 
		FROM hs_appliances_store.category
		WHERE category_name = 'small appliances'
		AND category_type = (SELECT id 
							FROM hs_appliances_store.category_type
							WHERE type_name = 'Toasters') ) AS category_id,
		'A toaster is a kitchen appliance for toasting food such as sliced bread, crumpets, and bagels.' AS description,
		'LG Toaster K20' AS product_name,
		(SELECT id 
		FROM hs_appliances_store.brand
		WHERE brand_name = 'LG') AS brand,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Romualdas Gavelis') AS supplier,
		98 AS price
		
               
UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.category
		WHERE category_name = 'major appliances'
		AND category_type = (SELECT id 
							FROM hs_appliances_store.category_type
							WHERE type_name = 'Refridgerator')) AS category_id,
		'A refrigerator is a large container which is kept cool inside, usually by electricity, so that the food and drink in it stays fresh' AS description,
		'LG Refridgerator W200' AS product_name,
		(SELECT id 
		FROM hs_appliances_store.brand
		WHERE brand_name = 'LG') AS brand,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Romualdas Gavelis') AS supplier,
		300 AS price

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.category
		WHERE category_name = 'consumer electronics'
		AND category_type = (SELECT id 
							FROM hs_appliances_store.category_type
							WHERE type_name = 'Kettle')) AS category_id,
		'Most kettles are metal, with a lid and a spout. If youre in the mood for a cup of tea, it might be time to "put the kettle on' AS description,
		'Samsung Kettle Z320' AS product_name,
		(SELECT id 
		FROM hs_appliances_store.brand
		WHERE brand_name = 'Samsung') AS brand,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Domas Judickas') AS supplier,
		70 AS price

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.category
		WHERE category_name = 'major appliances'
		AND category_type = (SELECT id 
							FROM hs_appliances_store.category_type
							WHERE type_name = 'Washing Machine')) AS category_id,
		'The washing machine concept is pretty simple – it agitates your clothes in a soapy suds and water to remove any dirt and stains' AS description,
		'Bosch WS V500' AS product_name,
		(SELECT id 
		FROM hs_appliances_store.brand
		WHERE brand_name = 'Bosch') AS brand,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Domas Judickas') AS supplier,
		450 AS price

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.category
		WHERE category_name = 'consumer electronics'
		AND category_type = (SELECT id 
							FROM hs_appliances_store.category_type
							WHERE type_name = 'Kettle')) AS category_id,
		'Most kettles are metal, with a lid and a spout. If youre in the mood for a cup of tea, it might be time to "put the kettle on' AS description,
		'Bosch Kettle E20' AS product_name,
		(SELECT id 
		FROM hs_appliances_store.brand
		WHERE brand_name = 'Bosch') AS brand,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Ulijonas Nainys') AS supplier,
		45 AS price

) t5
WHERE (category_id, product_name) NOT IN (
    SELECT category_id, product_name 
    FROM hs_appliances_store.product
);

INSERT INTO hs_appliances_store.orders (product_details, order_date)
SELECT product_details, order_date FROM 
(SELECT '2 LG Toasters' AS product_details,
		'2022-01-12'::DATE AS order_date
               
UNION ALL

SELECT '5 Deep Freezer' AS product_details,
		'2022-04-17'::DATE AS order_date 

UNION ALL

SELECT '10 Bosch Kettle' AS product_details,
		'2022-09-26'::DATE AS order_date

UNION ALL

SELECT '1 LG Microwave' AS product_details,
		'2019-12-19'::DATE AS order_date 

UNION ALL

SELECT '4 Kitchenaid Pots' AS product_details,
		'2023-01-10'::DATE AS order_date
		
UNION ALL

SELECT '2 Bosch Washing Machines' AS product_details,
		'2023-01-10'::DATE AS order_date
		
UNION ALL

SELECT '3 LG Toasters' AS product_details,
		'2023-01-10'::DATE AS order_date

) t6
WHERE (product_details, order_date) NOT IN (
    SELECT product_details, order_date 
    FROM hs_appliances_store.orders
);


INSERT INTO hs_appliances_store.order_detail (product_id, order_id, product_quantity)
SELECT product_id, order_id, product_quantity FROM 
(SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'LG Toaster K20') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.orders
		WHERE product_details = '2 LG Toasters') AS order_id,
		2 AS  product_quantity
               
UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'LG Refridgerator W200') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.orders
		WHERE product_details = '5 Deep Freezer') AS order_id,
		5 AS  product_quantity

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'Bosch Kettle E20') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.orders
		WHERE product_details = '10 Bosch Kettle') AS order_id,
		10 AS  product_quantity

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'Bosch WS V500') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.orders
		WHERE product_details = '2 Bosch Washing Machines') AS order_id,
		2 AS  product_quantity

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'LG Toaster K20') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.orders
		WHERE product_details = '3 LG Toasters') AS order_id,
		3 AS  product_quantity

) t7
WHERE (product_id, order_id) NOT IN (
    SELECT product_id, order_id
    FROM hs_appliances_store.order_detail
);

INSERT INTO hs_appliances_store.product_supplier (product_id, supplier_id, supply_date)
SELECT product_id, supplier_id, supply_date FROM 
(SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'LG Toaster K20') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Romualdas Gavelis') AS supplier_id,
		CURRENT_DATE AS  supply_date
               
UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'LG Refridgerator W200') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Ulijonas Nainys') AS supplier_id,
		CURRENT_DATE AS  supply_date

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'Bosch Kettle E20') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Faustas Kemezys') AS supplier_id,
		CURRENT_DATE AS  supply_date

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'Bosch WS V500') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Domas Judickas') AS supplier_id,
		CURRENT_DATE AS  supply_date

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'LG Toaster K20') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Domas Kasperunas') AS supplier_id,
		CURRENT_DATE AS  supply_date

) t8
WHERE (product_id, supplier_id) NOT IN (
    SELECT product_id, supplier_id
    FROM hs_appliances_store.product_supplier
);



INSERT INTO hs_appliances_store.customer (first_name,last_name, address, contact_no)
SELECT first_name,last_name, address, contact_no FROM 
(SELECT 'Vidmantas' AS first_name,
    	'Kukutis' AS last_name,
    	'Lyros g. 13, Kedaina' AS address,
    	865010093 AS contact_no
               
UNION ALL

SELECT 'Mykolas' AS first_name,
    	'Zvirbly' AS last_name,
    	'Zasliu g. 16, Jonava' AS address,
    	834960282 AS contact_no

UNION ALL

SELECT 'Domantas' AS first_name,
    	'Akute' AS last_name,
    	'Sloveniu al. 84-4, Kaunas' AS address,
    	877925141 AS contact_no

UNION ALL

SELECT 'Versijas' AS first_name,
    	'Merin' AS last_name,
    	'Pieu pr. 284, Kaunas' AS address,
    	888574963 AS contact_no

UNION ALL

SELECT 'Jonava' AS first_name,
    	'Teragas' AS last_name,
    	'Siluai g. 13, Vilnius' AS address,
    	82134456 AS contact_no

) t9
    
WHERE (first_name, last_name) NOT IN (
	SELECT first_name, last_name
    FROM hs_appliances_store.customer
);


INSERT INTO hs_appliances_store.purchase (product_id, customer_id, purchase_date)
SELECT product_id, customer_id, purchase_date FROM 
(SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'LG Toaster K20') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.customer
		WHERE CONCAT(first_name, ' ', last_name) = 'Jonava Teragas') AS customer_id,
		CURRENT_DATE AS  purchase_date
               
UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'LG Refridgerator W200') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.customer
		WHERE CONCAT(first_name, ' ', last_name) = 'Versijas Merin') AS customer_id,
		CURRENT_DATE AS  purchase_date

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'Bosch Kettle E20') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.customer
		WHERE CONCAT(first_name, ' ', last_name) = 'Domantas Akute') AS customer_id,
		CURRENT_DATE AS  purchase_date

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'Bosch WS V500') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.customer
		WHERE CONCAT(first_name, ' ', last_name) = 'Mykolas Zvirbly') AS customer_id,
		CURRENT_DATE AS  purchase_date

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.product
		WHERE product_name = 'LG Toaster K20') AS product_id,
		(SELECT id 
		FROM hs_appliances_store.customer
		WHERE CONCAT(first_name, ' ', last_name) = 'Vidmantas Kukutis') AS customer_id,
		CURRENT_DATE AS  purchase_date

) t10
WHERE (product_id, customer_id) NOT IN (
    SELECT product_id, customer_id
    FROM hs_appliances_store.purchase
);


INSERT INTO hs_appliances_store.supplier_category (category_id, supplier_id, supply_date)
SELECT category_id, supplier_id, supply_date FROM 
(SELECT (SELECT id 
		FROM hs_appliances_store.category
		WHERE category_name = 'small appliances'
		AND category_type = (SELECT id 
							FROM hs_appliances_store.category_type
							WHERE type_name = 'Toasters')) AS category_id,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Romualdas Gavelis') AS supplier_id,
		CURRENT_DATE AS  supply_date
		
               
UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.category
		WHERE category_name = 'major appliances'
		AND category_type = (SELECT id 
							FROM hs_appliances_store.category_type
							WHERE type_name = 'Refridgerator')) AS category_id,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Romualdas Gavelis') AS supplier_id,
		CURRENT_DATE AS  supply_date

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.category
		WHERE category_name = 'consumer electronics'
		AND category_type = (SELECT id 
							FROM hs_appliances_store.category_type
							WHERE type_name = 'Kettle')) AS category_id,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Domas Judickas') AS supplier_id,
		CURRENT_DATE AS  supply_date

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.category
		WHERE category_name = 'major appliances'
		AND category_type = (SELECT id 
							FROM hs_appliances_store.category_type
							WHERE type_name = 'Washing Machine')) AS category_id,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Domas Judickas') AS supplier_id,
		CURRENT_DATE AS  supply_date

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.category
		WHERE category_name = 'consumer electronics'
		AND category_type = (SELECT id 
							FROM hs_appliances_store.category_type
							WHERE type_name = 'Kettle')) AS category_id,
		(SELECT id 
		FROM hs_appliances_store.supplier
		WHERE CONCAT(first_name, ' ', last_name) = 'Ulijonas Nainys') AS supplier_id,
		CURRENT_DATE AS  supply_date

) t11
WHERE (category_id, supplier_id) NOT IN (
    SELECT category_id, supplier_id 
    FROM hs_appliances_store.supplier_category
);

INSERT INTO hs_appliances_store.payment (customer_id, amount, transaction_date, status)
SELECT customer_id, amount, transaction_date, status FROM 
(SELECT (SELECT id 
		FROM hs_appliances_store.customer
		WHERE CONCAT(first_name, ' ', last_name) = 'Jonava Teragas') AS customer_id,
		450 AS amount,
		CURRENT_DATE AS  transaction_date,
		'SUCCESSFUL' AS status
               
UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.customer
		WHERE CONCAT(first_name, ' ', last_name) = 'Versijas Merin') AS customer_id,
		50 AS amount,
		CURRENT_DATE AS  transaction_date,
		'SUCCESSFUL' AS status

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.customer
		WHERE CONCAT(first_name, ' ', last_name) = 'Domantas Akute') AS customer_id,
		200 AS amount,
		CURRENT_DATE AS  transaction_date,
		'SUCCESSFUL' AS status

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.customer
		WHERE CONCAT(first_name, ' ', last_name) = 'Mykolas Zvirbly') AS customer_id,
		70 AS amount,
		CURRENT_DATE AS  transaction_date,
		'SUCCESSFUL' AS status

UNION ALL

SELECT (SELECT id 
		FROM hs_appliances_store.customer
		WHERE CONCAT(first_name, ' ', last_name) = 'Vidmantas Kukutis') AS customer_id,
		78 AS amount,
		CURRENT_DATE AS  transaction_date,
		'SUCCESSFUL' AS status

) t12
WHERE (customer_id, amount) NOT IN (
    SELECT customer_id, amount
    FROM hs_appliances_store.payment
);




/*Create the following functions:
• Function that UPDATEs data in one of your tables (input arguments: table's primary key value, 
    column name and column value to UPDATE to).
• Function that adds new transaction to your transaction table. 
    Come up with input arguments and output format yourself. Make sure all transaction 
attributes can be set with the function (via their natural keys).

*/

CREATE OR REPLACE FUNCTION hs_appliances_store.update_product(role_id BIGINT,
                                            column_name VARCHAR(255),
                                            column_value VARCHAR(255))
RETURNS VARCHAR(255)
AS $$

--DECLARE
--   column_nam VARCHAR(255);
   

BEGIN 
    
        EXECUTE 'UPDATE hs_appliances_store.product 
                SET ' || column_name || ' = $3 
                WHERE id = $1'
        
        USING role_id, column_name, column_value;
--        RETURNING column_name INTO column_nam;
        RAISE NOTICE 'Successfully Updated  % to %', column_name, column_value;
        RETURN column_value;
END;

$$

LANGUAGE plpgsql;

SELECT * 
FROM hs_appliances_store.update_product(76, 'product_name', 'LG Toaster A500');


/*Create the following functions:
• Function that adds new transaction to your transaction table. 
    Come up with input arguments and output format yourself. Make sure all transaction 
attributes can be set with the function (via their natural keys).

*/

CREATE OR REPLACE FUNCTION hs_appliances_store.add_prod_supplier(prod_name VARCHAR(255),
                                                				supplier_name VARCHAR(55),
                                                				supply__date DATE DEFAULT CURRENT_DATE)
RETURNS VARCHAR(255)
AS $$

DECLARE
	prod_supply_id BIGINT;
  	column_namme VARCHAR(255);

BEGIN 
		-- check if product exist and allow insertion of several transaction
		SELECT ps.id INTO prod_supply_id
        FROM hs_appliances_store.product_supplier ps
        WHERE ps.product_id = (SELECT id 
					FROM hs_appliances_store.product
					WHERE product_name = $1);
        IF prod_supply_id IS NOT NULL THEN -- product exists   
        RAISE NOTICE 'Product exist  %', prod_supply_id;
       
		INSERT INTO hs_appliances_store.product_supplier (product_id, supplier_id, supply_date)
		
		SELECT product_id, supplier_id, supply_date FROM 
			(SELECT (SELECT id 
					FROM hs_appliances_store.product
					WHERE product_name = $1) AS product_id,
					(SELECT id 
					FROM hs_appliances_store.supplier
					WHERE CONCAT(first_name, ' ', last_name) = $2) AS supplier_id,
					$3 AS  supply_date
			) s1 
			
			
			WHERE (product_id, supplier_id) NOT IN (
			    SELECT product_id, supplier_id
			    FROM hs_appliances_store.product_supplier
			)
		
		
 
        RETURNING prod_name INTO column_namme;
        RAISE NOTICE 'Successfully Updated  %', column_namme;
       	END IF;
        RETURN column_namme;
END;

$$

LANGUAGE plpgsql;

SELECT * 
FROM hs_appliances_store.add_prod_supplier('LG Toaster A500', 'Ulijonas Nainys');


/*
* Create view that joins all tables in your database and represents 
* data in denormalized form for the past month. Make sure to omit meaningless fields in the 
* result (e.g. surrogate keys, duplicate fields, etc.).
*/

CREATE OR REPLACE VIEW hs_appliances_store.all_tables AS


SELECT p.id,
		p.description,
		p.product_name,
		p.price,
		ps.supply_date AS ps_supply_date,
		s.first_name AS supplier_first_name,
		s.last_name AS supplier_last_name,
		s.address AS supplier_address,
		s.contact_no AS supplier_phone_no,
		pu.purchase_date,
		c.first_name AS customer_first_name,
		c.last_name AS customer_last_name,
		c.address AS customer_address,
		c.contact_no AS customer_phone_no,
		pa.amount,
		pa.transaction_date,
		pa.status,
		sc.supply_date AS sc_supply_date,
		ca.category_name,
		ct.type_name,
		od.product_quantity,
		os.product_details,
		p.brand
		
		
FROM hs_appliances_store.product p
JOIN hs_appliances_store.product_supplier ps
ON p.id = ps.product_id
JOIN hs_appliances_store.supplier s
ON s.id = ps.supplier_id
JOIN hs_appliances_store.purchase pu
ON p.id = pu.product_id
JOIN hs_appliances_store.customer c
ON p.id = pu.product_id
JOIN hs_appliances_store.payment pa
ON c.id = pa.customer_id
JOIN hs_appliances_store.supplier_category sc
ON s.id = sc.supplier_id
JOIN hs_appliances_store.category ca
ON s.id = ca.supplier_id
JOIN hs_appliances_store.category_type ct
ON ca.category_type = ct.id
JOIN hs_appliances_store.order_detail od
ON od.product_id = p.id
JOIN hs_appliances_store.orders os
ON od.order_id = os.id
JOIN hs_appliances_store.brand b
ON b.id = p.brand
WHERE pa.transaction_date  >= date_trunc('month', current_date - interval '1' month)
AND pa.transaction_date  <= date_trunc('day', current_date);

SELECT * FROM hs_appliances_store.all_tables


--creating role manager
CREATE ROLE manager WITH LOGIN PASSWORD '12345';
GRANT CONNECT ON DATABASE postgres TO manager;
GRANT USAGE ON SCHEMA hs_appliances_store TO manager;
GRANT SELECT ON ALL TABLES IN SCHEMA hs_appliances_store TO manager;




