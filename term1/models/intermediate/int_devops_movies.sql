USE imdb;

-- Inserts violating data integrity

-- triggers for checking ratings out of interval

drop trigger if exists before_movie_insert_movieRating;

DELIMITER $$
create trigger before_movie_insert_movieRating before insert on movies
for each row
begin
    if ((new.rating < 1) OR (new.rating > 10)) then
	signal sqlstate '42000'
    set message_text = 'The rating of the movie is out of bounds, pls check it!';
	end if;
end$$
DELIMITER ;

drop trigger if exists before_movie_update_movieRating;

DELIMITER $$
create trigger before_movie_update_movieRating before update on movies
for each row
begin
    if ((new.rating < 1) OR (new.rating > 10)) then
	signal sqlstate '42000'
    set message_text = 'The rating of the movie is out of bounds, pls check it!';
	end if;
end$$
DELIMITER ;

/*
-- Run this to demo rating testing

INSERT INTO movies (
    id,
    name,
    year,
    rating
)
VALUES (
    '444',
    'David Lynch',
    '2000',
    '12.0' #10+ rating
);
 */

-- trigger for checking years in the future

drop trigger if exists before_movie_insert_movieYear;

DELIMITER $$
create trigger before_movie_insert_movieYear before insert on movies
for each row
begin
    if ((new.year > year(curdate())) or (new.year < 0)) then
	signal sqlstate '42000'
    set message_text = 'The year of the movie is either in the future or negative, pls check it!';
	end if;
end$$
DELIMITER ;

drop trigger if exists before_movie_update_movieYear;

DELIMITER $$
create trigger before_movie_update_movieYear before update on movies
for each row
begin
    if ((new.year > year(curdate())) or (new.year < 0)) then
	signal sqlstate '42000'
    set message_text = 'The year of the movie is either in the future or negative, pls check it!';
	end if;
end$$
DELIMITER ;

/*
-- Run this to demo year testing

INSERT INTO movies (
    id,
    name,
    year,
    rating
)
VALUES (
    '444',
    'David Lynch',
    '2200', #future year
    '9.0'
);
 */

-- CDC table for updates and inserts on the movies table

DROP TABLE IF EXISTS movies_audit_log;

CREATE TABLE movies_audit_log (
    id BIGINT NOT NULL,
    old_row_data JSON,
    new_row_data JSON,
    dml_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    dml_timestamp TIMESTAMP NOT NULL,
    dml_created_by VARCHAR(255) NOT NULL,
    PRIMARY KEY (id, dml_type, dml_timestamp)
);

-- trigger for INSERTS

drop trigger if exists movies_insert_audit_trigger;

DELIMITER $$
CREATE TRIGGER movies_insert_audit_trigger
AFTER INSERT ON movies FOR EACH ROW
BEGIN
    INSERT INTO movies_audit_log (
        id,
        old_row_data,
        new_row_data,
        dml_type,
        dml_timestamp,
        dml_created_by
    )
    VALUES(
        NEW.id,
        null,
        JSON_OBJECT(
            "name", NEW.name,
            "year", NEW.year,
            "rating", NEW.rating
        ),
        'INSERT',
        CURRENT_TIMESTAMP,
        CURRENT_USER()
    );
end$$
DELIMITER ;

-- trigger for UPDATEs

drop trigger if exists movies_update_audit_trigger;

DELIMITER $$
CREATE TRIGGER movies_update_audit_trigger
AFTER UPDATE ON movies FOR EACH ROW
BEGIN
    INSERT INTO movies_audit_log (
        id,
        old_row_data,
        new_row_data,
        dml_type,
        dml_timestamp,
        dml_created_by
    )
    VALUES(
        NEW.id,
        JSON_OBJECT(
            "name", OLD.name,
            "year", OLD.year,
            "rating", OLD.rating
        ),
        JSON_OBJECT(
            "name", NEW.name,
            "year", NEW.year,
            "rating", NEW.rating
        ),
        'UPDATE',
        CURRENT_TIMESTAMP,
        CURRENT_USER()
    );
end$$
DELIMITER ;

-- trigger for DELETEs

drop trigger if exists movies_delete_audit_trigger;

DELIMITER $$
CREATE TRIGGER movies_delete_audit_trigger
AFTER DELETE ON movies FOR EACH ROW
BEGIN
    INSERT INTO movies_audit_log (
        id,
        old_row_data,
        new_row_data,
        dml_type,
        dml_timestamp,
        dml_created_by
    )
    VALUES(
        OLD.id,
        JSON_OBJECT(
            "name", OLD.name,
            "year", OLD.year,
            "rating", OLD.rating
        ),
        null,
        'DELETE',
        CURRENT_TIMESTAMP,
        CURRENT_USER()
    );
end$$
DELIMITER ;

/*
-- Run this to demo see CDC at work

INSERT INTO movies (
    id,
    name,
    year,
    rating
)
VALUES (
    '888',
    'David Lynch',
    '2000',
    '8.0',
);
 */

