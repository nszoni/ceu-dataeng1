USE imdb;

-- Data Integrity Checks

-- triggers for checking sex values out of set

drop trigger if exists before_actors_insert_sexInSet;

DELIMITER $$
create trigger before_actors_insert_sexInSet before insert on actors
for each row
begin
    if (new.sex not in ('F', 'M')) then
	signal sqlstate '42000'
    set message_text = 'The given sex is not feasible, pls check it!';
	end if;
end$$
DELIMITER ;

drop trigger if exists before_actors_update_sexInSet;

DELIMITER $$
create trigger before_actors_update_sexInSet before update on actors
for each row
begin
    if (new.sex not in ('F', 'M')) then
	signal sqlstate '42000'
    set message_text = 'The given sex is not feasible, pls check it!';
	end if;
end$$
DELIMITER ;

/*
-- Run this to demo sex testing

INSERT INTO actors (
    id,
    first_name,
    last_name,
    sex,
    film_count
)
VALUES (
    '444',
    'David',
    'Lynch',
    'N', #non-binary
    '2'
);
 */

-- triggers for checking negative film_count values

drop trigger if exists before_actors_insert_filmCountIsNegative;

DELIMITER $$
create trigger before_actors_insert_filmCountIsNegative before insert on actors
for each row
begin
    if (new.film_count < 0) then
	signal sqlstate '42000'
    set message_text = 'The number of films cannot be less than zero, pls check it!';
	end if;
end$$
DELIMITER ;

drop trigger if exists before_actors_update_filmCountIsNegative;

DELIMITER $$
create trigger before_actors_update_filmCountIsNegative before update on actors
for each row
begin
    if (new.film_count < 0) then
	signal sqlstate '42000'
    set message_text = 'The number of films cannot be less than zero, pls check it!';
	end if;
end$$
DELIMITER ;

/*
-- Run this to demo film_count testing

INSERT INTO actors (
    id,
    first_name,
    last_name,
    sex,
    film_count
)
VALUES (
    '4454',
    'David',
    'Lynch',
    'M',
    '-2' #negative film count
);
 */

-- CDC table for updates and inserts on the actors table

DROP TABLE IF EXISTS actors_audit_log;

CREATE TABLE actors_audit_log (
    id BIGINT NOT NULL,
    old_row_data JSON,
    new_row_data JSON,
    dml_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    dml_timestamp TIMESTAMP NOT NULL,
    dml_created_by VARCHAR(255) NOT NULL,
    PRIMARY KEY (id, dml_type, dml_timestamp)
);

-- trigger for INSERTs

drop trigger if exists actors_insert_audit_trigger;

DELIMITER $$
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

DELIMITER $$
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

DELIMITER $$
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
-- Run this to demo to see CDC at work

INSERT INTO actors (
    id,
    first_name,
    last_name,
    sex,
    film_count
)
VALUES (
    '7777',
    'David',
    'Lynch',
    'M',
    '33'
);
 */
