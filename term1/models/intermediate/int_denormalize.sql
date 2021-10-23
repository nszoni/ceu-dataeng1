use imdb;

-- Let's transform our data and load into a new table

-- Ad-hoc transformations

-- rank is a reserved keywork in mysql
alter table movies
RENAME column `rank` TO rating;

-- to avoid ambugity
alter table actors
RENAME column gender TO sex;

-- update values which are suspicious
update `roles` set `role` = "unknown" where role = '""';
update `movies` set `rating` = 8.2 where `name` = 'Batman Begins';

-- Denormalizig the SF schema

drop procedure if exists denormalizeimdb;

delimiter //

CREATE PROCEDURE DenormalizeImdb()
BEGIN

    DROP TABLE IF EXISTS merged_imdb;

create table merged_imdb as
select
    movies.id as movieid,
    actor_id as actorid,
    name as name,
    year as year,
    movies_genres.genre as genre,
    sex as actor_sex,
    role as actor_role,
    round(rating, 2) as rating,
    rtrim(ltrim(
            concat_ws(' ',
                coalesce(actors.first_name, ''), -- concat the actor names for clarity
                coalesce(actors.last_name, '')
            ))) as actor_name,
    rtrim(ltrim(
            concat_ws(' ',
                coalesce(directors.first_name, ''), -- concat the director names for clarity
                coalesce(directors.last_name, '')
            ))) as director_name
from
    movies
inner join
    movies_directors on movies.id = movies_directors.movie_id
inner join
    movies_genres on movies.id = movies_genres.movie_id
inner join
    roles on movies.id = roles.movie_id
inner join
    directors on movies_directors.director_id = directors.id
inner join
    actors on roles.actor_id = actors.id;

end //
DELIMITER ;

call denormalizeimdb();
