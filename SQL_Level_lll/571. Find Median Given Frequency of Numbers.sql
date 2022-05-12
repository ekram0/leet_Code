/*
Table: Numbers

+-------------+------+
| Column Name | Type |
+-------------+------+
| num         | int  |
| frequency   | int  |
+-------------+------+
num is the primary key for this table.
Each row of this table shows the frequency of a number in the database.

 

The median is the value separating the higher half from the lower half of a data sample.

Write an SQL query to report the median of all the numbers in the database after decompressing the Numbers table. Round the median to one decimal point.

The query result format is in the following example.

 

Example 1:

Input: 
Numbers table:
+-----+-----------+
| num | frequency |
+-----+-----------+
| 0   | 7         |
| 1   | 1         |
| 2   | 3         |
| 3   | 1         |
+-----+-----------+
Output: 
+--------+
| median |
+--------+
| 0.0    |
+--------+
Explanation: 
If we decompress the Numbers table, we will get [0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 2, 3], so the median is (0 + 0) / 2 = 0.


The idea is that the natural index of the median should be within the range of frequency intervals of each value. Also as the intervals are inclusive [start, end] and neighboring intervals share borders, the avg() function will help return the median as the mean of two different numbers.
image

*/

WITH tmp AS (SELECT num, Frequency,
             SUM(Frequency) OVER (ORDER BY num ASC) rk1,
             SUM(Frequency) OVER (ORDER BY num DESC) rk2
             FROM Numbers)
  
SELECT AVG(num*1.0) AS median
FROM tmp
WHERE ABS(rk1-rk2)<=Frequency