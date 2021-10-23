use imdb;

-- Inserts violating data integrity

-- Ratings stored procedure which is called by insert and update triggers

drop procedure if exists ratingoutofbounds;

delimiter $$
CREATE PROCEDURE RatingOutOfBounds()
BEGIN
   	if (rating < 1) OR (rating > 5) then
	signal sqlstate '42000'
    set message_text = 'The rating of the movie is out of bounds, pls check it!';
	end if;
end;
end$$
DELIMITER ;

-- Years stored procedure which is called by insert and update triggers

drop procedure if exists yearinfuture

delimiter $$
CREATE PROCEDURE YearInFuture()
BEGIN
	if ((year > year(curdate())) or (year < 0)) then
	signal sqlstate '42000'
    set message_text = 'The year of the movie is either in the future or negative, pls check it!';
	end if;
end;
end$$
DELIMITER ;

-- triggers for checking ratings out of interval

drop trigger if exists before_movie_insert_movieRating;

delimiter $$
create trigger before_movie_insert_movieRating before insert on movies
for each row
begin
    call RatingOutOfBounds();
end$$
DELIMITER ;

drop trigger if exists before_movie_update_movieRating;

delimiter $$
create trigger before_movie_update_movieRating before update on movies
for each row
begin
    call RatingOutOfBounds();
end$$
DELIMITER ;

-- trigger for checking years in the future

drop trigger before_movie_insert_movieYear;

delimiter $$
create trigger before_movie_insert_movieYear before insert on movies
for each row
begin
    call YearInFuture();
end$$
DELIMITER ;

drop trigger if exists before_movie_update_movieYear;

delimiter $$
create trigger before_movie_update_movieYear before update on movies
for each row
begin
    call YearInFuture();
end$$
DELIMITER ;

-- CDC table for updates and inserts on the movies table

drop table if exists movies_audit_log;

create table movies_audit_log (
    id BIGINT not null,
    old_row_data JSON,
    new_row_data JSON,
    dml_type ENUM('INSERT', 'UPDATE', 'DELETE') not null,
    dml_timestamp timestamp not null,
    dml_created_by VARCHAR(255) not null,
    primary key (id, dml_type, dml_timestamp)
);

-- trigger for INSERTS

drop trigger if exists movies_insert_audit_trigger;

delimiter $$
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

delimiter $$
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

delimiter $$
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
-- rerun the Transformation as a trigger (materialized view in MySQL)

drop trigger if exists refresh_normalization_on_movies_dml;

DELIMITER $$
CREATE TRIGGER refresh_normalization_on_movies_dml
    AFTER INSERT ON movies_audit_log FOR EACH ROW
BEGIN
    call DenormalizeImdb();
END$$
DELIMITER ;
 */
