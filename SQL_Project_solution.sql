-- 1. COUNT THE NUMBER OF MOVIES VS TV SHOWS
SELECT COUNT(*), TYPE
FROM NETFLIX_TITLES
GROUP BY TYPE;

-- 2. FIND THE MOST COMMON RATING FOR MOVIES AND TV SHOWS
SELECT RATING, TYPE, COUNT_RATING 
FROM (
    SELECT RATING, TYPE, COUNT(*) AS COUNT_RATING,
           RANK() OVER (PARTITION BY TYPE ORDER BY COUNT(*) DESC) AS RANKING
    FROM NETFLIX_TITLES
    WHERE RATING IS NOT NULL
    GROUP BY RATING, TYPE
) AS RANKED_RATINGS
WHERE RANKING = 1;

-- 3. LIST ALL MOVIES RELEASED IN A SPECIFIC YEAR (E.G., 2020)
SELECT TITLE, RELEASE_YEAR
FROM NETFLIX_TITLES
WHERE TYPE = 'MOVIE' AND RELEASE_YEAR = 2020;

-- 4. FIND THE TOP 5 COUNTRIES WITH THE MOST CONTENT ON NETFLIX
WITH TEMP_COUNTRY AS (
    SELECT TRIM(VALUE) AS COUNTRY
    FROM NETFLIX_TITLES
    CROSS JOIN JSON_TABLE(CONCAT('["', REPLACE(COUNTRY, ',', '","'), '"]'), '$[*]' COLUMNS(VALUE VARCHAR(200) PATH '$')) AS TEMP 
)
SELECT COUNTRY, COUNT(*) AS TOTAL_CONTENT
FROM TEMP_COUNTRY
WHERE COUNTRY IS NOT NULL AND COUNTRY <> ''
GROUP BY COUNTRY
ORDER BY TOTAL_CONTENT DESC
LIMIT 5;

-- 5. IDENTIFY THE LONGEST MOVIE
SELECT TITLE, DURATION
FROM NETFLIX_TITLES
WHERE TYPE = 'MOVIE'
ORDER BY CAST(REGEXP_SUBSTR(DURATION, '[0-9]+') AS UNSIGNED) DESC
LIMIT 1;

-- 6. FIND CONTENT ADDED IN THE LAST 5 YEARS
WITH CTE_DATE AS (
    SELECT TITLE, DATE_ADDED, 
           SUBSTRING(DATE_ADDED, -4, 4) AS YEAR_ADDED
    FROM NETFLIX_TITLES
    WHERE DATE_ADDED IS NOT NULL AND DATE_ADDED != ''
)
SELECT TITLE, DATE_ADDED
FROM CTE_DATE
WHERE YEAR_ADDED >= YEAR(DATE_SUB('2021-12-30', INTERVAL 5 YEAR))
ORDER BY YEAR_ADDED;

-- 7. FIND ALL THE MOVIES/TV SHOWS BY DIRECTOR 'RAJIV CHILAKA'!
SELECT TITLE, TYPE, DIRECTOR 
FROM NETFLIX_TITLES
WHERE DIRECTOR = 'RAJIV CHILAKA';

-- 8. LIST ALL TV SHOWS WITH MORE THAN 5 SEASONS
SELECT TITLE, TYPE, DURATION 
FROM NETFLIX_TITLES
WHERE TYPE = 'TV SHOW' AND CAST(REGEXP_SUBSTR(DURATION, '[0-9]+') AS UNSIGNED) > 5;

-- 9. COUNT THE NUMBER OF CONTENT ITEMS IN EACH GENRE
WITH TEMP_GENRE AS (
    SELECT TRIM(GENRE) AS GENRE
    FROM NETFLIX_TITLES
    CROSS JOIN JSON_TABLE(CONCAT('["', REPLACE(LISTED_IN, ',', '","'), '"]'), '$[*]' COLUMNS(GENRE VARCHAR(200) PATH '$')) AS TEMP
)
SELECT GENRE, COUNT(*) AS TOTAL_CONTENT
FROM TEMP_GENRE
WHERE GENRE IS NOT NULL AND GENRE <> ''
GROUP BY GENRE
ORDER BY TOTAL_CONTENT DESC;

-- 10. FIND EACH YEAR AND THE AVERAGE NUMBER OF CONTENT RELEASES IN INDIA ON NETFLIX
SELECT 
  COUNTRY,
  EXTRACT(YEAR FROM STR_TO_DATE(DATE_ADDED, '%M %d, %Y')) AS YEAR_ADDED,
  COUNT(SHOW_ID) AS TOTAL_RELEASE,
  ROUND(
    COUNT(SHOW_ID) * 100.0 / 
    (SELECT COUNT(SHOW_ID) FROM NETFLIX_TITLES WHERE COUNTRY = 'INDIA' AND DATE_ADDED IS NOT NULL), 
    2
  ) AS AVG_RELEASE_PERCENT
FROM NETFLIX_TITLES
WHERE COUNTRY = 'INDIA'
  AND DATE_ADDED IS NOT NULL
GROUP BY COUNTRY, YEAR_ADDED
ORDER BY AVG_RELEASE_PERCENT DESC
LIMIT 5;

-- 11. LIST ALL MOVIES THAT ARE DOCUMENTARIES
SELECT * 
FROM NETFLIX_TITLES
WHERE TYPE = 'MOVIE' 
  AND LISTED_IN LIKE '%DOCUMENTARIES%';
  
-- 12. FIND ALL CONTENT WITHOUT A DIRECTOR
SELECT * FROM NETFLIX_TITLES WHERE DIRECTOR IS NULL;

-- 13. FIND HOW MANY MOVIES ACTOR 'SALMAN KHAN' APPEARED IN THE LAST 10 YEARS!
SELECT * FROM NETFLIX_TITLES
WHERE CAST LIKE '%SALMAN KHAN%' AND TYPE = 'MOVIE'
AND RELEASE_YEAR > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. FIND THE TOP 10 ACTORS WHO HAVE APPEARED IN THE HIGHEST NUMBER OF MOVIES PRODUCED IN INDIA
WITH TEMP_GENRE AS (
    SELECT TRIM(ACTORS) AS ACTORS, COUNTRY
    FROM NETFLIX_TITLES
    CROSS JOIN JSON_TABLE(CONCAT('["', REPLACE(CAST, ',', '","'), '"]'), '$[*]' COLUMNS(ACTORS VARCHAR(100) PATH '$')) AS TEMPO
)
SELECT ACTORS, COUNT(*) AS TOTAL_CONTENT
FROM TEMP_GENRE 
WHERE LOWER(COUNTRY) LIKE "%INDIA%" AND ACTORS <> ''
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15. CATEGORIZE THE CONTENT BASED ON THE PRESENCE OF THE KEYWORDS 'KILL' AND 'VIOLENCE' IN THE DESCRIPTION FIELD. 
-- LABEL CONTENT CONTAINING THESE KEYWORDS AS 'BAD' AND ALL OTHER CONTENT AS 'GOOD'. COUNT HOW MANY ITEMS FALL INTO EACH CATEGORY.
SELECT 
    CATEGORY,
    TYPE,
    COUNT(*) AS CONTENT_COUNT
FROM (
    SELECT *,
           CASE 
               WHEN DESCRIPTION LIKE '%KILL%' OR DESCRIPTION LIKE '%VIOLENCE%' THEN 'BAD'
               ELSE 'GOOD'
           END AS CATEGORY
    FROM NETFLIX_TITLES
) AS CATEGORIZED_CONTENT
GROUP BY 1,2
ORDER BY 2;
