-- ALEX LEMA
-- Lemac001

-- 5.1
-- Find the names of all the juniors enrolled in a class taught by I. Teach 

SELECT S.sname  FROM cs4707.student S, cs4707.Class C, cs4707.Enrolled E, cs4707.Faculty F
WHERE S.snum = E.snum AND E.cname = C.name AND 
C.fid = F.fid AND F.fname = 'Ivana Teach' AND S.level = 'JR';

-- 5.2
--  Find the age of the oldest student who is either a History major or in a course taught by 
-- Ivana Teach

 SELECT  MAX(S.age) AS max_age FROM cs4707.Student S, cs4707.Class C, cs4707.Enrolled E, cs4707.Faculty F
 WHERE 
 S.snum = E.snum AND E.cname = C.name AND C.fid = F.fid AND F.fname = 'Ivana Teach' 
 OR
 S.major = 'History';
 
  -- 5.3
 -- Find the name of all classes that either meet in room R128 or have five or more students enrolled; 
SELECT DISTINCT C.name FROM cs4707.Class C
WHERE C.room = 'R128'
OR C.name IN (
SELECT E.cname
FROM cs4707.Enrolled E
GROUP BY E.cname
HAVING COUNT(*)>=5);

-- 5.4
-- Find the names of all students who are enrolled in two classes that meet at the same time; 
SELECT DISTINCT S.sname FROM cs4707.Student S, cs4707.Enrolled E, cs4707.Class C
WHERE 
S.snum 
IN 
(SELECT E1.snum FROM cs4707.Enrolled E1, cs4707.Enrolled E2, cs4707.Class C1, cs4707.Class C2
WHERE E1.snum = E2.snum AND E1.cname = E2.cname AND E1.cname = C1.name
AND E2.cname = C2.name AND C1.meets_at = C2.meets_at);

-- 5.5.
-- Find the names of faculty members who teach in every room in which some class is taught;   

SELECT table2.fname
FROM (
SELECT DISTINCT F.fname,  COUNT(F.fname) AS unique_rooms
FROM cs4707.Faculty F, cs4707.Class C
WHERE F.fid = C.fid AND (
	SELECT COUNT(*) AS number_of_rooms FROM (
	SELECT DISTINCT C.room
	FROM cs4707.Class C
    ) intermediate
) 
GROUP BY F.fname
ORDER BY F.fname
) table2
WHERE(
		(SELECT MAX(this.number_of_rooms)
        FROM(
			SELECT COUNT(*) AS number_of_rooms FROM (
			SELECT DISTINCT C.room
			FROM cs4707.Class C
			) intermediate
        )this)
        = table2.unique_rooms
);

-- 5.6 
-- Find the names of faculty members for whom the combined enrollment of the courses that they teach
-- is less than 5;    

SELECT DISTINCT F.fname 
FROM cs4707.Faculty F WHERE 5 > (
	SELECT COUNT(E.snum)
    FROM cs4707.Class C, cs4707.Enrolled E
    WHERE C.name = E.cname AND C.fid = F.fid
);


-- 5.7
-- Print the level and average age of students for that level, for each level; 

SELECT S.level, AVG(S.age)
FROM cs4707.Student S
GROUP BY S.level;

-- 5.8
-- Print the level and average age of students for that level for all levels except Junior; 

SELECT S.level, AVG(S.age)
FROM cs4707.Student S
WHERE S.level NOT LIKE 'JR'
GROUP BY S.level;

-- 5.9
-- For each faculty member that has taught classes only in room R128, print the faculty member's name
-- and the total number of classes he or she has taught 
SELECT test_table.fname, test_table.CourseCount
FROM( 
	SELECT F.fname, sum(not(C.room LIKE '%R128%')) = 0 AS no_rooms_wrong, COUNT(*) AS CourseCount
	FROM cs4707.Faculty F, cs4707.Class C
	WHERE F.fid = C.fid 
	GROUP BY F.fname
)test_table
WHERE test_table.no_rooms_wrong = 1;

