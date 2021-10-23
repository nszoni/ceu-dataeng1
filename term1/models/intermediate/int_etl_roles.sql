use imdb;

-- on this table we have no numercal-like values to validate with testing

-- CDC table for updates and inserts on the roles table

drop table if exists roles_audit_log;

create table roles_audit_log (
    actorid BIGINT not null,
    movieid BIGINT not null,
    old_row_data VARCHAR(100),
    new_row_data VARCHAR(100),
    dml_type ENUM('INSERT', 'UPDATE', 'DELETE') not null,
    dml_timestamp timestamp not null,
    dml_created_by VARCHAR(255) not null,
    primary key (actorid, movieid, dml_type, dml_timestamp)
);

-- trigger for INSERTS

drop trigger if exists roles_insert_audit_trigger;

delimiter $$
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

delimiter $$
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

delimiter $$
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
-- rerun the Transformation as a trigger (materialized view in MySQL)

drop trigger if exists refresh_normalization_on_roles_dml;

DELIMITER $$
CREATE TRIGGER refresh_normalization_on_roles_dml
    AFTER INSERT ON roles_audit_log FOR EACH ROW
BEGIN
    call DenormalizeImdb();
END$$
DELIMITER ;
 */
