\select count(*) from p2.movies;
-- SELECT * FROM p2.ratings;
-- DELETE FROM  p2.ratings;
-- TRUNCATE [TABLE] ratings
-- DELETE FROM p2.ratings
-- LIMIT 438044
SELECT COUNT(*) FROM(
	SELECT DISTINCT P2.movieid, P2.rating FROM ratings P2
	WHERE P2.rating =1 
	GROUP BY movieid )this_table;

-- SELECT id FROM p2.movies WHERE title = 'Heat';
SELECT COUNT(*) 
    FROM(
	SELECT DISTINCT p2.movieid, p2.rating FROM ratings P2
	WHERE 1 < p2.rating AND 3 > p2.rating
	GROUP BY p2.movieid )this_table;
    
SELECT COUNT(*) 
	FROM(    
	SELECT userid, inside_table.post_count AS sum_of FROM
		(SELECT DISTINCT p2.userid, COUNT(userid) AS post_count
		FROM ratings p2
		GROUP BY p2.userid)inside_table
	WHERE inside_table.post_count > 100
	)this_table;
    
SELECT COUNT(*) 
FROM(      
SELECT inner_table.userid, inner_table.sum_ratings/inner_table.post_count AS
avg_rating
FROM(
SELECT DISTINCT p2.userid, COUNT(userid) AS post_count, SUM(rating) as
sum_ratings
FROM ratings p2
GROUP BY p2.userid
 ) inner_table )this_table;

SELECT R.userid, AVG(M.popularity)
FROM ratings R, movies M
WHERE R.movieid = M.id
GROUP BY R.userid;
--------------------
SELECT COUNT(*) FROM(
SELECT COUNT(*)
FROM movies M2, movies M3
WHERE M2.popularity > M3.popularity
AND
M2.vote_average < M3.vote_average
GROUP BY M2.id)
this_table;

----------
SELECT COUNT(*) FROM(
SELECT COUNT(*) FROM movies M1, movies M2
WHERE M1.popularity = M2.popularity
AND M1.vote_average <> M2.vote_average
AND M1.id != M2.id
GROUP BY M1.id
)this_table;
