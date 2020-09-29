CREATE database cs4707;
USE cs4707;

create table student
(
    snum NUMERIC(9,0) primary key,
    sname VARCHAR(30),
    major VARCHAR(25),
    standing VARCHAR(2),
    age NUMERIC(3,0)
);
create table faculty
(
    fid NUMERIC(9,0) primary key,
    fname VARCHAR(30),
    deptid NUMERIC(2,0)
);
create table class
(
    name VARCHAR(40) primary key,
    meets_at VARCHAR(20),
    room VARCHAR(10),
    fid NUMERIC(9,0),
    foreign key(fid) references faculty(fid)
);
create table enrolled
(
    snum NUMERIC(9,0),
    cname VARCHAR(40),
    primary key(snum,cname),
    foreign key(snum) references student(snum),
    foreign key(cname) references class(name)
);
CREATE TABLE grade
(
    snum NUMERIC(9,0),
    cname VARCHAR(40),
    score NUMERIC(3,0),
    primary key(snum,cname),
    foreign key(snum) references student(snum),
    foreign key(cname) references class(name)
);
CREATE TABLE prerequisite
(
    cname VARCHAR(40),
    prereqcname VARCHAR(40),
    primary key(cname, prereqcname),
    foreign key(cname) references class(name),
    foreign key(prereqcname) references class(name)
);

LOAD DATA INFILE 'student.txt' INTO TABLE student
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
(snum, sname, major, standing, age);

LOAD DATA INFILE 'faculty.txt' INTO TABLE faculty
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n'
(fid, fname, deptid);

LOAD DATA INFILE 'class.txt' INTO TABLE class
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n'
(name, meets_at, room, fid);

LOAD DATA INFILE 'enrolled.txt' INTO TABLE enrolled
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n'
(snum, cname);

LOAD DATA INFILE 'grades.txt' INTO TABLE grade
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n'
(snum, cname, score);

LOAD DATA INFILE 'prerequisite.txt' INTO TABLE prerequisite
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n'
(cname, prereqcname);

--  Exercise 5.1
--  1
SELECT DISTINCT S.Sname
FROM student S, class C, enrolled E, faculty F
WHERE S.snum = E.snum AND E.cname = C.name AND C.fid = F.fid 
AND F.fname = 'Ivana Teach' AND S.standing = 'JR';
/*
Christopher Garcia
Paul Hall 
*/

--  2
SELECT MAX(S.age)
FROM
    student S
WHERE (S.major = 'History') OR S.snum IN (
SELECT E.snum
    FROM class C, enrolled E, faculty F
    WHERE E.cname = C.name AND C.fid = F.fid AND F.fname = 'Ivana Teach');
--  20

-- 3
SELECT C.name
FROM class C
WHERE
C.room = 'R128' OR C.name
IN
(
SELECT E.cname
    FROM enrolled E
    GROUP BY
E.cname
    HAVING   COUNT(*) >= 5);
/*
Archaeology of the Incas |
Dairy Herd Management    |
Data Structures          |
Database Systems         |
Intoduction to Math      |
Operating System Design  |
Patent Law      
*/

-- 4
SELECT DISTINCT S.sname
FROM student S
WHERE S.snum IN (SELECT E1.snum
FROM enrolled E1, enrolled E2, class C1, class C2
WHERE E1.snum = E2.snum AND E1.cname <> E2.cname 
AND E1.cname = C1.name AND E2.cname = C2.name AND C1.meets_at = C2.meets_at);
--  Empty Set


-- 5
SELECT DISTINCT F.fname
FROM faculty F
WHERE  NOT EXISTS(SELECT C.room
FROM class C
WHERE C.room not in (SELECT C1.room
FROM class C1
WHERE C1.fid = F.fid));
-- Richard Jackson


-- 6
SELECT DISTINCT F.fname
FROM faculty F
WHERE 5 > (SELECT COUNT(E.snum)
FROM class C, enrolled E
WHERE C.name = E.cname AND C.fid = F.fid);
/*
| John Williams    |
| Elizabeth Taylor |
| Mary Johnson     |
| William Moore    |
| James Smith      |
| Barbara Wilson   |
| Patricia Jones   |
| Michael Miller   |
| Robert Brown     |
| David Anderson   |
| Richard Jackson  |
| Ulysses Teach    |
| Jennifer Thomas  |
*/

-- 7
SELECT S.standing, AVG(S.age)
FROM student S
GROUP BY S.standing;
/*
| FR       |    17.6667 |
| JR       |    19.5000 |
| SO       |    18.4000 |
| SR       |    20.6667 |
*/

-- 8
SELECT S.standing, AVG(S.age)
FROM student S
WHERE S.standing <> 'JR'
GROUP BY S.standing;
/*
 standing | AVG(S.age) |
+-- -- -- -- -- +-- -- -- -- -- -- +
| FR       |    17.6667 |
| SO       |    18.4000 |
| SR       |    20.6667 
*/