-- 5.10
-- Find the names of students enrolled in the maximum number of classes

SELECT summary.sname
FROM (
	SELECT DISTINCT  S.sname, E.snum, COUNT(S.snum)
    AS number_of_classes FROM cs4707.Enrolled E
	INNER JOIN cs4707.Student S ON E.snum = S.snum
	GROUP BY E.snum
)AS summary
WHERE summary.number_of_classes = (
	SELECT MAX(sub_where.number_of_classes) AS max_classes
	FROM(
		SELECT DISTINCT  S.sname, E.snum, COUNT(S.snum) 
        AS number_of_classes FROM cs4707.Enrolled E
		INNER JOIN cs4707.Student S ON E.snum = S.snum
		GROUP BY E.snum
	) AS sub_where
);

-- 5.11
-- Find the names of students not enrolled in any class

SELECT DISTINCT S.sname 
FROM cs4707.Student S
WHERE S.sname NOT IN (
	SELECT DISTINCT  S1.sname
	FROM cs4707.Student S1, cs4707.Enrolled E
	WHERE S1.snum = E.snum
	ORDER BY S1.sname
);

-- 5.12
-- For each age value that appears in Students find the grade level value that appears most often.
-- For example if there are more FR students age 18 than SR,JR, SO, you should return pairs

SELECT DISTINCT derived_table.level, derived_table.age
FROM(
SELECT DISTINCT S.age, S.level, (COUNT(S.age)) AS number_of
FROM cs4707.Student S
GROUP BY S.age
ORDER BY number_of) derived_table
GROUP BY derived_table.age
ORDER BY derived_table.age;


-- Problem 2 
-- Find the name of students who have enrolled in some classes, but have not received grades

 SELECT DISTINCT E.snum 
 FROM cs4707.Enrolled E 
 WHERE E.snum  NOT IN (
	SELECT derived.snum
	FROM(
	SELECT DISTINCT E.snum 
	FROM cs4707.Enrolled E, cs4707.Grade G
	WHERE E.snum = G.snum
	)derived );
 
 
-- Problem 3
 -- For each class, print the name of the class and name of student who topped the class. If 2 students
 -- had the same score pick the younger one 
 
  --  Answer to problem 3
 SELECT grade_data.cname, grade_data.sname, MAX(grade_data.score) AS high_score
 FROM(
	 -- Get the students for each class with their scores
	 SELECT * FROM cs4707.Grade G 
	 NATURAL JOIN cs4707.Student S
	 ORDER BY score, S.age
 )grade_data
 GROUP BY cname;
 
 -- Problem 4
-- Find the second topper for class 'Operating System Design'. If there are two students with the same score
-- select the one whose name is lexicographically smallest

 -- Answer
 SELECT * FROM(
	 SELECT *, RANK() OVER (ORDER BY G.score DESC) AS ranking FROM cs4707.Grade G 
	 NATURAL JOIN cs4707.Student S
	 WHERE G.cname = 'Operating System Design' 
	 ORDER BY  G.score DESC ,S.sname ASC, G.cname , S.age
 )ranker
 WHERE ranker.ranking =2 
 ORDER BY ranker.snum LIMIT 0,1;


 -- Problem 5
 -- Check if two students have the same name
 SELECT  COUNT(*) AS C 
 FROM cs4707.Student S
 GROUP BY S.sname
 HAVING C > 1;
 
-- Problem 6 
-- Rank each student for the class 'Operating System Design'. iF two have the same score ,they are the same rank
 
 SELECT sname, RANK() OVER (ORDER BY G.score DESC) AS ranking FROM cs4707.Grade G 
 NATURAL JOIN cs4707.Student S
 WHERE G.cname = 'Operating System Design' 
ORDER BY G.score DESC;

