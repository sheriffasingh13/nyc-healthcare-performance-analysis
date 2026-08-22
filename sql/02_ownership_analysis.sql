-- Does hospital ownership explain the borough rating gap?

-- Q3: ER coverage by borough
SELECT borough, COUNT(*) AS er_hospitals
FROM hospitals
WHERE emergency_services = 'Yes'
GROUP BY borough;

-- Q4: Average rating by ownership group
-- CASE WHEN buckets six detailed ownership types into three comparable groups.
SELECT CASE WHEN ownership LIKE 'Government%' THEN 'Government'
            WHEN ownership LIKE 'Voluntary non-profit%' THEN 'Non-profit'
            ELSE 'Other (VA)' END AS ownership_group,
       COUNT(*) AS hospitals,
       ROUND(AVG(overall_rating), 2) AS avg_rating,
       MIN(overall_rating) AS worst,
       MAX(overall_rating) AS best
FROM hospitals
WHERE is_rated = 1
GROUP BY ownership_group
ORDER BY avg_rating DESC;

-- Q5: Government presence vs. average rating, per borough
-- SUM(CASE WHEN ...) counts only rows matching a condition (conditional count).
-- Finding: the borough gap persists across ownership types, so ownership is
-- only a partial explanation.
SELECT borough,
       COUNT(*) AS rated_hospitals,
       SUM(CASE WHEN ownership LIKE 'Government%' THEN 1 ELSE 0 END) AS government,
       ROUND(AVG(overall_rating), 2) AS avg_rating
FROM hospitals
WHERE is_rated = 1
GROUP BY borough
ORDER BY avg_rating DESC;
