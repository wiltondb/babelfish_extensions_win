CREATE TABLE delete_test_tbl (
    age int,
    fname char(10),
    lname char(10),
    city nchar(20)
);
GO
INSERT INTO delete_test_tbl(age, fname, lname, city) 
VALUES  (50, 'fname1', 'lname1', 'london'),
        (34, 'fname2', 'lname2', 'paris'),
        (35, 'fname3', 'lname3', 'brussels'),
        (90, 'fname4', 'lname4', 'new york'),
        (26, 'fname5', 'lname5', 'los angeles'),
        (74, 'fname6', 'lname6', 'tokyo'),
        (44, 'fname7', 'lname7', 'oslo'),
        (19, 'fname8', 'lname8', 'hong kong'),
        (61, 'fname9', 'lname9', 'shanghai'),
        (29, 'fname10', 'lname10', 'mumbai');

SELECT * FROM delete_test_tbl ORDER BY age DESC, city ASC;
GO

-- Prove that a user may delete rows from a table without using the FROM clause
SELECT * FROM delete_test_tbl ORDER BY age DESC, city ASC;
GO

-- Test that that WHERE clause can be used without FROM
DELETE delete_test_tbl WHERE city='hong kong';
GO
SELECT * FROM delete_test_tbl ORDER BY age DESC, city ASC;
GO

DELETE delete_test_tbl WHERE age > 50;
GO
SELECT * FROM delete_test_tbl ORDER BY age DESC, city ASC;
GO

DELETE delete_test_tbl WHERE fname IN ('fname1', 'fname2');
GO
SELECT * FROM delete_test_tbl ORDER BY age DESC, city ASC;
GO

-- Test that DELETE works without any other clauses
DELETE delete_test_tbl;
GO
SELECT * FROM delete_test_tbl ORDER BY age DESC, city ASC;
GO

-- Test delete for joined table
CREATE TABLE delete_test_tbl2 (
    age int,
    fname char(10),
    lname char(10),
    city nchar(20)
);
GO

INSERT INTO delete_test_tbl2(age, fname, lname, city)
VALUES  (50, 'fname1', 'lname1', 'london'),
        (34, 'fname2', 'lname2', 'paris'),
        (50, 'fname3', 'lname3', 'brussels'),
        (90, 'fname4', 'lname4', 'new york'),
        (26, 'fname5', 'lname5', 'los angeles'),
        (74, 'fname6', 'lname6', 'tokyo'),
        (44, 'fname7', 'lname7', 'oslo'),
        (19, 'fname8', 'lname8', 'hong kong'),
        (61, 'fname9', 'lname9', 'shanghai'),
        (29, 'fname10', 'lname10', 'mumbai');
GO

CREATE TABLE delete_test_tbl3 (
    year int,
    lname char(10),
);
GO

INSERT INTO delete_test_tbl3(year, lname)
VALUES  (51, 'lname1'),
        (34, 'lname3'),
        (25, 'lname8'),
        (95, 'lname9'),
        (36, 'lname10');
GO

CREATE TABLE delete_test_tbl4 (
    lname char(10),
    city char(10),
);
GO

INSERT INTO delete_test_tbl4(lname, city)
VALUES  ('lname8','london'),
        ('lname9','tokyo'),
        ('lname10','mumbai');
GO

SELECT * FROM delete_test_tbl2 ORDER BY lname;
GO
SELECT * FROM delete_test_tbl3 ORDER BY lname;
GO
SELECT * FROM delete_test_tbl4 ORDER BY lname;
GO


DELETE delete_test_tbl2
FROM delete_test_tbl2 t2
INNER JOIN delete_test_tbl3 t3
ON t2.lname = t3.lname
WHERE year > 50;

SELECT * FROM delete_test_tbl2 ORDER BY lname;
GO

DELETE delete_test_tbl2
FROM delete_test_tbl3 t3
LEFT JOIN delete_test_tbl2 t2
ON t2.lname = t3.lname
WHERE t3.year < 30 AND t2.age > 40;

SELECT * FROM delete_test_tbl2 ORDER BY lname;
GO

-- delete with outer join on multiple tables
DELETE delete_test_tbl2
FROM delete_test_tbl4 t4
LEFT JOIN delete_test_tbl2 t2
ON t4.city = t2.city
LEFT JOIN delete_test_tbl3 t3
ON t2.lname = t3.lname
WHERE t4.city = 'mumbai';

SELECT * FROM delete_test_tbl2 ORDER BY lname;
GO

-- delete when target table not shown in JoinExpr
DELETE delete_test_tbl2
FROM delete_test_tbl4 t4
LEFT JOIN delete_test_tbl3 t3
ON t3.lname = t4.lname
WHERE t4.city = 'mumbai';

SELECT * FROM delete_test_tbl2 ORDER BY lname;
GO

-- delete with self join
DELETE delete_test_tbl3
FROM delete_test_tbl3 t1
INNER JOIN delete_test_tbl3 t2
on t1.lname = t2.lname;

SELECT * FROM delete_test_tbl3 ORDER BY lname;
GO

DELETE delete_test_tbl2
FROM delete_test_tbl2 c
JOIN
(SELECT lname, fname, age from delete_test_tbl2) b
on b.lname = c.lname
JOIN
(SELECT lname, city, age from delete_test_tbl2) a
on a.city = c.city;
SELECT * FROM delete_test_tbl2 ORDER BY lname;
GO

DELETE delete_test_tbl4
FROM
(SELECT lname, city from delete_test_tbl4) b
JOIN
(SELECT lname from delete_test_tbl4) a
on a.lname = b.lname;

SELECT * FROM delete_test_tbl4 ORDER BY lname;
GO

DROP TABLE delete_test_tbl;
GO
DROP TABLE delete_test_tbl2;
GO
DROP TABLE delete_test_tbl3;
GO
DROP TABLE delete_test_tbl4;
GO