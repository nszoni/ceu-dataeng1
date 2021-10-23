use imdb;

-- Event based stored procedure to create the materialized view
-- Runs every day at 1AM

SET GLOBAL event_scheduler = ON;

delimiter $$

CREATE EVENT event_name
  ON SCHEDULE
    EVERY 1 DAY
    STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY + INTERVAL 1 HOUR)
  DO
	BEGIN
    	CALL DenormalizeImdb();
    	CREATE INDEX index_movie_actor
        ON merged_imdb(movieid, actorid);
END$$
DELIMITER ;