-- 9
SELECT F.fname, COUNT(*) AS CourseCount
FROM faculty F, class C
WHERE F.fid = C.fid AND F.fid in 
(SELECT C1.fid
    from class C1
    where C1.room = 'R128')
GROUP BY
F.fid, F.fname;
/*
 fname            | CourseCount |
+-- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+
| Elizabeth Taylor |           2 |
| Barbara Wilson   |           2 |
| Robert Brown     |           1 |
| Richard Jackson  |           6 |
| Linda Davis      |           2 |
+-- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+
*/

-- 9 (second solution)
SELECT F.fname, COUNT(C.room)  AS CourseCount
FROM faculty F, class C 
WHERE F.fid = C.fid
GROUP BY F.fid, F.fname
HAVING SUM(NOT(C.room = 'R128')) = 0;
/*
 fname         | CourseCount |
+-- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+
| Robert Brown |           1 |
+-- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+
*/

-- 10
SELECT DISTINCT S.sname
FROM student S
WHERE S.snum IN (SELECT E.snum
FROM enrolled E
GROUP BY E.snum
HAVING COUNT(*) >=ALL(SELECT COUNT(*)
FROM enrolled E2
GROUP BY E2.snum));
/*
| sname          |
+-- -- -- -- -- -- -- -- +
| Juan Rodriguez |
| Ana Lopez   |
*/

-- 11
SELECT DISTINCT S.sname
FROM student S
WHERE S.snum NOT IN (SELECT E.snum
FROM enrolled E );
/*
| Charles Harris  |
| Angela Martinez |
| Thomas Robinson |
| Margaret Clark  |
| Dorthy Lewis    |
| Daniel Lee      |
| Nancy Allen     |
| Mark Young      |
| Donald King     |
| George Wright   |
| Steven Green    |
| Edward Baker    |
*/

-- 12
SELECT S.age, S.standing
FROM student S
GROUP BY S.age, S.standing
HAVING S.standing IN
(
SELECT S1.standing
FROM student S1
WHERE S1.age = S.age
GROUP BY
S1.standing, S1.age
HAVING COUNT(*) >=ALL(SELECT COUNT(*)
FROM student S2
WHERE s1.age = S2.age
GROUP BY S2.standing, S2.age));
/*
+------+-------+
| age  | level |
+------+-------+
| 21   | SR    |
| 22   | SR    |
| 20   | JR    |
| 19   | SO    |
| 18   | FR    |
| 17   | FR    |
+------+-------+
*/


-- Additional Queries
-- 2
SELECT sname
from student
where snum in (
SELECT snum
from enrolled
where snum not in
(SELECT snum
from grade));
-- Kenneth Hill

-- 3
SELECT V.cname, V.sname, V.age
FROM
    (SELECT s.sname, g.cname, s.age, g.score
    FROM grade g JOIN
        (SELECT grade.cname, max(score) as maxscore
        from grade
        group by grade.cname) T
        ON g.cname = T.cname AND g.score = T.maxscore
        JOIN student s ON s.snum = g.snum) V
HAVING V.age = (SELECT MIN(s1.age)
from student s1, grade g1
where g1.snum = s1.snum AND g1.cname = V.cname AND g1.score = V.score);

/*
+-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- +-- -- -- +
| cname                   | sname              | age  |
+-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- +-- -- -- +
| Communication Networks  | Ana Lopez          |   19 |
| Data Structures         | Karen Scott        |   18 |
| Database Systems        | Christopher Garcia |   20 |
| Operating System Design | Luis Hernandez     |   17 |
| Optical Electronics     | Luis Hernandez     |   17 |
| Patent Law              | Susan Martin       |   20 |
| Perception              | Juan Rodriguez     |   20 |
| Social Cognition        | Juan Rodriguez     |   20 |
| Urban Economics         | Betty Adams        |   20 |
+-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- +-- -- -- +
*/

-- 4
SELECT s.sname
from student s, grade g
WHERE
s.snum = g.snum and g.cname = 'Operating System Design'
    AND g.score < (SELECT MAX(score)
    from grade
    where cname = 'Operating System Design')
ORDER BY s.sname ASC LIMIT 1;
--  Ana Lopez

-- 5
SELECT * FROM student
s1, student s2 WHERE s1.sname = s2.sname AND s1.snum <> s2.snum;
--  Empty Set

-- 6
select distinct S.snum, S.sname, G.score,
rank() over( order by (G.score) desc) s_rank 
from Student S, Grade G
where S.snum = G.snum 
and G.cname = 'Operating System Design';
/*
+-- -- -- -- -- -- -- -- -- -- +-- -- -- -+-- -- -- +
| sname              | score | rank |
+-- -- -- -- -- -- -- -- -- -- +-- -- -- -+-- -- -- +
| Luis Hernandez     |   100 |    1 |
| Ana Lopez          |    98 |    2 |
| Christopher Garcia |    98 |    2 |
| Karen Scott        |    98 |    2 |
| Lisa Walker        |    56 |    3 |
| Joseph Thompson    |    35 |    4 |
+-- -- -- -- -- -- -- -- -- -- +-- -- -- -+-- -- -- +
*/

