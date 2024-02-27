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
