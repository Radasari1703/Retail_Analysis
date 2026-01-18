-- BRONZE LAYER: Staging Tables Setup
-- Goal: 1. Create empty tables (buckets) for the raw data.
--       2. Load the data from the CSV files into these tables.
-- Author: Ramprasan Dasari

-- =======================================================
-- PART 1: Create the Empty Buckets (Staging Tables)
-- =======================================================

-- 1. Staging for Customers
-- Matches columns in Customer.csv
CREATE TABLE Raw_Staging_Customers (
    customer_Id VARCHAR(50), 
    DOB VARCHAR(50), 
    Gender VARCHAR(50), 
    city_code VARCHAR(50)
);

-- 2. Staging for Product Categories
-- Matches columns in prod_cat_info.csv
CREATE TABLE Raw_Staging_Prod_Cat (
    prod_cat_code VARCHAR(50),
    prod_cat VARCHAR(50),
    prod_sub_cat_code VARCHAR(50),
    prod_subcat VARCHAR(50)
);

-- 3. Staging for Transactions
-- Matches columns in Transactions.csv
CREATE TABLE Raw_Staging_Transactions (
    transaction_id VARCHAR(50),
    cust_id VARCHAR(50),
    tran_date VARCHAR(50),
    prod_subcat_code VARCHAR(50),
    prod_cat_code VARCHAR(50),
    Qty VARCHAR(50),
    Rate VARCHAR(50),
    Tax VARCHAR(50),
    total_amt VARCHAR(50),
    Store_type VARCHAR(50)
);

-- =======================================================
-- PART 2: The Load Process (The Bridge)
-- =======================================================
-- Note: These paths assume you have cloned the repo to your C: drive.
-- If you run this on your laptop, change 'C:\Retail_Analysis' to your actual download folder.

-- Load Customers
BULK INSERT Raw_Staging_Customers
FROM 'C:\Retail_Analysis\Data\Customer.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

-- Load Product Info
BULK INSERT Raw_Staging_Prod_Cat
FROM 'C:\Retail_Analysis\Data\prod_cat_info.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

-- Load Transactions
BULK INSERT Raw_Staging_Transactions
FROM 'C:\Retail_Analysis\Data\Transactions.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);
