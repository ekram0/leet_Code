/*
Table: Accounts

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| id            | int     |
| name          | varchar |
+---------------+---------+
id is the primary key for this table.
This table contains the account id and the user name of each account.

 

Table: Logins

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| id            | int     |
| login_date    | date    |
+---------------+---------+
There is no primary key for this table, it may contain duplicates.
This table contains the account id of the user who logged in and the login date. A user may log in multiple times in the day.

 

Active users are those who logged in to their accounts for five or more consecutive days.

Write an SQL query to find the id and the name of active users.

Return the result table ordered by id.

The query result format is in the following example.

 

Example 1:

Input: 
Accounts table:
+----+----------+
| id | name     |
+----+----------+
| 1  | Winston  |
| 7  | Jonathan |
+----+----------+
Logins table:
+----+------------+
| id | login_date |
+----+------------+
| 7  | 2020-05-30 |
| 1  | 2020-05-30 |
| 7  | 2020-05-31 |
| 7  | 2020-06-01 |
| 7  | 2020-06-02 |
| 7  | 2020-06-02 |
| 7  | 2020-06-03 |
| 1  | 2020-06-07 |
| 7  | 2020-06-10 |
+----+------------+
Output: 
+----+----------+
| id | name     |
+----+----------+
| 7  | Jonathan |
+----+----------+
Explanation: 
User Winston with id = 1 logged in 2 times only in 2 different days, so, Winston is not an active user.
User Jonathan with id = 7 logged in 7 times in 6 different days, five of them were consecutive days, so, Jonathan is an active user.

 

Follow up: Could you write a general solution if the active users are those who logged in to their accounts for n or more consecutive days?
*/
WITH cte AS (
SELECT l.id, l.login_date, ROW_NUMBER() OVER(PARTITION BY l.id ORDER BY l.id, l.login_date) AS num
FROM (SELECT DISTINCT id, login_date FROM logins) l
)

SELECT id, name
FROM accounts
WHERE id in (
SELECT a.id
FROM cte a
GROUP BY a.id, DATEADD(day, -num, login_date)
HAVING COUNT(*) >=5
)
ORDER BY id

/*---------------------------------------------------------------------------------------------------------------------*/

WITH A AS (
select DISTINCT * FROM Logins
), B AS (


select id,
DATEADD(DAY,-ROW_NUMBER() OVER (PARTITION BY id ORDER BY login_date ASC), login_date) as grouping_set
FROM A)


select * FROM Accounts
where id IN (

select id FROM B
    GROUP BY id,grouping_set
    HAVING COUNT(*) >=5
)
ORDER BY 1 ASC
