--Netflix Project
DROP TABLE IF EXISTS netflix; 
CREATE TABLE Neflix
(
	show_id VARCHAR(8),
	type VARCHAR(15),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating	VARCHAR(10),
	duration VARCHAR(30),	
	listed_in VARCHAR(150),
	description VARCHAR(300)
);

SELECT * FROM Neflix;

SELECT COUNT(*) as total FROM Neflix;

SELECT DISTINCT type from neflix;

--15 Business Problem

-- 1. Count the number of Movies vs TV Shows
SELECT type, COUNT(*) AS total_content
FROM Neflix
GROUP BY type;


--2. Find the most common rating for movies and TV shows
SELECT type,rating
FROM 
(
	SELECT type,rating,COUNT(*),
	RANK () OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	from Neflix
	GROUP BY 1,2
) as t1
WHERE ranking = 1;


--3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM neflix
WHERE type='Movie' and release_year=2020


4. Find the top 5 countries with the most content on Netflix
SELECT * 
FROM
(
    SELECT 
	--UNNEST() converts the array into separate rows.
	--TRIM() removes those extra spaces.
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country,
        COUNT(*) AS total_content
    FROM neflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;


--5. Identify the longest movie
SELECT * FROM neflix
WHERE type='Movie'
AND duration=(
SELECT MAX(duration) from neflix
);


6. Find content added in the last 5 years
SELECT *
FROM neflix
--Show only those rows where the date_added is on or after the date five years ago.
WHERE TO_DATE(date_added, 'Month DD, YYYY') --This converts the text into a real DATE.
>= CURRENT_DATE - INTERVAL '5 years'; --Subtracts five years from today's date


7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM 
(SELECT
 *, UNNEST(STRING_TO_ARRAY(director,',')) AS director_n
 FROM neflix
 ) as t
WHERE director='Rajiv Chilaka';

SELECT * FROM neflix
WHERE director ILIKE 'Rajiv Chilaka'; --ILIKE ignores letter case.


8. List all TV shows with more than 5 seasons
SELECT * 
FROM neflix
WHERE type='TV Show' and duration >'5 seasons';-- Duration is text, not a number here, so incorrect

--SPLIT_PART(string, delimiter, part_number)::INT
--string → The text to split.
--delimiter → The character used to split the text.
--part_number → Which part you want (starts from 1).
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;


--9. Count the number of content items in each genre
SELECT 
UNNEST (STRING_TO_ARRAY(listed_in,',')) as genre,
COUNT(*) AS total_content
FROM neflix
GROUP BY 1;


--10.Find each year and the average numbers of content release in India on netflix.
--return top 5 year with highest avg content release!
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND( --The fraction of Indian titles released in that year.
        COUNT(show_id)::numeric /  --numeric converts an integer into a decimal number
        (SELECT COUNT(show_id) FROM neflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release  --The total number of Indian titles as a decimal.
FROM neflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;


--11. List all movies that are documentaries
SELECT * FROM neflix
WHERE listed_in ILIKE '%documentaries';


--12. Find all content without a director
SELECT * 
FROM neflix
WHERE director is null; --List content that does not have a director


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * 
FROM neflix 
WHERE casts LIKE '%Salman Khan%' 
AND release_year>EXTRACT(YEAR FROM Current_Date)- 10; --returns Only titles released after 2016.

--Returns only the year from today's date. (EXTRACT(YEAR FROM Current_Date))


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT UNNEST(STRING_TO_ARRAY(casts,',')) as actor,
COUNT(*)
FROM neflix
WHERE country='India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;


--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

SELECT category, COUNT(*) AS content_count
FROM (
SELECT CASE 
WHEN description ILIKE '%kill%' OR description ILIKE '%Violence%' Then 'Bad'
ELSE 'Good'
END as category
FROM neflix
) AS categorized_content
GROUP BY category;













