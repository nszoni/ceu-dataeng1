USE imdb;

-- Analytical Queries

-- Q: How many movies are in each genre? What is the distribution?

WITH sub1 AS (
    SELECT
        movie_name,
        genre,
        count(*) AS n FROM merged_imdb GROUP BY movie_name, genre
)

SELECT
    genre,
    count(*) AS n FROM sub1
GROUP BY genre
ORDER BY n DESC;

-- A: Thrillers and Dramas are the most dominant

-- Q: What was the most successful year in movie production?

WITH sub2 AS (
    SELECT
        movie_name,
        movie_year,
        count(*) AS n FROM merged_imdb GROUP BY movie_name, movie_year
)

SELECT
    movie_year,
    count(*) AS n FROM sub2
GROUP BY movie_year
ORDER BY n DESC;

-- A: 1999 was the best year for filming!

-- Q: Which actor/actress has appeared in the most roles?

SELECT
    actor_name,
    count(*) AS n FROM merged_imdb GROUP BY actor_name ORDER BY n DESC;

-- A: Jim Cummings (probably because of multiple voices in animated series)

-- Q: In which genre of movies we have the highest likelihood of seeing an actor/actress?

SELECT
    actor_name,
    genre,
    count(*) AS n FROM merged_imdb GROUP BY actor_name, genre ORDER BY actor_name;

-- Q: What is the average rating of movies directed by Quentin Tarantino?
WITH tarantino AS (
    SELECT avg(rating) AS subavg
    FROM merged_imdb
    WHERE director_name = 'Quentin Tarantino'
    GROUP BY director_name
)

SELECT subavg FROM tarantino;

-- A: His average rating was 8.4

-- Q: Do we see a gender equity in terms of appearance in movies?

SELECT
    actor_sex,
    count(*) AS role_count
FROM merged_imdb
GROUP BY actor_sex;

-- A: Still much unbalanced as there are more than 3 times more male appearances!

-- Q: List the directors who also include themselves in movies!

SELECT
    movie_name,
    actor_name,
    director_name
FROM merged_imdb WHERE actor_name = director_name
GROUP BY movie_name, actor_name, director_name

