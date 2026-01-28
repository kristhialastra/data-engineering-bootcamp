--- I. Analyze Netflix Data:

--- 1. Find the top 5 content types (Movie/TV Show) by number of releases each year.

-- Kunin yung type (Movie/TV Show) at release_year, then count

SELECT 
    type, 
    release_year, 
    COUNT(*) AS count
FROM netflix
GROUP BY type, release_year  -- group by both para makita per year per type
ORDER BY count DESC           -- highest count muna
LIMIT 5;

--- 2. Calculate the total number of releases per country and list the top 10 countries with the most content.

-- Count lahat ng titles per country
SELECT 
    country, 
    COUNT(*) AS count
FROM netflix
WHERE country IS NOT NULL     -- tanggalin yung walang country
    AND country != ''
GROUP BY country              -- group by country para makuha yung count per country
ORDER BY count DESC           -- highest muna
LIMIT 10;


--- II. Write 3 complex SQL queries demonstrating join concepts on the single netflix_titles table:

--- 1. **Self-join (conceptual):** Find pairs of movies/TV shows that share at least one common director or cast member.

-- CTE para i-normalize yung cast column
WITH actors_normalized AS (
    SELECT 
        title,
        director,
        TRIM(UNNEST(STRING_TO_ARRAY("cast", ','))) AS actor
    FROM netflix
    WHERE "cast" IS NOT NULL 
        AND "cast" != ''
)

-- Para sa shared DIRECTOR
SELECT 
    n1.title AS title1,
    n2.title AS title2,
    'Director: ' || n1.director AS shared_type,  -- ano yung shared (director or actor)
    n1.director AS shared_person                 -- kung sino
FROM netflix AS n1
JOIN netflix AS n2
    ON n1.director = n2.director
WHERE n1.title < n2.title
    AND n1.director IS NOT NULL
    AND n1.director != ''

UNION

-- Para sa shared ACTORS - pero i-aggregate na by title pair
SELECT 
    a1.title AS title1,
    a2.title AS title2,
    'Actors' AS shared_type,                     -- marker na multiple actors
    STRING_AGG(a1.actor, ', ') AS shared_person  
    -- combine lahat ng actors into one string since for reporting lang naman
FROM actors_normalized AS a1
JOIN actors_normalized AS a2
    ON a1.actor = a2.actor
WHERE a1.title < a2.title
GROUP BY a1.title, a2.title                      -- group by title pair para ma-aggregate yung actors


--- 2. **Subquery/CTE for "Inner Join" concept:** Identify titles where the country is among the top 3 countries for content releases.

-- CTE para makuha yung top 3 countries with ranking
WITH top_countries AS (
    SELECT 
        country,
        COUNT(*) AS content_count,
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS country_rank  -- rank 1, 2, 3
    FROM netflix
    WHERE country IS NOT NULL 
        AND country != ''
    GROUP BY country
    ORDER BY COUNT(*) DESC
    LIMIT 3
)

-- Kunin lahat ng titles from top 3 countries
SELECT 
    tc.country_rank,
    n.country AS country_name,
    n.title,
    n.type,
    n.release_year
FROM netflix AS n
JOIN top_countries AS tc 
    ON n.country = tc.country
ORDER BY 
    tc.country_rank,    
    -- USA first (rank 1), then India (rank 2), then UK (rank 3)
    n.release_year DESC,   -- within each country, newest year first
    n.title ASC            -- within each year, alphabetical by title

--- 3. **NOT EXISTS for "Left Join" concept:** Find movies/TV shows that are not associated with any of the top 5 most frequent genres (use a subquery to define top genres).

-- CTE para makuha yung top 5 genres
WITH genres_normalized AS (
    SELECT 
        show_id,
        title,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre  -- split yung genres
    FROM netflix
    WHERE listed_in IS NOT NULL
),
top_genres AS (
    SELECT genre
    FROM genres_normalized
    GROUP BY genre
    ORDER BY COUNT(*) DESC
    LIMIT 5                                      -- top 5 most frequent genres
)

-- Kunin yung titles na WALA sa top 5 genres
SELECT DISTINCT
    n.title,
    n.type,
    n.listed_in AS non_top5_genre               -- renamed column!
FROM netflix AS n
WHERE NOT EXISTS (                               
    SELECT 1
    FROM genres_normalized AS gn
    WHERE gn.show_id = n.show_id                
        AND gn.genre IN (SELECT genre FROM top_genres)  
)
ORDER BY n.listed_in, n.title                    -- sort by genre first, then alphabetical by title


--- III. Window Function Exercise:
  
--- 1. For each release_year and type (Movie/TV Show), assign a rank to each title based on its duration (or a proxy like num_seasons for TV shows, if available/simulated).

-- Parse duration into minutes para sa movies
-- Note: duration column format is "90 min" for movies or "1 Season" for TV shows
SELECT 
    title,
    type,
    release_year,
    duration,
    CASE 
        WHEN type = 'Movie' THEN CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER)  -- kunin yung number part lang
        ELSE NULL  -- for TV shows, wag na muna (or pwede gawin 0)
    END AS duration_minutes,
    RANK() OVER (                                -- window function para mag-rank
        PARTITION BY release_year, type          -- separate ranking per year at per type
        ORDER BY 
            CASE 
                WHEN type = 'Movie' THEN CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER)
                ELSE 0
            END DESC                             -- highest duration = rank 1
    ) AS duration_rank
FROM netflix
WHERE type = 'Movie'                             -- movies lang muna kasi TV shows walang minutes
    AND duration IS NOT NULL
ORDER BY release_year DESC, duration_rank)

--- 2. Find the previous release year's content count for each country using LAG() by country and ordered by year.

-- CTE para makuha muna yung count per country per year
WITH country_year_counts AS (
    SELECT 
        country,
        release_year,
        COUNT(*) AS content_count
    FROM netflix
    WHERE country IS NOT NULL 
        AND country != ''
        AND country NOT LIKE '%,%'  
        -- exclude multi-country entries! tanggalin yung may comma
    GROUP BY country, release_year
)

  -- Use LAG to get previous year's count
SELECT 
    country,
    release_year,
    content_count,
    COALESCE(
        LAG(content_count) OVER (                    
            PARTITION BY country                     
            ORDER BY release_year                    
        ), 
        0
    ) AS previous_year_count,                        -- NULL = 0 na
    content_count - COALESCE(
        LAG(content_count) OVER (
            PARTITION BY country 
            ORDER BY release_year
        ),
        0
    ) AS year_over_year_change                     -- NULL = 0 na din dito
FROM country_year_counts
ORDER BY country, release_year DESC
