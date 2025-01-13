create database netflix_db;

use netflix_db;
show tables;

select * from netflix;


-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems
-- 1Count the number of Movies vs. TV Shows
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows
SELECT 
    type, 
    rating AS most_frequent_rating, 
    MAX(rating_count) AS max_rating_count
FROM (
    SELECT 
        type, 
        rating, 
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
) AS RankedRatings
GROUP BY type, rating
ORDER BY MAX(rating_count) DESC;


-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * 
FROM netflix
WHERE release_year = 2020
  AND type = 'Movie';


-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
    country,
    COUNT(*) AS total_content
FROM (
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n.n), ',', -1)) AS country
    FROM netflix
    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    ) n
    ON CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) + 1 >= n.n
) AS split_countries
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the longest movie
SELECT * 
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;


-- 6. Find content added in the last 5 years
SELECT 
    date_added,
    STR_TO_DATE(date_added, '%M %d, %Y') AS parsed_date,
    DATE_SUB(CURDATE(), INTERVAL 5 YEAR) AS cutoff_date
FROM netflix
WHERE date_added IS NOT NULL
LIMIT 10;


-- 7. Find all the movies/TV shows by director 'Scott Stewart'!
SELECT * 
FROM (
    SELECT 
        *,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(director, ',', n.n), ',', -1)) AS director_name
    FROM netflix
    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    ) n
    ON CHAR_LENGTH(director) - CHAR_LENGTH(REPLACE(director, ',', '')) + 1 >= n.n
) AS directors
WHERE director_name = 'Scott Stewart';


-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;


-- 9. Count the number of content items in each genre
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.n), ',', -1)) AS genre,
    COUNT(*) AS total_content
FROM netflix
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
) n
ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) + 1 >= n.n
GROUP BY genre
ORDER BY total_content DESC;


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
SELECT 
    release_year,
    COUNT(*) AS total_release,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM netflix WHERE country = 'India') * 100, 2) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY release_year
ORDER BY avg_release DESC
LIMIT 5;


-- 11. List all movies that are documentaries
SELECT * 
FROM netflix
WHERE type = 'Movie' AND listed_in LIKE '%Documentaries%';


-- 12. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL OR director = '';


-- 13. Find how many movies actor 'Klara Castanho' appeared in last 10 years!
SELECT * 
FROM netflix
WHERE cast LIKE '%Klara Castanho%'
  AND release_year > YEAR(CURDATE()) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', n.n), ',', -1)) AS actor,
    COUNT(*) AS total_movies
FROM netflix
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 
    UNION ALL SELECT 9 UNION ALL SELECT 10
) n ON CHAR_LENGTH(cast) - CHAR_LENGTH(REPLACE(cast, ',', '')) + 1 >= n.n
WHERE country = 'India'
GROUP BY actor
ORDER BY total_movies DESC
LIMIT 10;

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
SELECT 
    CASE 
        WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS category,
    type,
    COUNT(*) AS content_count
FROM netflix
GROUP BY category, type
ORDER BY type;

-- End of reports
