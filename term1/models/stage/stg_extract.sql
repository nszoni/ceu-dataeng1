-- If you want to save some time for yourself, use the `stg_bulk_extract.sh`!!

-- SHOW VARIABLES LIKE "local_infile";
SET GLOBAL local_infile = 1;

USE imdb;

-- mysql does not let us truncate a table which has reference, thus we have to turn off the check for the time being.

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE actors;
TRUNCATE TABLE directors;
TRUNCATE TABLE directors_genres;
TRUNCATE TABLE movies;
TRUNCATE TABLE movies_genres;
TRUNCATE TABLE movies_directors;
TRUNCATE TABLE roles;

SET FOREIGN_KEY_CHECKS = 1;

-- Load actors.tsv into actors table
LOAD DATA LOCAL INFILE '/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/actors.tsv'
INTO TABLE actors
COLUMNS TERMINATED BY '\t'
IGNORE 1 LINES;

-- Load directors.tsv into directors table
LOAD DATA LOCAL INFILE '/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/directors.tsv'
INTO TABLE directors
COLUMNS TERMINATED BY '\t'
IGNORE 1 LINES;

-- Load directors_genres.tsv into directors_genres table
LOAD DATA LOCAL INFILE '/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/directors_genres.tsv'
INTO TABLE directors_genres
COLUMNS TERMINATED BY '\t'
IGNORE 1 LINES;

-- Load movies.tsv into movies table
LOAD DATA LOCAL INFILE '/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/movies.tsv'
INTO TABLE movies
COLUMNS TERMINATED BY '\t'
IGNORE 1 LINES;

-- Load movies_directors.tsv into movies_directors table
LOAD DATA LOCAL INFILE '/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/movies_directors.tsv'
INTO TABLE movies_directors
COLUMNS TERMINATED BY '\t'
IGNORE 1 LINES;

-- Load movies_genres.tsv into movies_genres table
LOAD DATA LOCAL INFILE '/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/movies_genres.tsv'
INTO TABLE movies_genres
COLUMNS TERMINATED BY '\t'
IGNORE 1 LINES;

-- Load roles.tsv into roles table
LOAD DATA LOCAL INFILE '/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/roles.tsv'
INTO TABLE roles
COLUMNS TERMINATED BY '\t'
IGNORE 1 LINES;
