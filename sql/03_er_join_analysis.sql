-- Do low-rated hospitals also have poor ER operations?
-- Joins hospitals (45 NYC facilities) to er_measures (national CMS Timely &
-- Effective Care subset: OP_18b = median ER minutes, OP_22 = % left before being seen).
-- Tables share facility_id (CMS CCN).

-- Q6: Worst ER waits in NYC
SELECT h.facility_name, h.borough, h.overall_rating, e.score AS er_wait_minutes
FROM hospitals h
JOIN er_measures e ON h.facility_id = e.facility_id
WHERE e.measure_id = 'OP_18b' AND e.score IS NOT NULL
ORDER BY e.score DESC
LIMIT 10;

-- Q7: NYC vs national averages for both ER measures
-- LEFT JOIN keeps every national row; the CASE picks out NYC matches only.
-- Finding: NYC median ER visit 216 min vs 157 national; walkouts 2.5% vs 1.7%.
SELECT e.measure_id,
       ROUND(AVG(CASE WHEN h.facility_id IS NOT NULL THEN e.score END), 1) AS nyc_avg,
       ROUND(AVG(e.score), 1) AS national_avg
FROM er_measures e
LEFT JOIN hospitals h ON e.facility_id = h.facility_id
WHERE e.score IS NOT NULL
GROUP BY e.measure_id;

-- Q8: Leadership watchlist — rated 2 stars or below AND ER performance worse
-- than NYC-typical (wait above the 218-min NYC median, or walkout rate >= 3%).
-- MAX(CASE WHEN ...) pivots the two measures into columns; HAVING filters after grouping.
-- Finding: 14 hospitals, 13 of them in the Bronx, Brooklyn, or Queens.
SELECT h.facility_name,
       h.borough,
       h.overall_rating AS stars,
       MAX(CASE WHEN e.measure_id = 'OP_18b' THEN e.score END) AS er_wait_min,
       MAX(CASE WHEN e.measure_id = 'OP_22' THEN e.score END) AS pct_walked_out
FROM hospitals h
JOIN er_measures e ON h.facility_id = e.facility_id
WHERE h.overall_rating <= 2
GROUP BY h.facility_id
HAVING er_wait_min > 218 OR pct_walked_out >= 3
ORDER BY pct_walked_out DESC, er_wait_min DESC;
