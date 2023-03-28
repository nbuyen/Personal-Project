--The 10 best-selling video games
SELECT TOP 10 * FROM game_sales
ORDER BY games_sold DESC
--Missing review scores
SELECT g.year, COUNT(g.game) AS 'missing_review_scores' 
FROM game_sales g JOIN reviews r ON g.game = r.game
WHERE r.critic_score = '0' or r.user_score = '0'
GROUP BY g.year 
ORDER BY year
--Years that video game critics loved
SELECT TOP 5 g.year, ROUND(AVG(r.critic_score),2) AS 'avg_critic_score'
FROM game_sales g JOIN reviews r ON g.game = r.game
GROUP BY g.year
ORDER BY avg_critic_score DESC
--Years that have more than 4 reviewed games
SELECT g.year, COUNT(g.game) AS 'num_reviewed_games', ROUND(AVG(r.critic_score),2) AS 'avg_critic_score'
FROM game_sales g JOIN reviews r ON g.game = r.game
GROUP BY g.year
HAVING COUNT(g.game)> 4
ORDER BY avg_critic_score DESC
--Years that dropped off the critic's favourite list
WITH t1 (year, avg_critic_score) AS 
(SELECT g.year, ROUND(AVG(r.critic_score),2)
FROM game_sales g JOIN reviews r ON g.game = r.game
GROUP BY g.year),
	t2 (year, num_reviewed_games, avg_critic_score) AS 
(SELECT g.year, COUNT(g.game), 
	ROUND(AVG(r.critic_score),2)
FROM game_sales g JOIN reviews r ON g.game = r.game
GROUP BY g.year
HAVING COUNT(g.game)> 4)
SELECT * FROM t1 
WHERE t1.year NOT IN (SELECT year FROM t2)
ORDER BY avg_critic_score DESC

--Years video game players loved
WITH t3 (year, avg_user_score) AS 
(SELECT g.year, ROUND(AVG(r.user_score),2)
FROM game_sales g JOIN reviews r ON g.game = r.game
GROUP BY g.year)
SELECT TOP 5 * FROM t3
ORDER BY avg_user_score DESC

--Years that both players and critics loved
WITH t1 (year, num_games, avg_critic_score) AS 
(SELECT g.year, COUNT(g.game), 
	ROUND(AVG(r.critic_score),2)
FROM game_sales g JOIN reviews r ON g.game = r.game
GROUP BY g.year
HAVING COUNT(g.game)> 4),

t2 (year, num_games, avg_user_score) AS
(SELECT g.year, COUNT(g.game), 
	ROUND(AVG(r.user_score),2)
FROM game_sales g JOIN reviews r ON g.game = r.game
GROUP BY g.year
HAVING COUNT(g.game)> 4)

SELECT year from t1 INTERSECT SELECT year from t2

--Sales in the best video game years
WITH t1 (year, num_games, avg_critic_score) AS 
(SELECT g.year, COUNT(g.game), 
	ROUND(AVG(r.critic_score),2)
FROM game_sales g JOIN reviews r ON g.game = r.game
GROUP BY g.year
HAVING COUNT(g.game)> 4),
t2 (year, num_games, avg_user_score) AS
(SELECT g.year, COUNT(g.game), 
	ROUND(AVG(r.user_score),2)
FROM game_sales g JOIN reviews r ON g.game = r.game
GROUP BY g.year
HAVING COUNT(g.game)> 4)
SELECT g.year, SUM(g.games_sold) AS 'total_games_sold'
FROM game_sales g 
WHERE g.year IN (SELECT year FROM t1 INTERSECT SELECT year FROM t2)
GROUP BY g.year
ORDER BY total_games_sold DESC
