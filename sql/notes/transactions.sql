COPY transactions(receipt_id, purchase_date, scan_date, store_name, user_id, barcode, final_quantity, final_sale)
FROM '/path/to/TRANSACTION_TAKEHOME.csv'
DELIMITER ',' CSV HEADER;

-- whoops, thought receipt_id would be the key but its duped


ALTER TABLE transactions 
DROP CONSTRAINT transactions_pkey,
ADD COLUMN id SERIAL PRIMARY KEY;


-- added new id column to use as a key temporarily will I investigate the data then load it in
COPY transactions(receipt_id, purchase_date, scan_date, store_name, user_id, barcode, final_quantity, final_sale)
FROM '/Users/bleezy/repos/data-analyst-fetch/input/TRANSACTION_TAKEHOME.csv'
DELIMITER ',' CSV HEADER;


select  * from transactions
order by receipt_id
limit 100




-- lots of dupes
SELECT receipt_id, COUNT(*) 
FROM transactions
GROUP BY receipt_id
HAVING COUNT(*) > 1;

-- everything is a dupe?
SELECT receipt_id, COUNT(*) 
FROM transactions
GROUP BY receipt_id
HAVING COUNT(*) = 1;

-- yes everything is a dupe
SELECT * 
FROM transactions
WHERE receipt_id IN (
    SELECT receipt_id 
    FROM transactions 
    GROUP BY receipt_id
    HAVING COUNT(*) > 1
)
ORDER BY receipt_id;

select count(*) from transactions

select * from transactions 
where receipt_id = 'ba7610de-985b-48dc-94db-8ba5d52bbe40'

-- check to make sure instances where recept_id is duplicated, user_id is as well.  it is
SELECT receipt_id, COUNT(DISTINCT user_id) AS unique_users
FROM transactions
GROUP BY receipt_id
HAVING COUNT(DISTINCT user_id) > 1;

-- check to make sure instances where recept_id is duplicated, scan_date is as well.  it is
SELECT receipt_id, COUNT(DISTINCT scan_date) AS unique_date
FROM transactions
GROUP BY receipt_id
HAVING COUNT(DISTINCT scan_date) > 1;

-- check to make sure instances where recept_id is duplicated, unique_barcode is as well.  its NOT
SELECT receipt_id, COUNT(DISTINCT barcode) AS unique_barcode
FROM transactions
GROUP BY receipt_id
HAVING COUNT(DISTINCT barcode) > 1;

SELECT * 
FROM transactions 
WHERE receipt_id IN (
    SELECT receipt_id
    FROM transactions
    GROUP BY receipt_id
    HAVING COUNT(DISTINCT barcode) > 1
)
ORDER BY receipt_id;
-- 1344 roews

SELECT receipt_id, COUNT(*) AS receipt_count


SELECT receipt_id, COUNT(*) AS receipt_count
FROM transactions
WHERE receipt_id IN (
    SELECT receipt_id
    FROM transactions
    GROUP BY receipt_id
    HAVING COUNT(DISTINCT barcode) > 1
)
GROUP BY receipt_id
HAVING COUNT(*) >= 4
ORDER BY receipt_count DESC;


SELECT SUM(receipt_count) AS total_receipt_count
FROM (
    SELECT receipt_id, COUNT(*) AS receipt_count
    FROM transactions
    WHERE receipt_id IN (
        SELECT receipt_id
        FROM transactions
        GROUP BY receipt_id
        HAVING COUNT(DISTINCT barcode) > 1
    )
    GROUP BY receipt_id
    HAVING COUNT(*) >= 4
) AS subquery;
-- 1344

-- looks like there are 2 records created for every item on each receipt.  one bad one good for each barcode on each receipt id

SELECT * FROM transactions where final_quantity <> 'zero' AND final_sale <> ' '
-- exactly half the records seem to have good data

select * from transactions
where receipt_id = '7b3ec72d-9d30-40b8-b185-0bfb638942a9'


select * from transactions where receipt_id in (
SELECT receipt_id FROM transactions where final_quantity <> 'zero' AND final_sale <> ' '
)
order by receipt_id

-- no records with 0 finral quantity.  'zero' seems to be erroneous.
select * from transactions where final_quantity = '0'

-- let's remove it
update transactions
set final_quantity = NULL
where final_quantity = 'zero'

-- same for ' ' in final_sale
select * from transactions where final_sale = ' '

update transactions
set final_sale = NULL
where final_sale = ' '


-- time to delete these bad records

select * into transactions_backup from transactions

--delete from transactions where final_sale IS NULL or final_quantity IS DELETE

