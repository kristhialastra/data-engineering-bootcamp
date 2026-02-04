--- Q1

SELECT 
    CASE 
        WHEN country LIKE '%United States%' THEN 'US'
        WHEN country = 'Unknown' THEN 'Unknown'
        ELSE 'International'
    END as origin,
    COUNT(*) as titles,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM netflix_cleaned
GROUP BY origin
ORDER BY titles DESC;

--- Q2. Which genres dominate our catalog vs underrepresented niches?
SELECT 
    TRIM(genre) as genre,
    COUNT(*) as title_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM netflix_cleaned,
    LATERAL UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
GROUP BY TRIM(genre)
ORDER BY title_count DESC
LIMIT 10;

--- Q3. What's our content acquisition trend - are we growing or slowing down?
SELECT 
    year_added,
    COUNT(*) as titles_added,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percent_of_total
FROM netflix_cleaned
WHERE year_added IS NOT NULL
GROUP BY year_added
ORDER BY year_added DESC;

--- Q4. Are we heavily Movie-focused or balancing with TV Shows?
SELECT 
    type,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM netflix_cleaned
GROUP BY type;

--- Q5. Which top 3 countries should we focus acquisition efforts on?
SELECT 
    country,
    COUNT(*) as title_count,
    ROUND(AVG(release_year), 0) as avg_release_year
FROM netflix_cleaned
WHERE country != 'Unknown'
GROUP BY country
ORDER BY title_count DESC
LIMIT 3;

--- Q6. What's the typical movie runtime we're producing?
SELECT 
    CASE 
        WHEN CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) < 60 THEN 'Short (<60 min)'
        WHEN CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) BETWEEN 60 AND 90 THEN 'Standard (60-90 min)'
        WHEN CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) BETWEEN 91 AND 120 THEN 'Long (91-120 min)'
        ELSE 'Epic (120+ min)'
    END as runtime_category,
    COUNT(*) as movie_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM netflix_cleaned
WHERE type = 'MOVIE' AND duration LIKE '%min%'
GROUP BY runtime_category
ORDER BY movie_count DESC;

--- Q7. Do we rely on repeat directors or constantly find new talent?
WITH director_frequency AS (
    SELECT 
        director,
        COUNT(*) as title_count
    FROM netflix_cleaned
    WHERE director != 'Unknown'
    GROUP BY director
)
SELECT 
    CASE 
        WHEN title_count = 1 THEN 'One-time directors'
        WHEN title_count BETWEEN 2 AND 3 THEN 'Occasional (2-3 titles)'
        ELSE 'Frequent (4+ titles)'
    END as director_type,
    COUNT(*) as director_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM director_frequency
GROUP BY director_type
ORDER BY director_count DESC;

--- Q8. What's our production split across content ratings?
SELECT 
    CASE 
        WHEN rating IN ('G', 'PG', 'TV-Y', 'TV-G', 'TV-Y7', 'TV-Y7-FV') THEN 'Kids/Family'
        WHEN rating IN ('PG-13', 'TV-PG', 'TV-14') THEN 'Teen/General'
        WHEN rating IN ('R', 'TV-MA', 'NC-17') THEN 'Mature'
        ELSE 'Unrated/Other'
    END as audience_category,
    COUNT(*) as titles,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM netflix_cleaned
GROUP BY audience_category
ORDER BY titles DESC;

--- Q9. How complex are our productions (cast size)?
SELECT 
    CASE 
        WHEN cast_size = 0 THEN 'No cast listed'
        WHEN cast_size BETWEEN 1 AND 3 THEN 'Small cast (1-3)'
        WHEN cast_size BETWEEN 4 AND 7 THEN 'Medium cast (4-7)'
        ELSE 'Large cast (8+)'
    END as cast_category,
    COUNT(*) as titles,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM netflix_cleaned
GROUP BY cast_category
ORDER BY titles DESC;

--- Q10. Which rating produces the longest content on average?
SELECT 
    rating,
    COUNT(*) as movie_count,
    ROUND(AVG(CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER)), 0) as avg_minutes
FROM netflix_cleaned
WHERE type = 'MOVIE' AND duration LIKE '%min%'
GROUP BY rating
HAVING COUNT(*) >= 20
ORDER BY avg_minutes DESC
LIMIT 5;

--- Q11. What's our overall metadata completeness score?
SELECT 
    ROUND(COUNT(CASE WHEN director != 'Unknown' THEN 1 END) * 100.0 / COUNT(*), 2) as director_completeness,
    ROUND(COUNT(CASE WHEN cast_size > 0 THEN 1 END) * 100.0 / COUNT(*), 2) as cast_completeness,
    ROUND(COUNT(CASE WHEN country != 'Unknown' THEN 1 END) * 100.0 / COUNT(*), 2) as country_completeness,
    ROUND(COUNT(CASE WHEN date_added_clean IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as date_completeness
FROM netflix_cleaned;

--- Q12. How fresh is our catalog (age distribution)?
SELECT 
    CASE 
        WHEN year_added - release_year = 0 THEN 'Same year (0 lag)'
        WHEN year_added - release_year BETWEEN 1 AND 2 THEN 'Recent (1-2 years)'
        WHEN year_added - release_year BETWEEN 3 AND 5 THEN 'Moderate (3-5 years)'
        ELSE 'Older (6+ years)'
    END as age_category,
    COUNT(*) as titles,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM netflix_cleaned
WHERE year_added IS NOT NULL 
    AND release_year IS NOT NULL
    AND year_added >= release_year
GROUP BY age_category
ORDER BY titles DESC;

--- Q13. When do we add the most content (operational capacity planning)?
SELECT 
    CASE 
        WHEN month_added IN (1,2,3) THEN 'Q1 (Jan-Mar)'
        WHEN month_added IN (4,5,6) THEN 'Q2 (Apr-Jun)'
        WHEN month_added IN (7,8,9) THEN 'Q3 (Jul-Sep)'
        WHEN month_added IN (10,11,12) THEN 'Q4 (Oct-Dec)'
    END as quarter,
    COUNT(*) as titles_added,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM netflix_cleaned
WHERE month_added IS NOT NULL
GROUP BY quarter
ORDER BY titles_added DESC;

--- Q14. How many titles need multi-country regional support?
SELECT 
    CASE 
        WHEN country LIKE '%,%' THEN 'Multi-country (needs regional ops)'
        WHEN country = 'Unknown' THEN 'Unknown (needs investigation)'
        ELSE 'Single country'
    END as regional_complexity,
    COUNT(*) as titles,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM netflix_cleaned
GROUP BY regional_complexity
ORDER BY titles DESC;

--- Q15. Where are our biggest data quality gaps by content type?
SELECT 
    type,
    COUNT(*) as total_titles,
    COUNT(CASE WHEN director = 'Unknown' THEN 1 END) as missing_director,
    COUNT(CASE WHEN cast_size = 0 THEN 1 END) as missing_cast,
    COUNT(CASE WHEN country = 'Unknown' THEN 1 END) as missing_country,
    ROUND(COUNT(CASE WHEN director = 'Unknown' OR cast_size = 0 OR country = 'Unknown' THEN 1 END) * 100.0 / COUNT(*), 2) as incomplete_percentage
FROM netflix_cleaned
GROUP BY type;
