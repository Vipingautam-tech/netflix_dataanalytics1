-- ============================================================================
-- NETFLIX MOVIES & TV SHOWS - SQL ANALYSIS
-- Complete SQL Queries for Big Data Analytics Project
-- ============================================================================

-- NOTE: First, import the netflix_cleaned.csv into your SQL database
-- Table name: netflix_data

-- ============================================================================
-- SECTION 1: BASIC DATA EXPLORATION
-- ============================================================================

-- 1.1 View all data
SELECT * FROM netflix_data LIMIT 10;

-- 1.2 Count total records
SELECT COUNT(*) AS total_records 
FROM netflix_data;

-- 1.3 View table structure
PRAGMA table_info(netflix_data);
-- For MySQL use: DESCRIBE netflix_data;
-- For PostgreSQL use: \d netflix_data

-- 1.4 Check for null values in critical columns
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS null_titles,
    SUM(CASE WHEN type IS NULL THEN 1 ELSE 0 END) AS null_types,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS null_countries,
    SUM(CASE WHEN release_year IS NULL THEN 1 ELSE 0 END) AS null_release_years
FROM netflix_data;

-- ============================================================================
-- SECTION 2: CONTENT TYPE ANALYSIS
-- ============================================================================

-- 2.1 Count of Movies vs TV Shows
SELECT 
    type,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_data), 2) AS percentage
FROM netflix_data
GROUP BY type
ORDER BY count DESC;

-- 2.2 Movies vs TV Shows by rating
SELECT 
    type,
    rating,
    COUNT(*) AS count
FROM netflix_data
WHERE rating != 'Not Rated'
GROUP BY type, rating
ORDER BY type, count DESC;

-- 2.3 Average release year by content type
SELECT 
    type,
    ROUND(AVG(release_year), 0) AS avg_release_year,
    MIN(release_year) AS oldest_content,
    MAX(release_year) AS newest_content
FROM netflix_data
WHERE release_year IS NOT NULL
GROUP BY type;

-- ============================================================================
-- SECTION 3: COUNTRY ANALYSIS
-- ============================================================================

-- 3.1 Top 10 countries producing content
SELECT 
    country,
    COUNT(*) AS content_count
FROM netflix_data
WHERE country != 'Unknown' AND country IS NOT NULL
GROUP BY country
ORDER BY content_count DESC
LIMIT 10;

-- 3.2 Countries producing only movies
SELECT 
    country,
    COUNT(*) AS movie_count
FROM netflix_data
WHERE type = 'Movie' AND country != 'Unknown'
GROUP BY country
ORDER BY movie_count DESC
LIMIT 10;

-- 3.3 Countries producing only TV shows
SELECT 
    country,
    COUNT(*) AS tv_show_count
FROM netflix_data
WHERE type = 'TV Show' AND country != 'Unknown'
GROUP BY country
ORDER BY tv_show_count DESC
LIMIT 10;

-- ============================================================================
-- SECTION 4: TEMPORAL ANALYSIS
-- ============================================================================

-- 4.1 Content added per year
SELECT 
    year_added,
    COUNT(*) AS content_count
FROM netflix_data
WHERE year_added IS NOT NULL
GROUP BY year_added
ORDER BY year_added DESC;

-- 4.2 Content added per month (all years combined)
SELECT 
    month_added,
    COUNT(*) AS content_count,
    CASE month_added
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS month_name
FROM netflix_data
WHERE month_added IS NOT NULL
GROUP BY month_added
ORDER BY month_added;

-- 4.3 Year-over-year growth in content
SELECT 
    year_added,
    COUNT(*) AS content_count,
    LAG(COUNT(*)) OVER (ORDER BY year_added) AS prev_year_count,
    COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY year_added) AS yoy_growth
FROM netflix_data
WHERE year_added IS NOT NULL
GROUP BY year_added
ORDER BY year_added;

-- 4.4 Content by release decade
SELECT 
    FLOOR(release_year / 10) * 10 AS decade,
    COUNT(*) AS content_count
FROM netflix_data
WHERE release_year IS NOT NULL
GROUP BY decade
ORDER BY decade DESC;

-- ============================================================================
-- SECTION 5: GENRE/CATEGORY ANALYSIS
-- ============================================================================

-- 5.1 Most common genres (assuming single genre per entry)
SELECT 
    listed_in AS genre,
    COUNT(*) AS count
FROM netflix_data
WHERE listed_in IS NOT NULL
GROUP BY listed_in
ORDER BY count DESC
LIMIT 15;

-- 5.2 Genre distribution by content type
SELECT 
    type,
    listed_in AS genre,
    COUNT(*) AS count
FROM netflix_data
WHERE listed_in IS NOT NULL
GROUP BY type, listed_in
ORDER BY type, count DESC
LIMIT 20;

-- ============================================================================
-- SECTION 6: RATING ANALYSIS
-- ============================================================================

-- 6.1 Content distribution by rating
SELECT 
    rating,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_data), 2) AS percentage
FROM netflix_data
GROUP BY rating
ORDER BY count DESC;

-- 6.2 Most common rating for movies
SELECT 
    rating,
    COUNT(*) AS count
FROM netflix_data
WHERE type = 'Movie'
GROUP BY rating
ORDER BY count DESC
LIMIT 5;

-- 6.3 Most common rating for TV shows
SELECT 
    rating,
    COUNT(*) AS count
FROM netflix_data
WHERE type = 'TV Show'
GROUP BY rating
ORDER BY count DESC
LIMIT 5;

-- 6.4 Rating trends over years
SELECT 
    year_added,
    rating,
    COUNT(*) AS count
FROM netflix_data
WHERE year_added IS NOT NULL AND year_added >= 2015
GROUP BY year_added, rating
ORDER BY year_added DESC, count DESC;

