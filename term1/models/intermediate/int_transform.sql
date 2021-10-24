USE imdb;

-- Let's transform our data and load into a new table

-- update values which are suspicious
UPDATE roles SET role = 'unknown' WHERE role = '""';
UPDATE movies SET rating = 8.2 WHERE name = ('Batman Begins');
UPDATE movies SET rating = 8.0 WHERE name = ('Pirates of the Caribbean');

-- Denormalizing the SF schema

DROP PROCEDURE IF EXISTS denormalizeimdb;

DELIMITER //

CREATE PROCEDURE DenormalizeImdb()
BEGIN

    DROP TABLE IF EXISTS merged_imdb;

CREATE TABLE merged_imdb AS
SELECT
    movies.id AS movieid,
    actors.id AS actorid,
    movies.name AS movie_name,
    movies.year AS movie_year,
    movies_genres.genre AS genre,
    actors.sex AS actor_sex,
    roles.role AS actor_role,
    round(rating, 2) AS rating,
    rtrim(ltrim(
            concat_ws(' ',
                coalesce(actors.first_name, ''), -- concat the actor names for clarity
                coalesce(actors.last_name, '')
            ))) AS actor_name,
    rtrim(ltrim(
            concat_ws(' ',
                coalesce(directors.first_name, ''), -- concat the director names for clarity
                coalesce(directors.last_name, '')
            ))) AS director_name
FROM
    movies
INNER JOIN
    movies_directors ON movies.id = movies_directors.movie_id
INNER JOIN
    movies_genres ON movies.id = movies_genres.movie_id
INNER JOIN
    roles ON movies.id = roles.movie_id
INNER JOIN
    directors ON movies_directors.director_id = directors.id
INNER JOIN
    actors ON roles.actor_id = actors.id;

END //
DELIMITER ;

CALL denormalizeimdb();
