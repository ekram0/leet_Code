/*
SQL Schema

Table: Product

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| product_id    | int     |
| product_name  | varchar |
+---------------+---------+
product_id is the primary key for this table.
product_name is the name of the product.

 

Table: Sales

+---------------------+---------+
| Column Name         | Type    |
+---------------------+---------+
| product_id          | int     |
| period_start        | date    |
| period_end          | date    |
| average_daily_sales | int     |
+---------------------+---------+
product_id is the primary key for this table. 
period_start and period_end indicate the start and end date for the sales period, and both dates are inclusive.
The average_daily_sales column holds the average daily sales amount of the items for the period.
The dates of the sales years are between 2018 to 2020.

 

Write an SQL query to report the total sales amount of each item for each year, with corresponding product_name, product_id, product_name, and report_year.

Return the result table ordered by product_id and report_year.

The query result format is in the following example.

 

Example 1:

Input: 
Product table:
+------------+--------------+
| product_id | product_name |
+------------+--------------+
| 1          | LC Phone     |
| 2          | LC T-Shirt   |
| 3          | LC Keychain  |
+------------+--------------+
Sales table:
+------------+--------------+-------------+---------------------+
| product_id | period_start | period_end  | average_daily_sales |
+------------+--------------+-------------+---------------------+
| 1          | 2019-01-25   | 2019-02-28  | 100                 |
| 2          | 2018-12-01   | 2020-01-01  | 10                  |
| 3          | 2019-12-01   | 2020-01-31  | 1                   |
+------------+--------------+-------------+---------------------+
Output: 
+------------+--------------+-------------+--------------+
| product_id | product_name | report_year | total_amount |
+------------+--------------+-------------+--------------+
| 1          | LC Phone     |    2019     | 3500         |
| 2          | LC T-Shirt   |    2018     | 310          |
| 2          | LC T-Shirt   |    2019     | 3650         |
| 2          | LC T-Shirt   |    2020     | 10           |
| 3          | LC Keychain  |    2019     | 31           |
| 3          | LC Keychain  |    2020     | 31           |
+------------+--------------+-------------+--------------+
Explanation: 
LC Phone was sold for the period of 2019-01-25 to 2019-02-28, and there are 35 days for this period. Total amount 35*100 = 3500. 
LC T-shirt was sold for the period of 2018-12-01 to 2020-01-01, and there are 31, 365, 1 days for years 2018, 2019 and 2020 respectively.
LC Keychain was sold for the period of 2019-12-01 to 2020-01-31, and there are 31, 31 days for years 2019 and 2020 respectively.


*/

with cte
as
(select cast(min(period_start) as date) as min_date, cast(max(period_end) as date) as end_Date
from sales
union all

select cast(DATEADD(day,1,min_date) as date), cast(end_date as date)
from cte
where min_date < end_date
)

select a.product_id ,product_name ,left(min_date,4) as report_year,sum(average_daily_sales) as total_amount
from sales a join cte b
on b.min_date between a.period_start and period_end
join product c
on a.product_id =c.product_id
group by a.product_id ,left(min_date,4),product_name
order by a.product_id , left(min_date,4)
OPTION (MAXRECURSION 0);

/*----------------------------------------------------------------------------------------------------------------------*/
;with CTE1
AS
(
SELECT S.product_id AS product_id,P.product_name AS product_name,average_daily_sales,period_start,year(period_start) AS period_start_year,period_end,year(period_end) AS period_end_year
FROM Sales S LEFT OUTER JOIN Product P on S.product_id=P.product_id
UNION ALL
SELECT product_id,product_name,average_daily_sales,period_start,period_start_year+1,period_end,period_end_year
FROM CTE1
WHERE period_start_year+1<=period_end_year
)
,
CTE2
AS
(
SELECT product_id,product_name,average_daily_sales,
CASE
	WHEN year(period_start)=period_start_year
	THEN period_start
	ELSE CAST(CONCAT(period_start_year,'-','01','-','01') AS date)
 END AS period_start,
 CASE
	WHEN year(period_end)=period_start_year
	THEN period_end
	ELSE CAST(CONCAT(period_start_year,'-','12','-','31') AS date)
END AS period_end
FROM CTE1
)
SELECT product_id,
	   product_name,
	   Cast(Year(period_start) AS nvarchar(4)) AS report_year,
	   (DATEDIFF(DAY,period_start,period_end)+1)*average_daily_sales AS total_amount
