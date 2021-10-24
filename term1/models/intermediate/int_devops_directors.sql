USE imdb;

-- on this table we have no numercal-like values to validate with testing

-- CDC table for updates and inserts on the directors table

DROP TABLE IF EXISTS directors_audit_log;

CREATE TABLE directors_audit_log (
    id BIGINT NOT NULL,
    old_row_data JSON,
    new_row_data JSON,
    dml_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    dml_timestamp TIMESTAMP NOT NULL,
    dml_created_by VARCHAR(255) NOT NULL,
    PRIMARY KEY (id, dml_type, dml_timestamp)
);

-- trigger for INSERTs

drop trigger if exists directors_insert_audit_trigger;

DELIMITER $$
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

DELIMITER $$
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

DELIMITER $$
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
-- Run this to demo see CDC at work

INSERT INTO movies (
    id,
    first_name,
    last_name
)
VALUES (
    '9999',
    'David',
    'Lynch'
);
 */
