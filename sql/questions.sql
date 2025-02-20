select * from transactions_backup order by receipt_id desc




select * from transactions limit 10

-- q1

SELECT p.brand, COUNT(DISTINCT t.receipt_id) AS receipt_count, SUM(t.quantity * t.sale) AS total
FROM transactions t
JOIN users u ON t.user_id = u.id
JOIN products p ON t.barcode = p.barcode
WHERE p.brand IS NOT NULL and u.birth_date <= CURRENT_DATE - INTERVAL '21 years'
GROUP BY p.brand
ORDER BY receipt_count DESC, total desc

SELECT p.brand
FROM transactions t
JOIN users u ON t.user_id = u.id
JOIN products p ON t.barcode = p.barcode
WHERE p.brand IS NOT NULL and u.birth_date <= CURRENT_DATE - INTERVAL '21 years'
GROUP BY p.brand
ORDER BY COUNT(DISTINCT t.receipt_id) DESC, SUM(t.quantity * t.sale) desc
LIMIT 5


select CURRENT_DATE - INTERVAL '21 years'

select * from users
where birth_date <= '2000-01-01'
limit 100

-- q2


SELECT p.brand, SUM(t.quantity * t.sale) AS total_sales
FROM transactions t
JOIN users u ON t.user_id = u.id
JOIN products p ON t.barcode = p.barcode
WHERE p.brand IS NOT NULL and u.created_date <= CURRENT_DATE - INTERVAL '6 months'
GROUP BY p.brand
ORDER BY total_sales desc

SELECT p.brand
FROM transactions t
JOIN users u ON t.user_id = u.id
JOIN products p ON t.barcode = p.barcode
WHERE p.brand IS NOT NULL and u.created_date <= CURRENT_DATE - INTERVAL '6 months'
GROUP BY p.brand
ORDER BY SUM(t.quantity * t.sale) desc




WITH users_6_months AS (
    SELECT id
    FROM users
    WHERE created_date <= CURRENT_DATE - INTERVAL '6 months'
),
brand_sales AS (
    SELECT p.brand, 
           SUM(t.quantity * t.sale) AS total_sales
    FROM transactions t
    JOIN users_6_months u ON t.user_id = u.id
    JOIN products p ON t.barcode = p.barcode
    WHERE p.brand IS NOT NULL
    GROUP BY p.brand
)
SELECT brand, total_sales
FROM brand_sales
ORDER BY total_sales DESC




select * from users
where created_date <= CURRENT_DATE - INTERVAL '6 months'
order by created_date desc
limit 100

--q3

select * from users
where birth_date >= '2012-01-01'
limit 100

-- total health and wellness
SELECT SUM(t.quantity * t.sale) AS total_health_wellness_sales
FROM transactions t
JOIN products p ON t.barcode = p.barcode
WHERE p.category_1 = 'Health & Wellness';
-- 29449.5688

-- unknown users
SELECT COUNT(DISTINCT t.receipt_id) AS transactions_with_unknown_user
FROM transactions t
JOIN products p ON t.barcode = p.barcode
LEFT JOIN users u ON t.user_id = u.id
WHERE p.category_1 = 'Health & Wellness'
AND u.id IS NULL;
-- 3398

-- known users
SELECT COUNT(DISTINCT t.receipt_id) AS transactions_with_known_user
FROM transactions t
JOIN products p ON t.barcode = p.barcode
JOIN users u ON t.user_id = u.id
WHERE p.category_1 = 'Health & Wellness';
-- 17



-- unknown birthdate
SELECT COUNT(DISTINCT t.receipt_id) AS transactions_with_unknown_birthdate
FROM transactions t
JOIN products p ON t.barcode = p.barcode
JOIN users u ON t.user_id = u.id
WHERE p.category_1 = 'Health & Wellness'
AND u.birth_date IS NULL;
-- 0


-- due to the huge imbalance in unknown users we won't use this.  It shows 99.41% of health and wellness
-- transactions do not have an associated user