-- ============================================================================
-- SECTION 7: DIRECTOR ANALYSIS
-- ============================================================================

-- 7.1 Top 10 directors with most content
SELECT 
    director,
    COUNT(*) AS content_count
FROM netflix_data
WHERE director != 'Unknown' AND director IS NOT NULL
GROUP BY director
ORDER BY content_count DESC
LIMIT 10;

-- 7.2 Directors with most movies
SELECT 
    director,
    COUNT(*) AS movie_count
FROM netflix_data
WHERE type = 'Movie' AND director != 'Unknown'
GROUP BY director
ORDER BY movie_count DESC
LIMIT 10;

-- 7.3 Directors with most TV shows
SELECT 
    director,
    COUNT(*) AS tv_show_count
FROM netflix_data
WHERE type = 'TV Show' AND director != 'Unknown'
GROUP BY director
ORDER BY tv_show_count DESC
LIMIT 10;

-- ============================================================================
-- SECTION 8: ADVANCED BUSINESS QUERIES
-- ============================================================================

-- 8.1 Content growth rate by year (percentage increase)
WITH yearly_counts AS (
    SELECT 
        year_added,
        COUNT(*) AS count
    FROM netflix_data
    WHERE year_added IS NOT NULL
    GROUP BY year_added
)
SELECT 
    year_added,
    count,
    LAG(count) OVER (ORDER BY year_added) AS prev_year,
    ROUND((count - LAG(count) OVER (ORDER BY year_added)) * 100.0 / 
          LAG(count) OVER (ORDER BY year_added), 2) AS growth_rate_percent
FROM yearly_counts
ORDER BY year_added;

-- 8.2 Top 5 countries by content type
SELECT 
    country,
    SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS movies,
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS tv_shows,
    COUNT(*) AS total
FROM netflix_data
WHERE country != 'Unknown'
GROUP BY country
ORDER BY total DESC
LIMIT 5;

-- 8.3 Most productive years for content release
SELECT 
    release_year,
    COUNT(*) AS content_released,
    SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS movies,
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS tv_shows
FROM netflix_data
WHERE release_year IS NOT NULL
GROUP BY release_year
ORDER BY content_released DESC
LIMIT 10;

-- 8.4 Average time gap between release and Netflix addition
SELECT 
    type,
    ROUND(AVG(year_added - release_year), 2) AS avg_years_gap,
    MIN(year_added - release_year) AS min_gap,
    MAX(year_added - release_year) AS max_gap
FROM netflix_data
WHERE year_added IS NOT NULL 
  AND release_year IS NOT NULL
  AND year_added >= release_year
GROUP BY type;

-- 8.5 Content diversity by country (number of unique ratings)
SELECT 
    country,
    COUNT(DISTINCT rating) AS unique_ratings,
    COUNT(*) AS total_content
FROM netflix_data
WHERE country != 'Unknown' AND rating != 'Not Rated'
GROUP BY country
HAVING COUNT(*) >= 50
ORDER BY unique_ratings DESC
LIMIT 10;

-- 8.6 Most recent additions by type
SELECT 
    type,
    title,
    date_added,
    release_year,
    rating,
    country
FROM netflix_data
WHERE date_added IS NOT NULL
ORDER BY date_added DESC
LIMIT 20;

-- 8.7 Oldest content still on Netflix
SELECT 
    title,
    type,
    release_year,
    country,
    rating,
    date_added
FROM netflix_data
WHERE release_year IS NOT NULL
ORDER BY release_year ASC
LIMIT 20;

-- 8.8 Content concentration analysis (top producers vs others)
WITH country_counts AS (
    SELECT 
        country,
        COUNT(*) AS count
    FROM netflix_data
    WHERE country != 'Unknown'
    GROUP BY country
)
SELECT 
    CASE 
        WHEN count >= 100 THEN 'Top Producers (100+)'
        WHEN count >= 50 THEN 'Major Producers (50-99)'
        WHEN count >= 20 THEN 'Mid-tier Producers (20-49)'
        ELSE 'Small Producers (<20)'
    END AS producer_category,
    COUNT(*) AS number_of_countries,
    SUM(count) AS total_content
FROM country_counts
GROUP BY producer_category
ORDER BY total_content DESC;

-- ============================================================================
-- SECTION 9: EXPORT QUERIES FOR POWER BI
-- ============================================================================

-- 9.1 Summary data for Power BI dashboard
SELECT 
    type,
    country,
    rating,
    year_added,
    month_added,
    release_year,
    listed_in AS genre,
    director,
    COUNT(*) AS count
FROM netflix_data
WHERE year_added IS NOT NULL
GROUP BY type, country, rating, year_added, month_added, release_year, listed_in, director;

-- 9.2 Time series data for trend analysis
SELECT 
    year_added,
    month_added,
    type,
    COUNT(*) AS content_count
FROM netflix_data
WHERE year_added IS NOT NULL
GROUP BY year_added, month_added, type
ORDER BY year_added, month_added;

-- 9.3 Geographic distribution for map visualization
SELECT 
    country,
    COUNT(*) AS total_content,
    SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS movies,
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS tv_shows
FROM netflix_data
WHERE country != 'Unknown'
GROUP BY country;

-- ============================================================================
-- END OF SQL QUERIES
-- ============================================================================

-- NOTES FOR EXECUTION:
-- 1. Create database: CREATE DATABASE netflix_analysis;
-- 2. Import netflix_cleaned.csv into netflix_data table
-- 3. Run queries in sections for organized analysis
-- 4. Export results to CSV for Power BI integration
-- 5. Adjust queries based on your SQL dialect (SQLite/MySQL/PostgreSQL)