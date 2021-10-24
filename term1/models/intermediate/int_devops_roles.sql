USE imdb;

-- on this table we have no numerical-like values to validate with testing

-- CDC table for updates and inserts on the roles table

DROP TABLE IF EXISTS roles_audit_log;

CREATE TABLE roles_audit_log (
    actorid BIGINT NOT NULL,
    movieid BIGINT NOT NULL,
    old_row_data VARCHAR(100),
    new_row_data VARCHAR(100),
    dml_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    dml_timestamp TIMESTAMP NOT NULL,
    dml_created_by VARCHAR(255) NOT NULL,
    PRIMARY KEY (actorid, movieid, dml_type, dml_timestamp)
);

-- trigger for INSERTS

drop trigger if exists roles_insert_audit_trigger;

DELIMITER $$
CREATE TRIGGER roles_insert_audit_trigger
AFTER INSERT ON roles FOR EACH ROW
BEGIN
    INSERT INTO roles_audit_log (
        actorid,
        movieid,
        old_row_data,
        new_row_data,
        dml_type,
        dml_timestamp,
        dml_created_by
    )
    VALUES(
        NEW.actor_id,
        NEW.movie_id,
        null,
        NEW.role,
        'INSERT',
        CURRENT_TIMESTAMP,
        CURRENT_USER()
    );
end$$
DELIMITER ;

-- trigger for UPDATEs

drop trigger if exists roles_update_audit_trigger;

DELIMITER $$
CREATE TRIGGER roles_update_audit_trigger
AFTER UPDATE ON roles FOR EACH ROW
BEGIN
    INSERT INTO roles_audit_log (
        actorid,
        movieid,
        old_row_data,
        new_row_data,
        dml_type,
        dml_timestamp,
        dml_created_by
    )
    VALUES(
        NEW.actor_id,
        NEW.movie_id,
        OLD.role,
        NEW.role,
        'UPDATE',
        CURRENT_TIMESTAMP,
        CURRENT_USER()
    );
end$$
DELIMITER ;

-- trigger for DELETEs

drop trigger if exists roles_delete_audit_trigger;

DELIMITER $$
CREATE TRIGGER roles_delete_audit_trigger
AFTER DELETE ON roles FOR EACH ROW
BEGIN
INSERT INTO roles_audit_log (
        actorid,
        movieid,
        old_row_data,
        new_row_data,
        dml_type,
        dml_timestamp,
        dml_created_by
    )
    VALUES(
        OLD.actor_id,
        OLD.movie_id,
        OLD.role,
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
    actor_id,
    movie_id,
    role
)
VALUES (
    '9999',
    '1000',
    'Ballboy'
);
 */
