/*
IMDB reduced size dataset: https://relational.fit.cvut.cz/dataset/IMDb
Dataset was stored on a MariaDB server from which I extracted the data as TSV files
*/

-- create database imdb;

USE imdb;

-- drop existing tables

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS actors;
DROP TABLE IF EXISTS directors;
DROP TABLE IF EXISTS directors_genres;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS movies_directors;
DROP TABLE IF EXISTS movies_genres;
DROP TABLE IF EXISTS roles;

SET FOREIGN_KEY_CHECKS = 1;

-- Below DDL was retrieved from the source MariaDB database with the built-in DataGrip DDL generator

CREATE TABLE actors
(
    id int DEFAULT 0 NOT NULL
    PRIMARY KEY,
    first_name varchar(100) NULL,
    last_name varchar(100) NULL,
    sex char NULL,
    film_count int DEFAULT 0 NULL
);

CREATE TABLE directors
(
    id int DEFAULT 0 NOT NULL
    PRIMARY KEY,
    first_name varchar(100) NULL,
    last_name varchar(100) NULL
);

create table directors_genres
(
    director_id int null,
    genre varchar(100) null,
    prob float null,
    constraint directors_genres_ibfk_1
        foreign key (director_id) references directors (id)
            on update cascade on delete cascade
);

CREATE TABLE movies
(
    `id` int DEFAULT 0 NOT NULL
    PRIMARY KEY,
    `name` varchar(100) NULL,
    `year` int NULL,
    `rating` float NULL
);

create table movies_directors
(
    director_id int not null,
    movie_id int not null,
    primary key (director_id, movie_id),
    constraint movies_directors_ibfk_1
        foreign key (movie_id) references movies (id)
            on update cascade on delete cascade,
    constraint movies_directors_ibfk_2
        foreign key (director_id) references directors (id)
            on update cascade on delete cascade
);

create table movies_genres
(
    movie_id int not null,
    genre varchar(100) not null,
    primary key (movie_id, genre),
    constraint movies_genres_ibfk_1
        foreign key (movie_id) references movies (id)
            on update cascade on delete cascade
);

create table roles
(
    actor_id int not null,
    movie_id int not null,
    role varchar(100) not null,
    primary key (actor_id, movie_id, role),
    constraint roles_ibfk_1
        foreign key (movie_id) references movies (id)
            on update cascade on delete cascade,
    constraint roles_ibfk_2
        foreign key (actor_id) references actors (id)
            on update cascade on delete cascade
);

/*
Creating index for id of tables.
It is unrealistic at this point but makes the queries more performant when data starts to grow.
*/

CREATE INDEX idx_director_id
ON directors_genres (director_id);

CREATE INDEX idx_director_id
ON movies_directors (director_id);

CREATE INDEX idx_movie_id
ON movies_directors (movie_id);

CREATE INDEX movie_id
ON movies_genres (movie_id);

CREATE INDEX idx_actor_id
ON roles (actor_id);

CREATE INDEX idx_movie_id
ON roles (movie_id);
