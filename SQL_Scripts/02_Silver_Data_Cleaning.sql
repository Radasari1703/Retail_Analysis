-- SILVER LAYER: Data Cleaning & Transformation Script
-- Goal: Populate the core tables with clean data from raw staging
-- Author: Ramprasan Dasari

-- ====================================================================
-- 1. Clean & Populate Customers
-- ====================================================================
-- Logic: 
-- 1. Handle Metadata format dates (dd-mm-yyyy) using CONVERT(105)
-- 2. Replace NULL Gender with 'U' (Unknown)
-- 3. Standardize City Codes

INSERT INTO Customers (customer_Id, DOB, Gender, city_code)
SELECT 
    customer_Id,
    -- Convert '28-02-2014' string to SQL Date format
    CONVERT(DATE, DOB, 105) AS DOB, 
    -- Handle missing gender info
    CASE 
        WHEN Gender IS NULL OR Gender = '' THEN 'U' 
        ELSE Gender 
    END AS Gender,
    ISNULL(city_code, 0) -- Default city code 0 if missing
FROM Raw_Staging_Customers; -- (Assuming raw data is loaded here temporarily)


-- ====================================================================
-- 2. Clean & Populate Product Categories
-- ====================================================================
-- Logic: Simple insert, ensuring no duplicates on the composite key

INSERT INTO Product_Categories (prod_cat_code, prod_cat, prod_sub_cat_code, prod_subcat)
SELECT DISTINCT
    prod_cat_code,
    prod_cat,
    prod_sub_cat_code,
    prod_subcat
FROM Raw_Staging_Prod_Cat;


-- ====================================================================
-- 3. Clean & Populate Transactions
-- ====================================================================
-- Logic:
-- 1. Convert Transaction Date
-- 2. Calculate Net Sales (ensure no bad math data)
-- 3. Filter out orphan transactions (where customer doesn't exist)

INSERT INTO Transactions (transaction_id, cust_id, tran_date, prod_subcat_code, prod_cat_code, Qty, Rate, Tax, total_amt, Store_type)
SELECT 
    transaction_id,
    cust_id,
    CONVERT(DATE, tran_date, 105) AS tran_date,
    prod_subcat_code,
    prod_cat_code,
    Qty,
    Rate,
    Tax,
    total_amt,
    Store_type
FROM Raw_Staging_Transactions t
WHERE EXISTS (
    -- Data Integrity Check: Only load transactions for valid customers
    SELECT 1 FROM Customers c WHERE c.customer_Id = t.cust_id
);
