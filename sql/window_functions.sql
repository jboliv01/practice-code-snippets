-- video ref: https://www.youtube.com/watch?v=dqwhNcZoMOQ&t=3064s
-- online sql editor: https://dataexpert.io/classroom/zachwilson

WITH lagged as (
  SELECT player_name, 
  season, 
  pts, 
  LAG(pts, 1) OVER (
  PARTITION BY player_name
  ORDER BY season ) as pts_last_season
FROM bootcamp.nba_player_seasons 
),

did_change as (
  SELECT *, 
  CASE WHEN pts >= 20 AND   pts_last_season >= 20 THEN 0 ELSE 1 END as pts_stayed_above_20
  FROM lagged
),

identified as (
  SELECT *,
  SUM(pts_stayed_above_20) OVER (
  PARTITION BY player_name 
  ORDER BY season) as streak_identfier 
  FROM did_change
),

aggregated as ( 
SELECT player_name, 
COUNT(CASE WHEN pts >= 20 THEN 1 END) as consecutive_seasons
FROM identified 
GROUP BY player_name, streak_identfier 
ORDER BY 2 DESC),

ranked as (  
SELECT *, DENSE_RANK() OVER (
ORDER BY consecutive_seasons DESC) as dense_rank,
RANK() OVER (
ORDER BY consecutive_seasons DESC) as rank,
ROW_NUMBER() OVER (
ORDER BY consecutive_seasons DESC) as row_number
FROM aggregated
)

SELECT * FROM ranked
WHERE dense_rank <= 10

-- ref: https://www.machinelearningplus.com/sql/sql-window-functions-exercises/

-- From the demand2 table, find the cumulative total sum for qty.

WITH rolling_sum as (
SELECT *, SUM(qty) OVER (
  ORDER BY day) as cumsum
  FROM demand2
  )
  
SELECT * FROM lagged;

-- From the demand table, find the cumulative total sum for qty for each product category.

WITH rolling_sum_by_prod as (
SELECT *, SUM(qty) OVER (
  PARTITION BY product
  ORDER BY day) as cumsum
  FROM demand
  )
  
SELECT * FROM rolling_sum_by_prod;

-- Extract the two worst performing days of each product in terms of number of qty sold. Paraphrasing it: Get the days corresponding to the two minimum most values of qty for each product.

WITH rolling_sum_by_prod as (
SELECT *, dense_rank() OVER (
  PARTITION BY product
  ORDER BY qty ASC) as RN
  FROM demand
  )
  
SELECT * FROM rolling_sum_by_prod
WHERE RN <= 2;

-- Sort the table by qty for each product and compute the percentage increase (or decrease) compared to the previous day.

WITH sorted as (
  SELECT *, LAG(qty, 1) OVER (
    PARTITION BY product
    ORDER BY day) as previous_qty
  FROM demand
  )
  
  SELECT *, SUM(((qty - previous_qty) / previous_qty) * 100) 
  FROM sorted
  GROUP BY product, day, qty
  
-- Create two new columns in the table that shows the minimum and the maximum quantity sold for each product.

WITH min_max as (
  SELECT *, MAX(qty) OVER ( 
    PARTITION BY product) as max_sold,
	MIN(qty) OVER ( 
    PARTITION BY product) as min_sold
  FROM demand
  )
  
  SELECT * from min_max;

-- Calculate the diffence between the second largest and the second smallest sales qty for each product.

WITH diff as (
  SELECT *, ROW_NUMBER() OVER (
    PARTITION BY product
    ORDER BY qty DESC) as row_num_desc,
    ROW_NUMBER() OVER (
    PARTITION BY product
    ORDER BY qty ASC) as row_num_asc
  FROM demand
  )
  
  SELECT product, day, qty
  FROM diff
  WHERE row_num_desc = 2 OR row_num_asc = 2

  -- Create a table to show the day and the names of the product the the highest qty sale.

  
WITH diff as (
  SELECT *, DENSE_RANK() OVER (
    PARTITION BY day
    ORDER BY qty DESC) as rank_qty
  FROM demand
  )
  
  SELECT *
  FROM diff
  WHERE rank_qty = 1