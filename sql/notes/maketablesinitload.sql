CREATE TABLE transactions (
    receipt_id TEXT PRIMARY KEY,
    purchase_date DATE,
    scan_date TIMESTAMP,
    store_name TEXT,
    user_id TEXT,
    barcode BIGINT,
    final_quantity TEXT,
    final_sale TEXT
);


CREATE TABLE users (
    id TEXT PRIMARY KEY,
    created_date TIMESTAMP,
    birth_date TIMESTAMP NULL,
    state TEXT,
    language TEXT,
    gender TEXT
);

COPY users(id, created_date, birth_date, state, language, gender)
FROM '/Users/bleezy/repos/data-analyst-fetch/input/USER_TAKEHOME.csv'
DELIMITER ',' CSV HEADER;


CREATE TABLE products (
    category_1 TEXT,
    category_2 TEXT,
    category_3 TEXT,
    category_4 TEXT,
    manufacturer TEXT,
    brand TEXT,
    barcode BIGINT
);


COPY products(category_1, category_2, category_3, category_4, manufacturer, brand, barcode)
FROM '/Users/bleezy/repos/data-analyst-fetch/input/PRODUCTS_TAKEHOME.csv'
DELIMITER ',' CSV HEADER;
