# Fetch Data Analyst Take-Home Assignment

## 1. Data Exploration

The provided dataset consists of three CSV files:

- **transactions.csv** (Receipt-level purchase data)
- **users.csv** (User demographic and account details)
- **products.csv** (Product metadata)

## Data Quality Issues

### Transactions Data

During the initial exploration, we identified several data quality issues:

- **Duplicate `receipt_id`s** exist, indicating multiple rows per transaction.
- **`barcode` column** has 5,762 missing values, affecting product mapping.
- **`FINAL_QUANTITY`** includes values labeled as "zero", which requires clarification.
- **`FINAL_SALE`** has many records with blank spaces (' '), which could indicate missing values, refunds, or errors.

### Users Data

- **`birth_date`** is missing for 3,675 users, making age-based analysis incomplete.
- **`state`, `language`, and `gender`** have substantial missing values, impacting segmentation.
- **`language`** has only two unique values (`en`, `es-419`), which seems limited.
- **Inconsistent values** in the `gender` column, requiring standardization.
- **Some users have an age over 120**, which seems implausible and may be due to placeholder or incorrect data.

### Products Data

- **Duplicate `barcode`s** exist, but associated product details differ (e.g., different brands/manufacturers).
- **`CATEGORY_4`** is missing for 778,093 products, limiting product classification depth.
- **`MANUFACTURER` and `BRAND`** have over 226,000 missing values, making brand-level analysis difficult.
- **Placeholder values found in manufacturer and brand fields:**
  - "PLACEHOLDER MANUFACTURER" in the `manufacturer` column.
  - "BRAND NOT KNOWN" and "BRAND NEEDS REVIEW" in the `brand` column.
- This suggests data gaps or incomplete ingestion, making it difficult to analyze brand-level sales.

## Fields That Are Challenging to Understand

### `FINAL_QUANTITY` in Transactions

- Some values are "zero", which could indicate returns, voided items, or bad data.
- Needs clarification from Fetch on whether these should be excluded.

### `SCAN_DATE` vs. `PURCHASE_DATE`

- `SCAN_DATE` is sometimes after `PURCHASE_DATE`, implying manual receipt submission rather than real-time scanning.
- This affects time-based analyses (e.g., user activity trends).

### `barcode` Inconsistencies

- The same barcode appears with different brands/manufacturers in `products.csv`, making brand mapping unreliable.
