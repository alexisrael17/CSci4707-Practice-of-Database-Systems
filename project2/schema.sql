CREATE DATABASE P2;
USE P2;
CREATE TABLE ratings
(
    userid NUMERIC(15,0),
    movieid NUMERIC(15,0),
    rating NUMERIC(3,1),
    time_stamp NUMERIC(15,0)
);

CREATE TABLE movies
(
    id NUMERIC(15,0),
    title VARCHAR(1000),
    revenue NUMERIC(20),
    vote_count NUMERIC(20),
    vote_average NUMERIC(3,1),
    popularity NUMERIC(20)
);

-- Note: If LOAD LOCAL DATA INFILE is not supported by your MySQL version, you can skip the "LOCAL" keyword. 
-- If that results in Error Code: 1290 MySQL running with --secure-file-priv option, please run the following command
-- to get the location of the secure file directory
-- SHOW VARIABLES LIKE "secure_file_priv";
-- You can then put your files in that location and run the LOAD DATA INFILE command
-- For both windows and Linux, use / in the file path

-- For me secure_file_priv = 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads'

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Rating.csv' INTO TABLE ratings
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(userid, movieid, rating, time_stamp);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Movie.tsv' INTO TABLE movies
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, title, revenue, vote_count, vote_average, popularity);

-- This command is used to start recording execution times of queries
SET profiling = 1;

-- This command is used to see the execution times of all queries run so far
SHOW PROFILES;