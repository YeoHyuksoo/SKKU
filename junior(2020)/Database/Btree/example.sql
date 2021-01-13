/* Make a table */
DROP TABLE TEST;
CREATE TABLE TEST (a INT, b INT) ;

DELIMITER $$

DROP PROCEDURE IF EXISTS loopInsert $$

CREATE PROCEDURE loopInsert()
BEGIN
	DECLARE i INT DEFAULT 1;
	WHILE i <= 20000000 DO
		INSERT INTO TEST (a, b) VALUES (i, i);
		SET i = i + 1;
	END WHILE;
	COMMIT;
END$$

DELIMITER ;

SET autocommit=0;
CALL loopInsert;
COMMIT;
SET autocommit=1;

/* Make a index */
ALTER TABLE TEST ADD INDEX(a);

/* Compare the running time between index scan and full table scan at selectivity 50% */
SELECT SUM(a)
FROM TEST
WHERE a > 10000000;

SELECT SUM(b)
FROM TEST
WHERE b > 10000000;
