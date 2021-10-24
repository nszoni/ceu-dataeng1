USE imdb;

-- Event based stored procedure to create the materialized view
-- Runs every day at 1AM

SET GLOBAL event_scheduler = ON;

drop event if exists materialized_imbd;

DELIMITER $$

CREATE EVENT materialized_imbd
  ON SCHEDULE
    EVERY 1 DAY
    STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY + INTERVAL 1 HOUR)
  DO
	BEGIN
    	CALL DenormalizeImdb();
    	CREATE INDEX index_movie_actor
        ON merged_imdb(movieid, actorid);
end;
END$$
DELIMITER ;