SELECT generation,
       total_sales,
       ROUND((total_sales * 100.0) / NULLIF(sum_total_sales, 0), 2) AS percentage_of_sales
FROM (
    -- Breakdown of Health & Wellness sales by generation, unknown birth date, and unknown users
    SELECT 
           CASE 
               WHEN u.id IS NULL THEN 'Unknown User'
               WHEN u.birth_date IS NULL THEN 'Unknown Birth Date'
               WHEN u.birth_date >= '2012-01-01' THEN 'Gen Alpha'
               WHEN u.birth_date BETWEEN '1997-01-01' AND '2011-12-31' THEN 'Gen Z'
               WHEN u.birth_date BETWEEN '1981-01-01' AND '1996-12-31' THEN 'Millennials'
               WHEN u.birth_date BETWEEN '1965-01-01' AND '1980-12-31' THEN 'Gen X'
               WHEN u.birth_date BETWEEN '1946-01-01' AND '1964-12-31' THEN 'Boomers'
               ELSE 'Silent Generation'
           END AS generation,
           SUM(t.quantity * t.sale) AS total_sales,
           (SELECT SUM(t2.quantity * t2.sale) 
            FROM transactions t2
            JOIN products p2 ON t2.barcode = p2.barcode
            WHERE p2.category_1 = 'Health & Wellness') AS sum_total_sales
    FROM transactions t
    LEFT JOIN users u ON t.user_id = u.id
    JOIN products p ON t.barcode = p.barcode
    WHERE p.category_1 = 'Health & Wellness'
    GROUP BY generation
) breakdown
ORDER BY total_sales DESC;



-- going to use this even though its ending up with very little data
WITH user_generations AS (
    SELECT id, 
           CASE 
               WHEN birth_date >= '2012-01-01' THEN 'Gen Alpha'
               WHEN birth_date BETWEEN '1997-01-01' AND '2011-12-31' THEN 'Gen Z'
               WHEN birth_date BETWEEN '1981-01-01' AND '1996-12-31' THEN 'Millennials'
               WHEN birth_date BETWEEN '1965-01-01' AND '1980-12-31' THEN 'Gen X'
               WHEN birth_date BETWEEN '1946-01-01' AND '1964-12-31' THEN 'Boomers'
               ELSE 'Silent Generation'
           END AS generation
    FROM users
    WHERE birth_date IS NOT NULL
),
category_sales AS (
    SELECT u.generation,
           SUM(t.quantity * t.sale) AS health_wellness_sales
    FROM transactions t
    JOIN user_generations u ON t.user_id = u.id
    JOIN products p ON t.barcode = p.barcode
    WHERE p.category_1 = 'Health & Wellness'
    GROUP BY u.generation
),
total_sales AS (
    SELECT u.generation,
           SUM(t.quantity * t.sale) AS total_sales
    FROM transactions t
    JOIN user_generations u ON t.user_id = u.id
    GROUP BY u.generation
)
SELECT ts.generation,
       cs.health_wellness_sales,
       ts.total_sales,
       ROUND((cs.health_wellness_sales * 100.0) / NULLIF(ts.total_sales, 0), 2) AS percentage_of_sales
FROM total_sales ts
LEFT JOIN category_sales cs ON ts.generation = cs.generation
ORDER BY percentage_of_sales DESC;





-- power users
WITH user_activity AS (
    SELECT user_id, 
           COUNT(DISTINCT receipt_id) AS total_receipts,
           SUM(quantity * sale) AS total_spent
    FROM transactions
    GROUP BY user_id
)
SELECT u.id, u.created_date, u.state, u.language, u.gender, TO_CHAR(age(current_date, u.birth_date), 'YY "Years"') as age, 
u.birth_date, ua.total_receipts, ua.total_spent
FROM users u
JOIN user_activity ua ON u.id = ua.user_id
ORDER BY ua.total_spent desc ,  ua.total_receipts DESC

LIMIT 10;