-- Problem 7
-- Find class names with no prereqs
SELECT DISTINCT  C.name
FROM cs4707.Class C
WHERE C.name NOT IN (
	SELECT DISTINCT P.cname
	FROM cs4707.Prerequisite P
);

-- Problem 8 
-- Find all prerequisite for class 'Operating System Design' and 'Multivariate Analysis'; 

SELECT * FROM cs4707.Prerequisite P WHERE P.cname = 'Operating System Design'
UNION
SELECT * FROM cs4707.Prerequisite P WHERE P.cname = 'Multivariate Analysis';

-- Problem 9
-- find all class names with at least two prerequisite  

select inside.cname
from(
select *, count(cname) AS pre_count from cs4707.prerequisite group by cname
) inside
WHERE inside.pre_count > 1
;

-- Problem 10
-- Find youngest student by each department and major if their average grade score is more than 80 and
-- order them by name; 
-- Find the youngest by department alter

(SELECT *  FROM(
	SELECT *, MIN(this_step.age) AS minimum FROM
	(
		SELECT DISTINCT s.age, s.major, s.sname, c.name ,c.fid, f.deptid , g.score, jericho.avg_score
		from cs4707.class c natural join cs4707.faculty f natural join cs4707.student s natural join cs4707.enrolled e natural join (
			SELECT inter.sname, AVG(inter.score) as avg_score
			FROM(
				SELECT * FROM cs4707.Grade G2 NATURAL JOIN cs4707.Student S2
			) inter
			GROUP BY inter.sname
		) jericho natural join cs4707.Grade g
		GROUP BY deptid, sname, cname, score,snum
		ORDER BY deptid, age
	)this_step
	GROUP BY this_step.deptid, this_step.age
	)q3
WHERE q3.avg_score > 80 
GROUP BY deptid 
ORDER BY sname
)
    
UNION 
-- Find the youngest by major 
(
SELECT * FROM(  
SELECT *, MIN(inter_2.age) AS minimum FROM
	(
	SELECT DISTINCT s.age, s.major, s.sname, c.name ,c.fid, f.deptid, G4.score, jerichox.avg_score
			from cs4707.class c natural join cs4707.faculty f natural join cs4707.student s natural join cs4707.enrolled e natural join (
				SELECT interx.sname, AVG(interx.score) as avg_score
				FROM(
					SELECT * FROM cs4707.Grade G3 NATURAL JOIN cs4707.Student S3
				) interx
				GROUP BY interx.sname
			) jerichox natural join cs4707.Grade G4
	GROUP BY major, sname, cname, score,snum
	ORDER BY deptid, age
	)inter_2
	GROUP BY inter_2.major
	)q5
WHERE age = minimum AND q5.avg_score > 80
ORDER BY sname
) ;

-- Problem 11
-- Add five to the score of every student who has grades for db systems, but ensure nobody's grade surpasses 100
--  
CREATE TABLE temp_grades(snum INTEGER, cname CHAR(50), score INTEGER);
INSERT INTO temp_grades
(
	SELECT DISTINCT G.snum, G.cname, G.score
	FROM cs4707.Grade G
	WHERE G.cname LIKE '%Database Systems%'  AND G.score <= 95
);

UPDATE temp_grades 
SET temp_grades.score = temp_grades.score + 5;

UPDATE cs4707.Grade G
SET G.score = G.score + 5
WHERE G.snum IN (
	SELECT temp_grades.snum
    FROM temp_grades
);
DROP TABLE IF EXISTS temp_grades;

-- Problem 11
-- Add five to the score of every student who has grades for db systems, but ensure nobody's grade surpasses 100
--  

UPDATE cs4707.Grade G
SET G.score = G.score + 5
WHERE G.snum IN (SELECT * FROM  (
		SELECT DISTINCT G1.snum
		FROM cs4707.Grade G1
		WHERE G1.cname LIKE '%Database Systems%' AND G1.score <= 95
	)derived
);


