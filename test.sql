
-- setup

INSERT INTO main (data) VALUES ('[1,2,3,4,5]');
INSERT INTO main (data) VALUES ('[4,5,6,7,8]');
INSERT INTO main (data) VALUES ('[7,8,9,10,11]');
INSERT INTO main (data) VALUES ('[10,11,12,13,14]');

-- point query

SELECT 'point query should return rows with arrays with the value 5';

SELECT * FROM main WHERE id IN (
  SELECT DISTINCT main_id FROM main_array WHERE value = 5
);

-- range query

SELECT 'range query should return rows with arrays containing values greater than 8 and less than 11'; 

SELECT * FROM main WHERE id IN (
  SELECT DISTINCT main_id FROM main_array WHERE value > 8 AND value < 11
);

-- update (is a pain because JSON functions don't work well with numeric
-- arrays)

SELECT 'modifing arrays to remove the value 5';

START TRANSACTION;

CREATE TEMPORARY TABLE new_json
  SELECT main_id, CONCAT('[',GROUP_CONCAT(value),']') AS new_values
           FROM main_array ma1
           WHERE ma1.value <> 5
           AND ma1.main_id IN (SELECT DISTINCT ma2.main_id FROM main_array ma2 WHERE ma2.value = 5)
           GROUP BY main_id;

SELECT @update_main_ids := GROUP_CONCAT(main_id) FROM main_array WHERE value = 5 GROUP BY main_id;

UPDATE main m,
       new_json
SET m.data = new_json.new_values
WHERE m.id = new_json.main_id;

COMMIT;

SELECT 'all data after removing value 5';

SELECT * from main;

-- point query after removing 5

SELECT 'after update point query should return nothing when searching for 5';

SELECT * FROM main WHERE id IN (
  SELECT DISTINCT main_id FROM main_array WHERE value = 5
);

-- teardown

SELECT 'both tables should have 0 records';

DELETE FROM main;
SELECT COUNT(*) FROM main;
SELECT COUNT(*) FROM main_array;

