use imdb;

-- Data Integrity Checks

-- whether sex is not in the given set

drop procedure if exists sexinset

delimiter $$
CREATE PROCEDURE SexInSet()
BEGIN
	if (sex not in ('F', 'M')) then
	signal sqlstate '42000'
    set message_text = 'The given sex is not feasible, pls check it!';
	end if;
end;
end$$
DELIMITER ;

-- whether the film count is negative

drop procedure if exists filmcountisnegative

delimiter $$
CREATE PROCEDURE FilmCountIsNegative()
BEGIN
	if (film_count < 0) then
	signal sqlstate '42000'
    set message_text = 'The number of films cannot be less than zero, pls check it!';
	end if;
end;
end$$
DELIMITER ;

-- triggers for checking sex values out of set

drop trigger if exists before_actors_insert_sexInSet;

delimiter $$
create trigger before_actors_insert_sexInSet before insert on actors
for each row
begin
    call SexInSet();
end$$
DELIMITER ;

drop trigger if exists before_actors_update_sexInSet;

delimiter $$
create trigger before_actors_update_sexInSet before update on actors
for each row
begin
    call SexInSet();
end$$
DELIMITER ;

-- triggers for checking negative film_count values

drop trigger if exists before_actors_insert_filmCountIsNegative;

delimiter $$
create trigger before_actors_insert_filmCountIsNegative before insert on actors
for each row
begin
    call FilmCountIsNegative();
end$$
DELIMITER ;

drop trigger if exists before_actors_update_filmCountIsNegative;

delimiter $$
create trigger before_actors_update_filmCountIsNegative before update on actors
for each row
begin
    call FilmCountIsNegative();
end$$
DELIMITER ;

-- CDC table for updates and inserts on the actors table

drop table if exists actors_audit_log;

create table actors_audit_log (
    id BIGINT not null,
    old_row_data JSON,
    new_row_data JSON,
    dml_type ENUM('INSERT', 'UPDATE', 'DELETE') not null,
    dml_timestamp timestamp not null,
    dml_created_by VARCHAR(255) not null,
    primary key (id, dml_type, dml_timestamp)
);

-- trigger for INSERTs

drop trigger if exists actors_insert_audit_trigger;

delimiter $$
CREATE TRIGGER actors_insert_audit_trigger
AFTER INSERT ON actors FOR EACH ROW
BEGIN
    INSERT INTO actors_audit_log (
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
            "first_name", NEW.first_name,
            "last_name", NEW.last_name,
            "sex", NEW.sex,
            "film_count", NEW.film_count
        ),
        'INSERT',
        CURRENT_TIMESTAMP,
        CURRENT_USER()
    );
end$$
DELIMITER ;

-- trigger for UPDATEs

drop trigger if exists actors_update_audit_trigger;

delimiter $$
CREATE TRIGGER actors_update_audit_trigger
AFTER UPDATE ON actors FOR EACH ROW
BEGIN
    INSERT INTO actors_audit_log (
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
            "first_name", OLD.first_name,
            "last_name", OLD.last_name,
            "sex", OLD.sex,
            "film_count", OLD.film_count
        ),
        JSON_OBJECT(
            "first_name", NEW.first_name,
            "last_name", NEW.last_name,
            "sex", NEW.sex,
            "film_count", NEW.film_count
        ),
        'UPDATE',
        CURRENT_TIMESTAMP,
        CURRENT_USER()
    );
end$$
DELIMITER ;

-- trigger for DELETEs

drop trigger if exists actors_delete_audit_trigger;

delimiter $$
CREATE TRIGGER actors_delete_audit_trigger
AFTER DELETE ON actors FOR EACH ROW
BEGIN
    INSERT INTO actors_audit_log (
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
            "first_name", OLD.first_name,
            "last_name", OLD.last_name,
            "sex", OLD.sex,
            "film_count", OLD.film_count
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

drop trigger if exists refresh_normalization_on_actors_dml;

DELIMITER $$
CREATE TRIGGER refresh_normalization_on_actors_dml
    AFTER INSERT ON actors_audit_log FOR EACH ROW
BEGIN
    call DenormalizeImdb();
END$$
DELIMITER ;
 */
