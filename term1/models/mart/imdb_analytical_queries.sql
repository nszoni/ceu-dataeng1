use imdb;

-- Analytical Queries

select
    a.genre,
    count(*) as n from (
        select
             name,
             genre,
             count(*) as n from merged_imdb group by name, genre) as a
group by genre
order by n desc;

select
    year,
    count(*) as n from (
        select
             name,
             year,
             count(*) as n from merged_imdb group by name, year)
group by year
order by n desc;

select
    actor_name,
    count(*) as n from merged_imdb group by actor_name order by n desc;

select count(*) from merged_imdb group by actor_name, genre order by actor_name;

select avg(a.subavg) as avg_rating from (
select avg(rating) as subavg from merged_imdb where director_name = 'Quentin Tarantino' group by name) a

select actor_sex, count(*) as role_count from merged_imdb group by actor_sex

select name, actor_name, director_name from merged_imdb where actor_name = director_name group by name, actor_name, director_name

