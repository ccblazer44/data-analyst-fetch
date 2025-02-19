select * from products limit 100

select * from transactions where receipt_id = '01a70fe0-026f-4bea-9da4-7d13bbf21e9a'

select * from products where barcode is NULL

-- lots of dupe barcodes.  lots of null barcodes
SELECT barcode, COUNT(*)
FROM products
GROUP BY barcode
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- without a barcode these records are useless, delete the NULL
delete from products where barcode is null


-- dupe barcodes
SELECT * 
FROM products
WHERE barcode IN (
    SELECT barcode
    FROM products
    GROUP BY barcode
    HAVING COUNT(*) > 1
)
ORDER BY barcode;

--full duplicates
WITH duplicate_rows AS (
    SELECT *, COUNT(*) OVER (PARTITION BY category_1, category_2, category_3, category_4, manufacturer, brand, barcode) AS duplicate_count
    FROM products
)
SELECT *
FROM duplicate_rows
WHERE duplicate_count > 1
ORDER BY barcode;


-- full duplicate removal
CREATE TABLE products_deduplicated AS
SELECT DISTINCT ON (category_1, category_2, category_3, category_4, manufacturer, brand, barcode) *
FROM products;

DROP TABLE products;
ALTER TABLE products_deduplicated RENAME TO products;



-- investigating how often duplicated batcodes appear in transactions

WITH duplicate_barcodes AS (
    -- Find barcodes that appear more than once in the products table
    SELECT barcode
    FROM products
    WHERE barcode IS NOT NULL
    GROUP BY barcode
    HAVING COUNT(*) > 1
),
transaction_counts AS (
    -- Count how many times each duplicated barcode appears in transactions
    SELECT barcode, COUNT(*) AS transaction_count
    FROM transactions
    WHERE barcode IN (SELECT barcode FROM duplicate_barcodes)
    GROUP BY barcode
)
SELECT p.*, 
       COALESCE(tc.transaction_count, 0) AS transaction_count
FROM products p
JOIN duplicate_barcodes db ON p.barcode = db.barcode
LEFT JOIN transaction_counts tc ON p.barcode = tc.barcode
ORDER BY transaction_count DESC, p.barcode;


-- 4003207 is the only barcode showing up in transactions so we can ignore the others for now

select * from products where barcode = 4003207


-- for the sake of this task I'm going to make a judgement call because I know M&Ms are candy

delete from products where id = 325188



SELECT category_1, COUNT(*)
FROM products
GROUP BY category_1
ORDER BY COUNT(*) DESC;

SELECT brand, COUNT(*)
FROM products
GROUP BY brand
ORDER BY COUNT(*) DESC;

SELECT manufacturer, COUNT(*)
FROM products
GROUP BY manufacturer
ORDER BY COUNT(*) DESC;


SELECT *
FROM products
WHERE manufacturer ILIKE '%unknown%' OR manufacturer ILIKE '%placeholder%' or manufacturer ILIKE '%manufactur' or brand ILIKE '%known%' or brand ILIKE '%review%'

select * from products where brand ilike '%review'


select * from products
where manufacturer = '' or manufacturer is null or brand = '' or brand is null


-- ok we want to use barcode as the key, so lets remove the dupes using common sense
SELECT * 
FROM products
WHERE barcode IN (
    SELECT barcode
    FROM products
    GROUP BY barcode
    HAVING COUNT(*) > 1
)
ORDER BY barcode;

-- if a record has a placeholder or NULL manufacturer or brand we will remove that one
-- if a record has more categories we will use that

-- all else being equal use the one that has more records for the brand

select count(*) from products where brand = 'SCHWARZKOPF'

select count(*) from products where brand = 'GÖT2B'

-- more common category name?


select count(*) from products where category_3 = 'Candy Variety Pack'

select count(*) from products where category_3 = 'Chocolate Candy'

-- some are a pure judgement call, like barcode 3473009, I would NEVER go around deleting like this in a production environment

-- delete from products where id in ('327049',
-- '796382',
-- '358794',
-- '614850',
-- '224418',
-- '589104',
-- '655124',
-- '725968',
-- '61094',
-- '782545',
-- '320504',
-- '245306',
-- '448023',
-- '63657',
-- '284566',
-- '461981',
-- '520817',
-- '372282',
-- '369625',
-- '153550',
-- '403879',
-- '487507',
-- '225551',
-- '566587',
-- '491184',
-- '53296')