-- 7
select name
from class
where name not in (select cname
from prerequisite);
/*
 name                             |
+---------------------------------+
| Air Quality Engineering         |
| Aviation Accident Investigation |
| Orbital Mechanics               |
| Patent Law                      |
| Social Cognition                |
| Archaeology of the Incas        |
| Introductory Latin              |
| Optical Electronics             |
| Intoduction to Math             |
| Marketing Research              |
| Organic Chemistry               |
| Perception                      |
| Seminar in American Art         |
| Urban Economics                 |
| Data Structures                 |
| American Political Parties      |
+---------------------------------+
*/

--  8
-- solution for recursively getting all prerequisites
WITH RECURSIVE tree AS ( 
   SELECT cname as q, cname, 
          prereqcname,
          1 as level 
   FROM prerequisite
   WHERE cname IN ('Operating System Design','Multivariate Analysis')

   UNION ALL 

   SELECT t.q, p.cname,
          p.prereqcname, 
          t.level + 1
   FROM prerequisite p
     JOIN tree t ON t.prereqcname = p.cname
)
SELECT tree.q , prereqcname
FROM tree;
/*
+-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+
| q                       | prereqcname         |
+-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+
| Multivariate Analysis   | Intoduction to Math |
| Operating System Design | Database Systems    |
| Operating System Design | Data Structures     |
| Operating System Design | Intoduction to Math |
+-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+
*/

-- 9
WITH RECURSIVE tree AS ( 
   SELECT cname as q, cname, 
          prereqcname,
          1 as level 
   FROM prerequisite

   UNION ALL 

   SELECT t.q, p.cname,
          p.prereqcname, 
          t.level + 1
   FROM prerequisite p
     JOIN tree t ON t.prereqcname = p.cname
)
SELECT tree.q , count(*)
FROM tree GROUP BY tree.q
HAVING count(*) >= 2;

/*
+-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- +
| q                       | count(*) |
+-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- +
| Database Systems        |        2 |
| Operating System Design |        3 |
| Communication Networks  |        2 |
+-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- +
*/

-- 10
SELECT DISTINCT s1.sname, s1.age, V.avgscore, s1.major
from student s1,
    (SELECT s.snum, AVG(g.score) as avgscore
    from student s, grade g
    WHERE s.snum = g.snum
    GROUP BY s.snum) V
WHERE V.avgscore >= 80
    AND s1.snum = V.snum AND s1.age =
(select MIN(s2.age)
    from student s2
    where s2.major = s1.major);
/*
+-- -- -- -- -- -- -- -- +-- -- -- +-- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- +
| sname          | age  | avgscore | major                  |
+-- -- -- -- -- -- -- -- +-- -- -- +-- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- +
| Luis Hernandez |   17 |  93.5000 | Electrical Engineering |
| Karen Scott    |   18 |  99.0000 | Computer Engineering   |
+-- -- -- -- -- -- -- -- +-- -- -- +-- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- +
*/

-- Solution 2:
SELECT A.sname, A.age, A.major, A.average 
		FROM (  SELECT S.sname, S.age, S.major, AVG(G.score) as average 
				FROM Student S, Grade G 
				WHERE S.snum = G.snum 
				GROUP BY S.sname 
				ORDER BY S.major, S.age ) AS A 
		WHERE A.average > 80.0 
		GROUP BY A.major;
/* OUTPUT
+----------------+------+------------------------+-----------+
| sname          | age  | major                  |  average
+----------------+------+------------------------+-----------+
| Juan Rodriguez |   20 | Psychology             | 87.0000
| Karen Scott    |   18 | Computer Engineering   | 99.0000
| Luis Hernandez |   17 | Electrical Engineering | 93.5000
| Paul Hall      |   18 | Computer Science       | 90.0000
+----------------+------+------------------------+-----------+
*/
	

-- 11
UPDATE grade SET score = CASE
WHEN score BETWEEN 95 and 100 THEN 100
ELSE score + 5
END
WHERE cname = 'Database Systems';
/*
select * from grade where cname = 'Database Systems';
-- -- -- -- -- -+-- -- -- -- -- -- -- -- -- +-- -- -- -+
| snum      | cname            | score |
+-- -- -- -- -- -+-- -- -- -- -- -- -- -- -- +-- -- -- -+
| 112348546 | Database Systems |    85 |
| 115987938 | Database Systems |   100 |
| 322654189 | Database Systems |   100 |
| 348121549 | Database Systems |    95 |
+-- -- -- -- -- -+-- -- -- -- -- -- -- -- -- +-- -- -- -+
*/
