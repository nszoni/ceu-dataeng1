-- SHOW VARIABLES LIKE "local_infile";
SET GLOBAL local_infile = 1;

use imdb;

-- mysql does not let us truncate a table which has reference, thus we have to turn off the check for the time being.

set FOREIGN_KEY_CHECKS = 0;

truncate table actors;
truncate table directors;
truncate table directors_genres;
truncate table movies;
truncate table movies_genres;
truncate table movies_directors;
truncate table roles;

set FOREIGN_KEY_CHECKS = 1;

-- Load actors.tsv into actors table
LOAD DATA LOCAL INFILE '/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/imdb_small_actors.tsv'
INTO TABLE actors
COLUMNS TERMINATED BY '\t'
IGNORE 1 LINES;

-- Load directors.tsv into directors table
LOAD DATA LOCAL INFILE '/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/imdb_small_directors.tsv'
INTO TABLE directors
COLUMNS TERMINATED BY '\t'
IGNORE 1 LINES;

-- Load directors_genres.tsv into directors_genres table
LOAD DATA LOCAL INFILE '/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/imdb_small_directors_genres.tsv'
INTO TABLE directors_genres
COLUMNS TERMINATED BY '\t'
IGNORE 1 LINES;

-- Load movies.tsv into movies table
LOAD DATA LOCAL INFILE '/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/imdb_small_movies.tsv'
INTO TABLE movies
COLUMNS TERMINATED BY '\t'
IGNORE 1 LINES;

-- Load movies_directors.tsv into movies_directors table
LOAD DATA LOCAL INFILE '/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/imdb_small_movies_directors.tsv'
INTO TABLE movies_directors
COLUMNS TERMINATED BY '\t'
IGNORE 1 LINES;

-- Load movies_genres.tsv into movies_genres table
LOAD DATA LOCAL INFILE '/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/imdb_small_movies_genres.tsv'
INTO TABLE movies_genres
COLUMNS TERMINATED BY '\t'
IGNORE 1 LINES;

-- Load roles.tsv into roles table
LOAD DATA LOCAL INFILE '/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/imdb_small_roles.tsv'
INTO TABLE roles
COLUMNS TERMINATED BY '\t'
IGNORE 1 LINES;
