use imdb;

-- Analytical Queries



with sub1 as(
        select
             name,
             genre,
             count(*) as n from merged_imdb group by name, genre) as a
),

sub2 as(
        select
             name,
             year,
             count(*) as n from merged_imdb group by name, year)
)

-- How many movies are in each genre? What is the distribution?

select
    genre,
    count(*) as n from sub
group by genre
order by n desc;

-- What was the most successful year in movie production?

select
    year,
    count(*) as n from sub2
group by year
order by n desc;

-- Which actor/actress has appeared in the most roles?

select
    actor_name,
    count(*) as n from merged_imdb group by actor_name order by n desc;

-- In which genre of movies we have the highest likelihood of seeing an actor/actress?

select count(*) from merged_imdb group by actor_name, genre order by actor_name;

-- What is the average rating of movies directed by Quentin Tarantino?

select avg(a.subavg) as avg_rating from (
select avg(rating) as subavg from merged_imdb where director_name = 'Quentin Tarantino' group by name) a

-- Do we see a gender equity in terms of appearance in movies?

select actor_sex, count(*) as role_count from merged_imdb group by actor_sex

-- List the directors who also include themselves in movies!

select name, actor_name, director_name from merged_imdb where actor_name = director_name group by name, actor_name, director_name

