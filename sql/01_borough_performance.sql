-- NYC Hospital Quality Analysis — first queries
-- Database: data/nyc_hospitals.db (table: hospitals, from data/cleaned/nyc_hospitals_cleaned.csv)
-- Unrated psychiatric/specialty facilities are excluded via is_rated = 1.

-- Q1: Top 5 rated hospitals in NYC
SELECT facility_name, borough, overall_rating
FROM hospitals
WHERE is_rated = 1
ORDER BY overall_rating DESC
LIMIT 5;

-- Q2: Rating profile by borough — count, average, and range
SELECT borough,
       COUNT(*) AS hospitals,
       ROUND(AVG(overall_rating), 2) AS avg_rating,
       MIN(overall_rating) AS worst,
       MAX(overall_rating) AS best
FROM hospitals
WHERE is_rated = 1
GROUP BY borough
ORDER BY avg_rating DESC;
