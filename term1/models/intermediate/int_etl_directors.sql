use imdb;

-- on this table we have no numercal-like values to validate with testing

-- CDC table for updates and inserts on the directors table

drop table if exists directors_audit_log;

create table directors_audit_log (
    id BIGINT not null,
    old_row_data JSON,
    new_row_data JSON,
    dml_type ENUM('INSERT', 'UPDATE', 'DELETE') not null,
    dml_timestamp timestamp not null,
    dml_created_by VARCHAR(255) not null,
    primary key (id, dml_type, dml_timestamp)
);

-- trigger for INSERTs

drop trigger if exists directors_insert_audit_trigger;

delimiter $$
CREATE TRIGGER directors_insert_audit_trigger
AFTER INSERT ON directors FOR EACH ROW
BEGIN
    INSERT INTO directors_audit_log (
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
            "last_name", NEW.last_name
        ),
        'INSERT',
        CURRENT_TIMESTAMP,
        CURRENT_USER()
    );
end$$
DELIMITER ;

-- trigger for UPDATEs

drop trigger if exists directors_update_audit_trigger;

delimiter $$
CREATE TRIGGER directors_update_audit_trigger
AFTER UPDATE ON directors FOR EACH ROW
BEGIN
    INSERT INTO directors_audit_log (
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
            "last_name", OLD.last_name
        ),
        JSON_OBJECT(
            "first_name", NEW.first_name,
            "last_name", NEW.last_name
        ),
        'UPDATE',
        CURRENT_TIMESTAMP,
        CURRENT_USER()
    );
end$$
DELIMITER ;

-- trigger for DELETEs

drop trigger if exists directors_delete_audit_trigger;

delimiter $$
CREATE TRIGGER directors_delete_audit_trigger
AFTER DELETE ON directors FOR EACH ROW
BEGIN
    INSERT INTO directors_audit_log (
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
            "last_name", OLD.last_name
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

drop trigger if exists refresh_normalization_on_directors_dml;

DELIMITER $$
CREATE TRIGGER refresh_normalization_on_directors_dml
    AFTER INSERT ON directors_audit_log FOR EACH ROW
BEGIN
    call DenormalizeImdb();
END$$
DELIMITER ;
 */
