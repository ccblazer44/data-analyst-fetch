SELECT id, COUNT(*) 
FROM users
GROUP BY id
HAVING COUNT(*) > 1;

select * from users limit 100

select count(*) from users
-- 100000

SELECT id, COUNT(*) 
FROM users
GROUP BY id
HAVING COUNT(*) > 1;

-- checking gender
select distinct gender from users

SELECT gender, COUNT(*)
FROM users
GROUP BY gender
ORDER BY COUNT(*) DESC;

-- common sense updates
update users
set gender = 'non_binary'
where gender = 'Non-Binary'

update users
set gender = 'prefer_not_to_say'
where gender = 'Prefer not to say'

update users
set gender = 'not_listed'
where gender = 'My gender isn''t listed'


select count (distinct state)  from users -- 52

-- looks ok, includes DC and NULL
SELECT "state", COUNT(*)STATE
FROM users
GROUP BY state
ORDER BY COUNT(*) DESC;


-- checking LANGUAGE

select distinct "language" from users

SELECT "language", COUNT(*)
FROM users
GROUP BY "language"
ORDER BY COUNT(*) DESC;
-- looks ok



SELECT id, LENGTH(id) AS id_length
FROM users
ORDER BY id_length DESC;


SELECT *
FROM users
WHERE birth_date > CURRENT_DATE 
   OR birth_date < CURRENT_DATE - INTERVAL '120 years';





SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'users';



select count(distinct user_id) from transactions
-- 17694

select count(distinct id) from users
-- 100000

SELECT COUNT(DISTINCT t.user_id) AS unmatched_users
FROM transactions t
LEFT JOIN users u ON t.user_id = u.id
WHERE u.id IS NULL;
-- 17603

SELECT COUNT(DISTINCT t.user_id) AS matched_users
FROM transactions t
JOIN users u ON t.user_id = u.id;
-- 91

-- these tables aren't matching up, going to make for problems


select count(*) from transactions where user_id is null
