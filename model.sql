-- reset

DROP TRIGGER IF EXISTS main_after_insert_trigger;
DROP TRIGGER IF EXISTS main_update_insert_trigger;
DROP TABLE IF EXISTS main_array;
DROP TABLE IF EXISTS main;

-- create - main table with JSON array (data) 

CREATE TABLE IF NOT EXISTS main (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  data JSON
);

-- helper child table used to index JSON array
-- deletes are handled by CASCADE

CREATE TABLE IF NOT EXISTS main_array (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  main_id BIGINT NOT NULL,
  value BIGINT,

  INDEX (main_id),
  FOREIGN KEY (main_id)
    REFERENCES main(id)
    ON DELETE CASCADE, 

  KEY (value, main_id, id)
);

DELIMITER //

-- after insert into main, extract the array values into the helper child
-- table

CREATE TRIGGER main_after_insert_trigger AFTER INSERT ON main
FOR EACH ROW
BEGIN
  DECLARE numavals INT;
  DECLARE i INT DEFAULT 0;
    
  SELECT JSON_LENGTH(NEW.data) INTO numavals;
  
  WHILE i < numavals DO
    INSERT INTO main_array (main_id, value) VALUES (NEW.id, JSON_EXTRACT(NEW.data, CONCAT('$[',i,']')));
    SELECT i + 1 INTO i;
  END WHILE;
END//

-- after update of main, remove helper child rows and re-extract
-- (this could be made better using partial updates,inserts and deletes)

CREATE TRIGGER main_after_update_trigger AFTER UPDATE ON main
FOR EACH ROW
BEGIN
  DECLARE numavals INT;
  DECLARE i INT DEFAULT 0;

  DELETE from main_array WHERE main_array.main_id = NEW.id;
    
  SELECT JSON_LENGTH(NEW.data) INTO numavals;
  
  WHILE i < numavals DO
    INSERT INTO main_array (main_id, value) VALUES (NEW.id, JSON_EXTRACT(NEW.data, CONCAT('$[',i,']')));
    SELECT i + 1 INTO i;
  END WHILE;
END//

DELIMITER ;