-- segmented by age group and gender
WITH user_activity AS (
    SELECT user_id, 
           COUNT(DISTINCT receipt_id) AS total_receipts,
           SUM(quantity * sale) AS total_spent
    FROM transactions
    GROUP BY user_id
),
user_details AS (
    SELECT id, 
           gender, 
           EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) AS age
    FROM users
    WHERE birth_date IS NOT NULL
)
SELECT 
    CASE 
        WHEN ud.age < 18 THEN 'Under 18'
        WHEN ud.age BETWEEN 18 AND 24 THEN '18-24'
        WHEN ud.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN ud.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN ud.age BETWEEN 45 AND 54 THEN '45-54'
        WHEN ud.age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+' 
    END AS age_group,
    ud.gender,
    COUNT(DISTINCT ua.user_id) AS user_count,
    SUM(ua.total_receipts) AS total_receipts,
    SUM(ua.total_spent) AS total_spent
FROM user_activity ua
JOIN user_details ud ON ua.user_id = ud.id
GROUP BY age_group, ud.gender
ORDER BY total_receipts DESC;



-- dips and salsa

select distinct category_1 from products

select distinct category_4, category_3, category_2 from products where category_3 ILIKE '%sals%'

select distinct category_4 from products where category_2 = 'Dips & Salsa'


SELECT p.brand, 
       SUM(t.quantity * t.sale) AS total_sales
FROM transactions t
JOIN products p ON t.barcode = p.barcode
WHERE p.category_2 = 'Dips & Salsa'
GROUP BY p.brand
ORDER BY total_sales DESC

SELECT p.brand, 
       SUM(t.quantity * t.sale) AS total_sales,
       COUNT(DISTINCT t.receipt_id) AS receipts_scanned
FROM transactions t
JOIN products p ON t.barcode = p.barcode
WHERE p.category_2 = 'Dips & Salsa'
GROUP BY p.brand
ORDER BY total_sales DESC;



-- year over year growth
WITH yearly_receipts AS (
    SELECT EXTRACT(YEAR FROM purchase_date) AS year,
           COUNT(DISTINCT receipt_id) AS total_receipts
    FROM transactions
    GROUP BY year
)
SELECT 
    yr1.year AS year,
    yr1.total_receipts AS receipts_this_year,
    yr2.total_receipts AS receipts_last_year,
    ROUND(
        (yr1.total_receipts - yr2.total_receipts) * 100.0 / NULLIF(yr2.total_receipts, 0), 2
    ) AS yoy_growth_percentage
FROM yearly_receipts yr1
LEFT JOIN yearly_receipts yr2 ON yr1.year = yr2.year + 1
ORDER BY yr1.year DESC;


-- no good we don't have transaction data across years

-- comparing each years growth to the previous years growth
WITH yearly_users AS (
    SELECT EXTRACT(YEAR FROM created_date) AS year,
           COUNT(id) AS new_users
    FROM users
    GROUP BY year
)
SELECT 
    yr1.year AS year,
    yr1.new_users AS users_this_year,
    yr2.new_users AS users_last_year,
    ROUND(
        (yr1.new_users - yr2.new_users) * 100.0 / NULLIF(yr2.new_users, 0), 2
    ) AS yoy_growth_percentage
FROM yearly_users yr1
LEFT JOIN yearly_users yr2 ON yr1.year = yr2.year + 1
ORDER BY yr1.year DESC;


select * from users limit 100

SELECT count(*) 
FROM users
WHERE EXTRACT(YEAR FROM created_date) = 2020;


-- comparing each years growth using the total number of users
WITH yearly_users AS (
    SELECT EXTRACT(YEAR FROM created_date) AS year,
           COUNT(id) AS new_users
    FROM users
    GROUP BY year
),
cumulative_users AS (
    SELECT year, 
           new_users,
           SUM(new_users) OVER (ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS total_users_prior
    FROM yearly_users
)
SELECT year,
       new_users,
       COALESCE(total_users_prior, 0) AS total_users_prior,
       ROUND(
           (new_users * 100.0) / NULLIF(total_users_prior, 0), 2
       ) AS yoy_growth_percentage
FROM cumulative_users
ORDER BY year DESC;



