-- 1. Create table ‘table_to_delete’ and fill it with the following query:

CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x; -- generate_series() creates 10^7 rows of sequential numbers 
                                        -- from 1 to 10000000 (10^7)
-- total time (28.304 secs)



-- 2. Lookup how much space this table consumes with the following query
    
SELECT *, pg_size_pretty(total_bytes) AS total, 
            pg_size_pretty(index_bytes) AS INDEX,
            pg_size_pretty(toast_bytes) AS toast,
            pg_size_pretty(table_bytes) AS TABLE
FROM ( SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
    FROM (SELECT c.oid,nspname AS table_schema, 
            relname AS TABLE_NAME,
            c.reltuples AS row_estimate,
            pg_total_relation_size(c.oid) AS total_bytes,
            pg_indexes_size(c.oid) AS index_bytes,
            pg_total_relation_size(reltoastrelid) AS toast_bytes
FROM pg_class c
LEFT JOIN pg_namespace n 
ON n.oid = c.relnamespace
WHERE relkind = 'r'
        ) a
    ) a
WHERE table_name LIKE '%table_to_delete%' 

-- the TABLE takes 575 mb of memory


-- 3. Issue the following DELETE operation on ‘table_to_delete’:

DELETE FROM table_to_delete
WHERE REPLACE(col, 'veeeeeeery_long_string','')::int % 3 = 0; -- removes 1/3 of all ROWS
-- it takes 24.875 secs to run
-- the space consumption is still 575mb after deletion

VACUUM FULL VERBOSE table_to_delete;
-- the space consumption is now 383mb after vacuuming

-- after the table_to_delete vacuum, there is a reduction in the space occupied by the memory 
-- i.e some memory space have been freed up

-- 4. Issue the following TRUNCATE operation

TRUNCATE table_to_delete;
-- it takes 1.148 secs to perform the truncate operation

-- when compared to delete, truncate is much faster in operation (1.148s) than delete (24.875s)
-- after truncating the table, the storage space is 0 bytes which means it completely freed up the memory,
-- after performing the operation unlike delete that reserves the storage space even after performing
-- am operation

--DROP TABLE table_to_delete;