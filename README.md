# Netflix Movies and TV Shows Data Analysis using MY SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT COUNT(*), TYPE
FROM NETFLIX_TITLES
GROUP BY TYPE;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT RATING, TYPE, COUNT_RATING 
FROM (
    SELECT RATING, TYPE, COUNT(*) AS COUNT_RATING,
           RANK() OVER (PARTITION BY TYPE ORDER BY COUNT(*) DESC) AS RANKING
    FROM NETFLIX_TITLES
    WHERE RATING IS NOT NULL
    GROUP BY RATING, TYPE
) AS RANKED_RATINGS
WHERE RANKING = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT TITLE, RELEASE_YEAR
FROM NETFLIX_TITLES
WHERE TYPE = 'MOVIE' AND RELEASE_YEAR = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
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
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT TITLE, DURATION
FROM NETFLIX_TITLES
WHERE TYPE = 'MOVIE'
ORDER BY CAST(REGEXP_SUBSTR(DURATION, '[0-9]+') AS UNSIGNED) DESC
LIMIT 1;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
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
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT TITLE, TYPE, DIRECTOR 
FROM NETFLIX_TITLES
WHERE DIRECTOR = 'RAJIV CHILAKA';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT TITLE, TYPE, DURATION 
FROM NETFLIX_TITLES
WHERE TYPE = 'TV SHOW' AND CAST(REGEXP_SUBSTR(DURATION, '[0-9]+') AS UNSIGNED) > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
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
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * 
FROM NETFLIX_TITLES
WHERE TYPE = 'MOVIE' 
  AND LISTED_IN LIKE '%DOCUMENTARIES%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * FROM NETFLIX_TITLES WHERE DIRECTOR IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * FROM NETFLIX_TITLES
WHERE CAST LIKE '%SALMAN KHAN%' AND TYPE = 'MOVIE'
AND RELEASE_YEAR > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.


This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!


