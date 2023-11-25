CREATE DATABASE kindergarten;

CREATE SCHEMA IF NOT EXISTS kindergarten AUTHORIZATION postgres;

    CREATE TABLE IF NOT EXISTS kindergarten.group_type
    (
        id BIGSERIAL PRIMARY KEY,
        group_name VARCHAR(255) NOT NULL,
        age_group VARCHAR(20) NOT NULL 
    );
    
    CREATE TABLE IF NOT EXISTS kindergarten.activity_type
    (
        id BIGSERIAL PRIMARY KEY,
        act_type VARCHAR(255) NOT NULL,
        description TEXT 
    );

    CREATE TABLE IF NOT EXISTS kindergarten.activity
    (
        id BIGSERIAL PRIMARY KEY,
        activity_type BIGINT NOT NULL REFERENCES kindergarten.activity_type,
        activity_name VARCHAR(20) NOT NULL 
    );

    CREATE TABLE IF NOT EXISTS kindergarten.menu_type
    (
        id BIGSERIAL PRIMARY KEY,
        description TEXT,
        category VARCHAR(50) NOT NULL,
        calories VARCHAR(50) NOT NULL,
        image BYTEA
    );

    CREATE TABLE IF NOT EXISTS kindergarten.menu
    (
        id BIGSERIAL PRIMARY KEY,
        meal_type VARCHAR(255) NOT NULL DEFAULT 'Breakfast',
        menu_type BIGINT NOT NULL REFERENCES kindergarten.menu_type
        CHECK (meal_type IN ('Breakfast','Lunch', 'Dinner'))
    );



    CREATE TABLE IF NOT EXISTS kindergarten.kggroup
    (
        id BIGSERIAL PRIMARY KEY,
        group_type BIGINT NOT NULL REFERENCES kindergarten.group_type,
        activity BIGINT NOT NULL REFERENCES kindergarten.activity,
        menu BIGINT NOT NULL REFERENCES kindergarten.menu
    );

    CREATE TABLE IF NOT EXISTS kindergarten.child
    (
        id BIGSERIAL PRIMARY KEY,
        group_id BIGINT NOT NULL REFERENCES kindergarten.kggroup,
        first_name VARCHAR(255) NOT NULL,
        last_name VARCHAR(255) NOT NULL,
        gender varchar(10) NOT NULL CHECK (gender IN ('Male', 'Female', 'Others')),
        date_of_birth DATE NOT NULL,
        address VARCHAR(255) NOT NULL
    );
    
    CREATE TABLE IF NOT EXISTS kindergarten.parent
    (
        id BIGSERIAL PRIMARY KEY,
        first_name VARCHAR(255) NOT NULL,
        last_name VARCHAR(255) NOT NULL,
        email varchar(100) NOT NULL CHECK (email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
        phone BIGINT NOT NULL

    );

    CREATE TABLE IF NOT EXISTS kindergarten.events
    (
        id BIGSERIAL PRIMARY KEY,
        group_type INT NOT NULL REFERENCES kindergarten.group_type,
        event_name VARCHAR(50) NOT NULL,
        event_description TEXT
    );

     CREATE TABLE IF NOT EXISTS kindergarten.payment
    (
        id BIGSERIAL PRIMARY KEY,
        parent_id INT NOT NULL REFERENCES kindergarten.parent,
        child_id INT NOT NULL REFERENCES kindergarten.child,
        event_id INT NOT NULL REFERENCES kindergarten.events,
        payment_details VARCHAR(255) NOT NULL,
        status VARCHAR(50) NOT NULL DEFAULT 'NOT PAID'
    );  
    

    CREATE TABLE IF NOT EXISTS kindergarten.child_registration
    (
        id BIGSERIAL PRIMARY KEY,
        child_id INT NOT NULL REFERENCES kindergarten.child,
        parent_id INT NOT NULL REFERENCES kindergarten.parent   
    ); 

    CREATE TABLE IF NOT EXISTS kindergarten.group_activity
    (
        id BIGSERIAL PRIMARY KEY,
        group_id BIGINT NOT NULL REFERENCES kindergarten.kggroup,
        activity_id BIGINT NOT NULL REFERENCES kindergarten.activity,
        duration VARCHAR(50) NOT NULL,
        day_ VARCHAR(20) CHECK (day_ IN ('Monday','Tuesday', 'Wednesday', 'Thursday', 'Friday')),
        week_ INT CHECK (week_ != 0)
    );
    
    CREATE TABLE IF NOT EXISTS kindergarten.group_menu
    (
        id BIGSERIAL PRIMARY KEY,
        group_id BIGINT NOT NULL REFERENCES kindergarten.kggroup,
        menu_id BIGINT NOT NULL REFERENCES kindergarten.menu,
        duration VARCHAR(50) NOT NULL,
        day_ VARCHAR(20) CHECK (day_ IN ('Monday','Tuesday', 'Wednesday', 'Thursday', 'Friday')),
        week_ INT CHECK (week_ != 0)
    );

        CREATE TABLE IF NOT EXISTS kindergarten.group_event
    (
        id BIGSERIAL PRIMARY KEY,
        group_id BIGINT NOT NULL REFERENCES kindergarten.kggroup,
        event_id BIGINT NOT NULL REFERENCES kindergarten.events,
        duration VARCHAR(50) NOT NULL,
        day_ VARCHAR(20) CHECK (day_ IN ('Monday','Tuesday', 'Wednesday', 'Thursday', 'Friday')),
        week_ INT CHECK (week_ != 0)
    );


INSERT INTO kindergarten.group_type (group_name, age_group)
SELECT group_name, age_group FROM 
(SELECT 'Beautiful Minds' AS group_name, 
        '4 - 5years' AS age_group
        
UNION ALL 

SELECT 'Future Leaders' AS group_name, 
        '5 - 6years' AS age_group
        
) t1
        
WHERE group_name NOT IN (
    SELECT group_name 
    FROM kindergarten.group_type
);
    
INSERT INTO kindergarten.activity_type (act_type, description)
SELECT act_type, description FROM 
(SELECT 'Maths activity' AS act_type, 
        'By sorting and categorizing beans, your kindergartner will begin to build math and problem-solving skills.' AS description
        
UNION ALL 

SELECT 'Science activity' AS act_type, 
        'This fun activity engages your child’s curiosity and builds observation skills, which will become important as your child studies science.' AS description
        
) t2
        
WHERE act_type NOT IN (
    SELECT act_type
    FROM kindergarten.activity_type
);
 
INSERT INTO kindergarten.activity (activity_type, activity_name)
SELECT activity_type, activity_name FROM 
(SELECT (SELECT id 
        FROM kindergarten.activity_type
        WHERE act_type = 'Maths activity') AS activity_type, 
        'Sorting beans' AS activity_name

        
UNION ALL 

SELECT (SELECT id 
        FROM kindergarten.activity_type
        WHERE act_type = 'Science activity') AS activity_type, 
        'Amazing bubbles' AS activity_name
        
) t3
        
WHERE activity_name NOT IN (
    SELECT activity_name
    FROM kindergarten.activity
);

INSERT INTO kindergarten.menu_type (description, category, calories)
SELECT description, category, calories FROM 
(SELECT 'Cheries, Peaches, Milk' AS description, 
        'Protein & Vitamins' AS category,
        '200kcals' AS calories
        
UNION ALL 

SELECT 'Chicken Nuggets, Peas, Apple Juice' AS description, 
        'Carbs, Protein & Vitamins' AS category,
        '1000kcals' AS calories
        
) t4
        
WHERE description NOT IN (
    SELECT description
    FROM kindergarten.menu_type
);

INSERT INTO kindergarten.menu (meal_type, menu_type)
SELECT meal_type, menu_type FROM 
(SELECT 'Breakfast' AS meal_type, 
        (SELECT id 
        FROM kindergarten.menu_type
        WHERE description = 'Cheries, Peaches, Milk')
        AS menu_type
        
UNION ALL 

SELECT 'Lunch' AS meal_type, 
        (SELECT id 
        FROM kindergarten.menu_type
        WHERE description = 'Chicken Nuggets, Peas, Apple Juice')
        AS menu_type
        
) t5
        
WHERE (meal_type, menu_type) NOT IN (
    SELECT meal_type, menu_type 
    FROM kindergarten.menu
);

INSERT INTO kindergarten.kggroup (group_type, activity, menu)
SELECT group_type, activity, menu FROM 
(SELECT (SELECT id 
        FROM kindergarten.group_type
        WHERE group_name = 'Beautiful Minds') AS group_type, 
        (SELECT id 
        FROM kindergarten.activity
        WHERE activity_name = 'Amazing bubbles') AS activity,
        (SELECT id 
        FROM kindergarten.menu
        WHERE meal_type = 'Lunch') AS menu
        
UNION ALL 

SELECT (SELECT id 
        FROM kindergarten.group_type
        WHERE group_name = 'Future Leaders') AS group_type, 
        (SELECT id 
        FROM kindergarten.activity
        WHERE activity_name = 'Sorting beans') AS activity,
        (SELECT id 
        FROM kindergarten.menu
        WHERE meal_type = 'Breakfast') AS menu
        
) t6
        
WHERE (group_type,activity) NOT IN (
    SELECT group_type, activity 
    FROM kindergarten.kggroup
);
    

INSERT INTO kindergarten.child (group_id, first_name, last_name, gender, date_of_birth, address)
SELECT group_id, first_name, last_name, gender, date_of_birth::DATE , address FROM 
(SELECT (SELECT id 
        FROM (SELECT id 
        FROM kindergarten.group_type
        WHERE group_name = 'Beautiful Minds') a) AS group_id,
        'Vitas' AS first_name, 
        'Zurinskas' AS last_name,
        'Male' AS gender,
        '13-09-2017' AS date_of_birth,
        'Vilniaus pr. 21, Vilnius' AS address
        
UNION ALL 

SELECT (SELECT id 
        FROM (SELECT id 
        FROM kindergarten.group_type
        WHERE group_name = 'Future Leaders') b) AS group_id ,
        'Nerijus' AS first_name, 
        'Vaiciulaitis' AS last_name,
        'Female' AS gender,
        '22-01-2016' AS date_of_birth,
        'Gedeminos pr. 9, Vilnius' AS address
        
        
) t7
        
WHERE (first_name, last_name) NOT IN (
    SELECT first_name, last_name
    FROM kindergarten.child
); 


INSERT INTO kindergarten.parent (first_name, last_name, email, phone)
SELECT first_name, last_name, email, phone FROM 
(SELECT 'Ovidijus' AS first_name, 
        'Kudukis' AS last_name,
        'o.kudu@gmail.com' AS email,
        863345232 AS phone
        
UNION ALL 

SELECT 'Ignotas' AS first_name, 
        'Caplikas' AS last_name,
        'ign_Caplikas@gmail.com' AS email,
        823755644 AS phone
        
        
) t8
        
WHERE (first_name, last_name) NOT IN (
    SELECT first_name, last_name
    FROM kindergarten.parent
); 

INSERT INTO kindergarten.events (group_type, event_name, event_description)
SELECT group_type, event_name, event_description FROM 
(SELECT (SELECT id 
        FROM kindergarten.group_type
        WHERE group_name = 'Future Leaders') AS group_type , 
        'Outdoor storytime' AS event_name,
        'Spread out cushions on the ground at a park or outdoor café for children to listen to a story you read aloud' AS event_description

        
UNION ALL 

SELECT (SELECT id 
        FROM kindergarten.group_type
        WHERE group_name = 'Beautiful Minds') AS group_type , 
        'Arts & Crafts day' AS event_name,
        'arts and crafts projects, create boxes with everything that’s needed to complete the project and have them ready for pick-up.' AS event_description

        
        
) t9
        
WHERE event_name NOT IN (
    SELECT event_name
    FROM kindergarten.events
);


INSERT INTO kindergarten.payment (parent_id, child_id, event_id, payment_details, status)
SELECT parent_id, child_id, event_id, payment_details, status FROM 
(SELECT (SELECT id 
        FROM kindergarten.parent
        WHERE CONCAT(first_name, ' ', last_name)  = 'Ovidijus Kudukis') AS parent_id, 
        
        (SELECT id 
        FROM kindergarten.child
        WHERE CONCAT(first_name, ' ', last_name)  = 'Nerijus Vaiciulaitis') AS child_id,
        
        (SELECT id 
        FROM kindergarten.events
        WHERE event_name  = 'Arts & Crafts day') AS event_id,
        
        'Arts & Crafts Payment by Ovidijus Kudukis' AS payment_details,
        'PAID' AS status

        
UNION ALL 

SELECT (SELECT id 
        FROM kindergarten.parent
        WHERE CONCAT(first_name, ' ', last_name)  = 'Ovidijus Kudukis') AS parent_id, 
        
        (SELECT id 
        FROM kindergarten.child
        WHERE CONCAT(first_name, ' ', last_name)  = 'Vitas Zurinskas') AS child_id,
        
        (SELECT id 
        FROM kindergarten.events
        WHERE event_name  = 'Arts & Crafts day') AS event_id,
        
        'Arts & Crafts Payment by Ovidijus Kudukis' AS payment_details,
        'PAID' AS status    
        
) t10
        
WHERE child_id NOT IN (
    SELECT child_id
    FROM kindergarten.payment
);
    
INSERT INTO kindergarten.child_registration (child_id, parent_id)
SELECT child_id, parent_id FROM 
(SELECT  (SELECT id 
        FROM kindergarten.child
        WHERE CONCAT(first_name, ' ', last_name)  = 'Nerijus Vaiciulaitis') AS child_id,
        
        (SELECT id 
        FROM kindergarten.parent
        WHERE CONCAT(first_name, ' ', last_name)  = 'Ovidijus Kudukis') AS parent_id

        
UNION ALL 

SELECT (SELECT id 
        FROM kindergarten.child
        WHERE CONCAT(first_name, ' ', last_name)  = 'Vitas Zurinskas') AS child_id,

        (SELECT id 
        FROM kindergarten.parent
        WHERE CONCAT(first_name, ' ', last_name)  = 'Ovidijus Kudukis') AS parent_id
              
) t11
        
WHERE (child_id, parent_id) NOT IN (
    SELECT child_id, parent_id
    FROM kindergarten.child_registration
);

INSERT INTO kindergarten.group_activity (group_id, activity_id, duration, day_, week_)
SELECT group_id, activity_id, duration, day_, week_ FROM 
(SELECT (SELECT id 
        FROM (SELECT id 
        FROM kindergarten.group_type
        WHERE group_name = 'Beautiful Minds') c) AS group_id,
        
        (SELECT id 
        FROM kindergarten.activity
        WHERE activity_name = 'Amazing bubbles') AS activity_id,
        
        '45 mins' AS duration,
        'Wednesday' AS day_,
        3 AS week_

        
UNION ALL 


SELECT (SELECT id 
        FROM (SELECT id 
        FROM kindergarten.group_type
        WHERE group_name = 'Future Leaders') d) AS group_id,
        
        (SELECT id 
        FROM kindergarten.activity
        WHERE activity_name = 'Amazing bubbles') AS activity_id,
        
        '45 mins' AS duration,
        'Friday' AS day_,
        12 AS week_  
        
) t12
        
WHERE (group_id, activity_id) NOT IN (
    SELECT group_id, activity_id
    FROM kindergarten.group_activity
);

INSERT INTO kindergarten.group_menu (group_id, menu_id, duration, day_, week_)
SELECT group_id, menu_id, duration, day_, week_ FROM 
(SELECT (SELECT id 
        FROM (SELECT id 
        FROM kindergarten.group_type
        WHERE group_name = 'Beautiful Minds') e) AS group_id,
        
        (SELECT id 
        FROM kindergarten.menu
        WHERE meal_type = 'Breakfast') AS menu_id,
        
        '60 mins' AS duration,
        'Monday' AS day_,
        2 AS week_

        
UNION ALL 


SELECT (SELECT id 
        FROM (SELECT id 
        FROM kindergarten.group_type
        WHERE group_name = 'Future Leaders') f) AS group_id,
        
        (SELECT id 
        FROM kindergarten.menu
        WHERE meal_type = 'Lunch') AS menu_id,
        
        '60 mins' AS duration,
        'Friday' AS day_,
        4 AS week_  
        
) t13
        
WHERE (group_id, menu_id) NOT IN (
    SELECT group_id, menu_id
    FROM kindergarten.group_menu
);

INSERT INTO kindergarten.group_event (group_id, event_id, duration, day_, week_)
SELECT group_id, event_id, duration, day_, week_ FROM 
(SELECT (SELECT id 
        FROM (SELECT id 
        FROM kindergarten.group_type
        WHERE group_name = 'Beautiful Minds') g) AS group_id,
        
        (SELECT id 
        FROM kindergarten.events
        WHERE event_name  = 'Outdoor storytime') AS event_id,
        
        '60 mins' AS duration,
        'Monday' AS day_,
        2 AS week_

        
UNION ALL 


SELECT (SELECT id 
        FROM (SELECT id 
        FROM kindergarten.group_type
        WHERE group_name = 'Future Leaders') h) AS group_id,
        
        (SELECT id 
        FROM kindergarten.events
        WHERE event_name  = 'Arts & Crafts day') AS event_id,
        
        '60 mins' AS duration,
        'Friday' AS day_,
        4 AS week_  
        
) t14
        
WHERE (group_id, event_id) NOT IN (
    SELECT group_id, event_id
    FROM kindergarten.group_event
);


-- Alter all tables and add 'record_ts' field to each table. 
-- Make it not null and set its default value to current_date. 
-- Check that the value has been set for existing rows.
    
ALTER TABLE kindergarten.group_type
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;

ALTER TABLE kindergarten.activity_type 
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;

ALTER TABLE kindergarten.activity
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;

ALTER TABLE kindergarten.menu_type
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;

ALTER TABLE kindergarten.menu 
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;

ALTER TABLE kindergarten.kggroup
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;

ALTER TABLE kindergarten.child
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;

ALTER TABLE kindergarten.parent
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;

ALTER TABLE kindergarten.events
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;

ALTER TABLE kindergarten.payment
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;

ALTER TABLE kindergarten.child_registration
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;

ALTER TABLE kindergarten.group_activity 
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;

ALTER TABLE kindergarten.group_menu
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;

ALTER TABLE kindergarten.group_event
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;

ALTER TABLE kindergarten.group_type
ADD IF NOT EXISTS record_ts TIMESTAMP NOT NULL DEFAULT current_date;
    