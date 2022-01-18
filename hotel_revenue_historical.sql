-- Combine 3 dataset

SELECT * FROM revenue_2018
UNION
SELECT * FROM revenue_2019
UNION
SELECT * FROM revenue_2020

-- Create temporary table
CREATE TEMPORARY TABLE revenues
SELECT * FROM
(
SELECT * FROM revenue_2018 
UNION
SELECT * FROM revenue_2019
UNION
SELECT * FROM revenue_2020
)bt;

-- JOIN market_segment and meal_cost

SELECT *
FROM revenues
LEFT JOIN market_segment
ON revenues.market_segment = market_segment.market_segment
LEFT JOIN meal_cost
ON meal_cost.meal = revenues.meal

-- Business Question 1: Is the hotel revenue growing by year?

SELECT 
	arrival_date_year,
    hotel,
	ROUND(SUM((stays_in_week_nights + stays_in_weekend_nights)*adr),2) AS total_revenue
FROM revenues
GROUP BY arrival_date_year, hotel
