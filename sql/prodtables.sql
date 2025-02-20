ALTER TABLE users RENAME TO users_staging;


CREATE TABLE users (
    id VARCHAR PRIMARY KEY,
    created_date TIMESTAMP,
    birth_date TIMESTAMP NULL,
    state VARCHAR,
    language VARCHAR,
    gender VARCHAR
);


INSERT INTO users (id, created_date, birth_date, state, language, gender)
SELECT id, created_date, birth_date, state, language, gender
FROM users_staging;




ALTER TABLE products RENAME TO products_staging;

CREATE TABLE products (
    category_1 VARCHAR,
    category_2 VARCHAR,
    category_3 VARCHAR,
    category_4 VARCHAR,
    manufacturer VARCHAR,
    brand VARCHAR,
    barcode BIGINT PRIMARY KEY
);

INSERT INTO products (category_1, category_2, category_3, category_4, manufacturer, brand, barcode)
SELECT category_1, category_2, category_3, category_4, manufacturer, brand, barcode
FROM products_staging
WHERE barcode IS NOT NULL;



ALTER TABLE transactions RENAME TO transactions_staging;

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,  -- Auto-incrementing unique ID
    receipt_id VARCHAR,                 -- Receipt ID (not unique)
    purchase_date TIMESTAMP,
    scan_date TIMESTAMP,
    store_name VARCHAR,
    user_id VARCHAR,
    barcode BIGINT,
    quantity NUMERIC,
    sale NUMERIC
);


INSERT INTO transactions (receipt_id, purchase_date, scan_date, store_name, user_id, barcode, quantity, sale)
SELECT receipt_id, purchase_date, scan_date, store_name, user_id, barcode, final_quantity::NUMERIC, final_sale::NUMERIC
FROM transactions_staging;


ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_users
FOREIGN KEY (user_id) 
REFERENCES users(id)
ON DELETE CASCADE;

select * from transactions where user_id = '60fc1e6deb7585430ff52ee7'

select * from users where id = '60fc1e6deb7585430ff52ee7'

-- ok some user_ids do not exist in users, so we cannot add this foreign key

SELECT *
FROM transactions t
LEFT JOIN users u ON t.user_id = u.id
WHERE u.id IS NULL;

-- this is too many, I'm not going to add dummy users for this or delete records to enforce the foreign key
select count(*) from transactions
where user_id not in (select id from users)



SELECT DISTINCT t.barcode
FROM transactions t
LEFT JOIN products p ON t.barcode = p.barcode
WHERE p.barcode IS NULL;


ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_products
FOREIGN KEY (barcode) 
REFERENCES products(barcode)
ON DELETE CASCADE;


-- same problem.  there are too many that don't match up.  We aren't going to add any foreign keys for this data.

