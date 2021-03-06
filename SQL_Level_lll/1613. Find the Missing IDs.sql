/*
Table: Customers

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| customer_id   | int     |
| customer_name | varchar |
+---------------+---------+
customer_id is the primary key for this table.
Each row of this table contains the name and the id customer.

 

Write an SQL query to find the missing customer IDs. The missing IDs are ones that are not in the Customers table but are in the range between 1 and the maximum customer_id present in the table.

Notice that the maximum customer_id will not exceed 100.

Return the result table ordered by ids in ascending order.

The query result format is in the following example.

 

Example 1:

Input: 
Customers table:
+-------------+---------------+
| customer_id | customer_name |
+-------------+---------------+
| 1           | Alice         |
| 4           | Bob           |
| 5           | Charlie       |
+-------------+---------------+
Output: 
+-----+
| ids |
+-----+
| 2   |
| 3   |
+-----+
Explanation: 
The maximum customer_id present in the table is 5, so in the range [1,5], IDs 2 and 3 are missing from the table.

*/
WITH r_cte AS (
    SELECT 1 ids, MAX(customer_id) m
    FROM customers
    
    UNION ALL
    
    SELECT ids+1, m
    FROM r_cte
    WHERE ids < m
)
SELECT ids 
FROM r_cte
WHERE ids NOT IN (SELECT customer_id FROM customers)
ORDER BY ids ASC

/* ------------------------------------------------------------------------------------------------*/
with level1 as (
select 
        customer_id,
        customer_id - lag( customer_id) over (order by customer_id) as diff
from Customers
)
select customer_id, diff
from level1
where diff > 1;

/*------------------------------------------------------------------------------------------------*/


with t as
(
select 1 as ids,max(customer_id) as mx from customers
    union all
select ids +1 as ids, mx from t where ids < mx
)

select  ids from t
except
select customer_id as ids from customers
