# SQL Practice Questions and Solutions: CTE and Window Functions

This README contains practice questions and solutions to help you master Common Table Expressions (CTEs) and Window Functions in SQL. These questions are based on real-world scenarios and cover various aspects of advanced SQL querying.

All questions are dervied from Zach Wilson's video tutorial [SQL Window Functions and CTEs](https://www.youtube.com/watch?v=dqwhNcZoMOQ&t=3064s).

You can perform the queries using the [DataExpert.io Query Editor](https://www.dataexpert.io/classroom/zachwilson).

## Window Functions
Window functions define a `Window` and performing some sort of `operation` on it. 

Key words for when to use a Window Function in a SQL interview:
- Rolling
- Rank
- Consecutive
- Deduplicate (can sometimes get away with using a group by, otherwise use ROW_NUMBER)

Common question: Second highest salary by department 

Note they didn't specify rank but used an ordinal term such as (Second highest, Third highest, etc.)


### What is a Window?
A window is a set of rows determined by the `OVER` expression:

OVER has a few components to it. 
- `PARTITION BY` (determines how many 'slices' there will be)
- `ORDER BY` (determines how a window is sorted)
- `ROWS` (determines how many rows before and after the current row should be considered)
   - The ROWS clause isn't very common and typically only used in Rolling functions i.e. Rolling 30 day average.

## Questions and Solutions

1. **LAG Function:**
   Question: How would you use the LAG function to compare a player's points in the current season with their points in the previous season?

   Solution:
   ```sql
   WITH lagged AS (
     SELECT player_name, 
     season, 
     pts, 
     LAG(pts, 1) OVER (
       PARTITION BY player_name
       ORDER BY season
     ) AS pts_last_season
     FROM bootcamp.nba_player_seasons 
   )
   SELECT * FROM lagged;
   ```

2. **CASE Statement:**
   Question: Write a CASE statement to categorize players based on whether they maintained a scoring average of 20 or more points across consecutive seasons.

   Solution:
   ```sql
   WITH did_change AS (
     SELECT *, 
     CASE WHEN pts >= 20 AND pts_last_season >= 20 THEN 0 ELSE 1 END AS pts_stayed_above_20
     FROM lagged
   )
   SELECT * FROM did_change;
   ```

3. **SUM with OVER clause:**
   Question: How can you use the SUM function with an OVER clause to create a running total or identify streaks in player performance?

   Solution:
   ```sql
   WITH identified AS (
     SELECT *,
     SUM(pts_stayed_above_20) OVER (
       PARTITION BY player_name 
       ORDER BY season
     ) AS streak_identifier 
     FROM did_change
   )
   SELECT * FROM identified;
   ```

4. **COUNT with CASE:**
   Question: Explain how to use COUNT with a CASE statement to tally the number of consecutive seasons a player scored 20 or more points.

   Solution:
   ```sql
   WITH aggregated AS ( 
     SELECT player_name, 
     COUNT(CASE WHEN pts >= 20 THEN 1 END) AS consecutive_seasons
     FROM identified 
     GROUP BY player_name, streak_identifier 
     ORDER BY 2 DESC
   )
   SELECT * FROM aggregated;
   ```

5. **DENSE_RANK, RANK, and ROW_NUMBER:**
   Question: What's the difference between DENSE_RANK, RANK, and ROW_NUMBER? How would you use them to rank players based on their consecutive high-scoring seasons?

   Solution:
   ```sql
   WITH ranked AS (  
     SELECT *, 
     DENSE_RANK() OVER (ORDER BY consecutive_seasons DESC) AS dense_rank,
     RANK() OVER (ORDER BY consecutive_seasons DESC) AS rank,
     ROW_NUMBER() OVER (ORDER BY consecutive_seasons DESC) AS row_number
     FROM aggregated
   )
   SELECT * FROM ranked
   WHERE dense_rank <= 10;
   ```

6. **Cumulative Sum:**
   Question: How would you calculate a cumulative sum of quantity sold over time using a window function?

   Solution:
   ```sql
   WITH rolling_sum AS (
     SELECT *, SUM(qty) OVER (
       ORDER BY day
     ) AS cumsum
     FROM demand2
   )
   SELECT * FROM rolling_sum;
   ```

7. **Partitioned Cumulative Sum:**
   Question: Extend the previous cumulative sum question to calculate separate running totals for each product category.

   Solution:
   ```sql
   WITH rolling_sum_by_prod AS (
     SELECT *, SUM(qty) OVER (
       PARTITION BY product
       ORDER BY day
     ) AS cumsum
     FROM demand
   )
   SELECT * FROM rolling_sum_by_prod;
   ```

8. **Top N per Group:**
   Question: How can you use window functions to find the two days with the lowest sales for each product?

   Solution:
   ```sql
   WITH rolling_sum_by_prod AS (
     SELECT *, DENSE_RANK() OVER (
       PARTITION BY product
       ORDER BY qty ASC
     ) AS RN
     FROM demand
   )
   SELECT * FROM rolling_sum_by_prod
   WHERE RN <= 2;
   ```

9. **Percentage Change:**
   Question: Write a query to calculate the day-over-day percentage change in quantity sold for each product.

   Solution:
   ```sql
   WITH sorted AS (
     SELECT *, LAG(qty, 1) OVER (
       PARTITION BY product
       ORDER BY day
     ) AS previous_qty
     FROM demand
   )
   SELECT *, 
   ((qty - previous_qty) / NULLIF(previous_qty, 0)) * 100 AS percentage_change
   FROM sorted;
   ```

10. **Min and Max per Group:**
    Question: How would you add columns showing the minimum and maximum quantity sold for each product across all days?

    Solution:
    ```sql
    WITH min_max AS (
      SELECT *, 
      MAX(qty) OVER (PARTITION BY product) AS max_sold,
      MIN(qty) OVER (PARTITION BY product) AS min_sold
      FROM demand
    )
    SELECT * FROM min_max;
    ```

11. **Nth Largest and Smallest:**
    Question: Write a query to find the second largest and second smallest sales quantity for each product.

    Solution:
    ```sql
    WITH diff AS (
      SELECT *, 
      ROW_NUMBER() OVER (
        PARTITION BY product
        ORDER BY qty DESC
      ) AS row_num_desc,
      ROW_NUMBER() OVER (
        PARTITION BY product
        ORDER BY qty ASC
      ) AS row_num_asc
      FROM demand
    )
    SELECT product, day, qty
    FROM diff
    WHERE row_num_desc = 2 OR row_num_asc = 2;
    ```

12. **Ranking within Groups:**
    Question: How would you identify the product with the highest quantity sold for each day?

    Solution:
    ```sql
    WITH diff AS (
      SELECT *, DENSE_RANK() OVER (
        PARTITION BY day
        ORDER BY qty DESC
      ) AS rank_qty
      FROM demand
    )
    SELECT *
    FROM diff
    WHERE rank_qty = 1;
    ```

## Practice Tips

- Try to solve these questions on your own before looking at the solutions.
- Use an SQL editor or database system to test your queries.
- Pay attention to the specific requirements of each question, such as partitioning and ordering in window functions.
- Consider edge cases and how your queries would handle them.
- After implementing a solution, compare it with the provided solution and understand any differences.

## Additional Resources

- [SQL Window Functions Tutorial](https://www.sqlshack.com/sql-window-functions-overview/)
- [PostgreSQL Window Functions](https://www.postgresql.org/docs/current/tutorial-window.html)
- [MySQL Window Functions](https://dev.mysql.com/doc/refman/8.0/en/window-functions.html)

Happy querying!
