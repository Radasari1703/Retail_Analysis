-- DDL Script to set up the Retail Database Schema
-- Author: Ramprasan Dasari
-- Project: Retail Analysis Pipeline

-- 1. Customer Dimension Table
-- Holds static details about our customers
CREATE TABLE Customers (
    customer_Id INT PRIMARY KEY, -- Unique ID for every customer
    DOB DATE,                    -- Date of Birth
    Gender VARCHAR(1),           -- M or F
    city_code INT
);

-- 2. Product Category Dimension Table
-- Holds the hierarchy of product categories (e.g., Clothing -> Mens)
CREATE TABLE Product_Categories (
    prod_cat_code INT,
    prod_cat VARCHAR(50),
    prod_sub_cat_code INT,
    prod_subcat VARCHAR(50),
    -- Composite Primary Key: We need both codes to identify a unique subcategory
    CONSTRAINT PK_Product_Categories PRIMARY KEY (prod_cat_code, prod_sub_cat_code)
);

-- 3. Transactions Fact Table
-- The central table recording all sales events
CREATE TABLE Transactions (
    transaction_id BIGINT,      -- Using BigInt as transaction IDs can be huge
    cust_id INT,
    tran_date DATE,             -- Transaction Date
    prod_subcat_code INT,
    prod_cat_code INT,
    Qty INT,                    -- Negative values indicate returns
    Rate DECIMAL(10,2),         -- Price per unit
    Tax DECIMAL(10,2),
    total_amt DECIMAL(10,2),    -- Final amount after tax
    Store_type VARCHAR(50),     -- e.g., e-Shop, Flagship store
    -- Foreign Key: Ensures we only record transactions for existing customers
    CONSTRAINT FK_Transactions_Customers FOREIGN KEY (cust_id) REFERENCES Customers(customer_Id)
);