FROM CTE2
ORDER BY product_id,Year(period_start)

/*----------------------------------------------------------------------------------------------------------------------*/
with my(year) as 
(
select max(year(period_end)) from sales
),years(year) as
(
select min(year(period_start))
from sales
union all
select years.year+1 
from years, my
where years.year<=my.year                                                   
)
select s.product_id
        ,p.product_name
        ,cast(y.year as varchar(5)) report_year
        ,sum(case when year(s.period_start)=year(s.period_end) then (datediff(day,period_start,period_end)+1)* average_daily_sales
        when y.year=year(s.period_start) then (datediff(day,period_start,concat(y.year,'-12-31'))+1)* average_daily_sales
        when y.year=year(s.period_end) then (datediff(day,concat(y.year,'-01-01'),period_end)+1) * average_daily_sales 
        else 365* average_daily_sales end) as total_amount
from sales s
left join years y
    on y.year between year(s.period_start) and year(s.period_end)
left join product p
    on s.product_id=p.product_id
group by s.product_id,p.product_name,y.year
order by s.product_id,cast(y.year as varchar(5))

with years(year1,year2) as
(select min(year(period_start)),max(year(period_end)) from sales
 union all
select year1+1,year2 from years where year1<year2)
select s.product_id
    ,p.product_name
    ,cast(y.year1 as varchar(4)) as report_year
    ,sum(case when year(s.period_start)=year(s.period_end) then (datediff(day,s.period_start,s.period_end)+1)*s.average_daily_sales 
         when year(s.period_start)=y.year1 then (datediff(day,s.period_start,concat(y.year1,'-12-31'))+1)*s.average_daily_sales
         when year(s.period_end)=y.year1 then (datediff(day,concat(y.year1,'-01-01'),s.period_end)+1)*s.average_daily_sales
    else 365*s.average_daily_sales end) as total_amount
from sales s
left join product p
    on s.product_id=p.product_id
left join years y
    on y.year1 between year(s.period_start) and year(s.period_end)
group by s.product_id
    ,p.product_name
    ,y.year1
order by s.product_id,report_year;
GO
/*----------------------------------------------------------------------------------------------------------------------*/
WITH YEARS AS (
    SELECT '2018' AS YEAR, '2018-01-01' AS START_YEAR, '2018-12-31' AS END_YEAR
    UNION
    SELECT '2019' AS YEAR, '2019-01-01' AS START_YEAR, '2019-12-31' AS END_YEAR
    UNION
    SELECT '2020' AS YEAR, '2020-01-01' AS START_YEAR, '2020-12-31' AS END_YEAR
)
, CTE AS (
    SELECT
        T1.product_id
      , T2.product_name
      , T1.period_start
      , T1.period_end
      , T3.YEAR AS report_year
      , T3.START_YEAR
      , T3.END_YEAR
      , T1.average_daily_sales
    FROM 
        Sales T1
    JOIN
        Product T2
        ON T1.product_id = T2.product_id
    JOIN
        YEARS T3
        ON T3.YEAR BETWEEN YEAR(T1.period_start) AND YEAR(T1.period_end)
)
, CTE2 AS (
    SELECT
        product_id
      , product_name
      , report_year
      , period_start
      , period_end
      , CASE 
            WHEN YEAR(period_start) < report_year AND YEAR(period_end) > report_year
                THEN DATEDIFF(day, START_YEAR, END_YEAR) + 1
            WHEN YEAR(period_start) < report_year AND YEAR(period_end) = report_year
                THEN DATEDIFF(day, START_YEAR, period_end) + 1
            WHEN YEAR(period_start) = report_year AND YEAR(period_end) > report_year
                THEN DATEDIFF(day, period_start, END_YEAR) + 1
            WHEN YEAR(period_start) = report_year AND YEAR(period_end) = report_year
                THEN DATEDIFF(day, period_start, period_end) + 1
            END AS total_days
      , average_daily_sales
    FROM
        CTE
)
SELECT
    product_id
  , product_name
  , report_year
  , average_daily_sales * total_days AS total_amount
FROM
    CTE2
ORDER BY
    product_id, report_year
