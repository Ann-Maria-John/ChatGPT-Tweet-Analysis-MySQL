USE chatgpt;

-- 1.
-- most engaged tweet
select t.tweet_id, e.total_engagement
from tweet t join engagement e
on t.tweet_id = e.tweet_id
ORDER BY total_engagement DESC;

select t.tweet_id, e.total_engagement,
DENSE_RANK() OVER (ORDER BY total_engagement DESC) AS engagement_rank
from tweet t join engagement e
on t.tweet_id = e.tweet_id; -- rank 70 twice

-- 2.
-- Top media tweet (ones that include an image/video/gif) wrt tweet engagement
-- with and without media
select t.tweet_id, e.total_engagement, m.media_present,
ROW_NUMBER() OVER (ORDER BY total_engagement DESC) AS rownumber
from tweet t join engagement e
on t.tweet_id = e.tweet_id
join media m
on e.tweet_id = m.tweet_id;

-- max, avg, min engagement for tweets with media and without media
select  m.media_present, max(e.total_engagement) AS max_engagement,
AVG(e.total_engagement) AS avg_engagement, min(e.total_engagement) AS min_engagement
from engagement e join media m
on e.tweet_id = m.tweet_id
where m.media_present = 0
GROUP BY m.media_present
UNION
select  m.media_present, max(e.total_engagement) AS max_engagement,
AVG(e.total_engagement) AS avg_engagement, min(e.total_engagement) AS min_engagement
from engagement e join media m
on e.tweet_id = m.tweet_id
where m.media_present = 1
GROUP BY m.media_present;

-- On an average tweets with media has more engagement compared to those without media, almost double.
-- However, top 5 tweets wrt tweet engagement has no media.

-- 3.
-- Which tweet gets more engagement - tweets with or without links
-- with and without links
select t.tweet_id, e.total_engagement, e.link_present,
ROW_NUMBER() OVER (ORDER BY total_engagement DESC) AS rownumber
from tweet t join engagement e
on t.tweet_id = e.tweet_id;

-- max, avg, min engagement for tweets with media and without media
select  link_present, max(total_engagement) AS max_engagement,
AVG(total_engagement) AS avg_engagement, min(total_engagement) AS min_engagement
from engagement
where link_present = 0
GROUP BY link_present
UNION
select  link_present, max(total_engagement) AS max_engagement,
AVG(total_engagement) AS avg_engagement, min(total_engagement) AS min_engagement
from engagement
where link_present = 1
GROUP BY link_present;

-- On an average tweets without links have more engagement compared to those with links, almost triple.
-- Among, top 10 tweets wrt tweet engagement only two have links.

-- 4. 
-- Count of the Tweets in a conversation using ‘conversation_id’ : 
-- [get count of tweet_ids under the same conversation_id] -> number of replies
SELECT 
    COUNT(t.tweet_id) as tweet_id_count,
    c.conversation_id
FROM
    tweet t inner join tweet c ON c.tweet_id = t.tweet_id
GROUP BY c.conversation_id
ORDER BY tweet_id_count DESC;

SELECT COUNT(mentioned_users) as count_user FROM muser group by tweet_id;

-- 5.
-- Do tweets with mentioned users have more engagement? 
-- [Use MentionedUsers column and find engagement for tweet IDs]
SELECT m.tweet_id, COUNT(m.mentioned_users) as count_mentioned_users, e.total_engagement,
ROW_NUMBER() OVER (ORDER BY e.total_engagement DESC) AS rownumber
FROM muser m join engagement e 
on m.tweet_id = e.tweet_id
group by m.tweet_id, e.total_engagement
ORDER BY total_engagement DESC;

-- max, avg, min engagement for tweets with media and without media
SELECT count_mentioned_users, max(total_engagement) AS max_engagement,
AVG(total_engagement) AS avg_engagement, min(total_engagement) AS min_engagement
from 
(SELECT m.tweet_id, COUNT(m.mentioned_users) as count_mentioned_users, e.total_engagement,
ROW_NUMBER() OVER (ORDER BY e.total_engagement DESC) AS rownumber
FROM muser m join engagement e 
on m.tweet_id = e.tweet_id
group by m.tweet_id, e.total_engagement
ORDER BY total_engagement DESC) t
where t.count_mentioned_users = 0;

select (select max(total_engagement) from engagement e where mentioned_link is not null) as max_not_null_count,
(select max(total_engagement) from engagement e where mentioned_link is  null) as max_null_count from engagement
limit 1;
select (select avg(total_engagement) from engagement e where mentioned_link is not null) as avg_not_null_count,
(select avg(total_engagement) from engagement e where mentioned_link is  null)as avg_null_count from engagement
limit 1;
select (select min(total_engagement) from engagement e where mentioned_link is not null) as min_not_null_count,
(select min(total_engagement) from engagement e where mentioned_link is  null) as min_null_count from engagement
limit 1;
