-- GOLD LAYER: Business Views & Key Performance Indicators (KPIs)
-- Author: Ramprasan Dasari
-- Contents: 
-- 1. Sales Trend (Time Series)
-- 2. Category Performance (Aggregations)
-- 3. Demographics (Customer Info)
-- 4. Gender Pivot (Matrix/Cross-Tab)
-- 5. Return Analysis (Loss Prevention)
-- 6. Customer Risk Flag (Logic-Based Classification)

-- ====================================================================
-- 1. VIEW: Monthly Sales Trend
-- ====================================================================
CREATE OR ALTER VIEW v_Monthly_Sales_Trend AS
SELECT 
    YEAR(tran_date) AS Year_of_Trans,
    MONTH(tran_date) AS Month_of_Trans,
    FORMAT(tran_date, 'MMM-yyyy') AS Month_Name,
    SUM(total_amt) AS Total_Revenue,
    COUNT(transaction_id) AS Total_Transactions
FROM Transactions
WHERE total_amt > 0 
GROUP BY YEAR(tran_date), MONTH(tran_date), FORMAT(tran_date, 'MMM-yyyy');
GO

-- ====================================================================
-- 2. VIEW: Category Performance
-- ====================================================================
CREATE OR ALTER VIEW v_Category_Performance AS
SELECT 
    p.prod_cat AS Category_Name,
    SUM(t.total_amt) AS Total_Revenue,
    SUM(t.Qty) AS Total_Units_Sold
FROM Transactions t
JOIN Product_Categories p 
    ON t.prod_cat_code = p.prod_cat_code 
    AND t.prod_subcat_code = p.prod_sub_cat_code 
WHERE t.total_amt > 0 
GROUP BY p.prod_cat;
GO

-- ====================================================================
-- 3. VIEW: Customer Demographics
-- ====================================================================
CREATE OR ALTER VIEW v_Customer_Demographics AS
SELECT 
    c.Gender,
    COUNT(DISTINCT t.cust_id) AS Unique_Customers,
    SUM(t.total_amt) AS Total_Spent
FROM Transactions t
JOIN Customers c ON t.cust_id = c.customer_Id
WHERE t.total_amt > 0
GROUP BY c.Gender;
GO

-- ====================================================================
-- 4. VIEW: Gender Purchase Pivot (Matrix)
-- ====================================================================
CREATE OR ALTER VIEW v_Category_By_Gender_Pivot AS
SELECT 
    p.prod_cat AS Category_Name,
    SUM(CASE WHEN c.Gender = 'M' THEN t.total_amt ELSE 0 END) AS Male_Sales,
    SUM(CASE WHEN c.Gender = 'F' THEN t.total_amt ELSE 0 END) AS Female_Sales
FROM Transactions t
JOIN Customers c ON t.cust_id = c.customer_Id
JOIN Product_Categories p 
    ON t.prod_cat_code = p.prod_cat_code 
    AND t.prod_subcat_code = p.prod_sub_cat_code
WHERE t.total_amt > 0
GROUP BY p.prod_cat;
GO

-- ====================================================================
-- 5. VIEW: Return Rate Analysis (Bad Products)
-- ====================================================================
CREATE OR ALTER VIEW v_Category_Return_Analysis AS
SELECT 
    p.prod_cat AS Category_Name,
    SUM(CASE WHEN t.total_amt > 0 THEN t.total_amt ELSE 0 END) AS Total_Sales_Value,
    ABS(SUM(CASE WHEN t.total_amt < 0 THEN t.total_amt ELSE 0 END)) AS Total_Returned_Value,
    CAST(
        (ABS(SUM(CASE WHEN t.total_amt < 0 THEN t.total_amt ELSE 0 END)) * 1.0) / 
        NULLIF(SUM(CASE WHEN t.total_amt > 0 THEN t.total_amt ELSE 0 END), 0) * 100
    AS DECIMAL(10,2)) AS Return_Rate_Percent
FROM Transactions t
JOIN Product_Categories p 
    ON t.prod_cat_code = p.prod_cat_code 
    AND t.prod_subcat_code = p.prod_sub_cat_code
GROUP BY p.prod_cat;
GO

-- ====================================================================
-- 6. VIEW: High Risk Customers (Bad Actors)
-- ====================================================================
CREATE OR ALTER VIEW v_High_Return_Customers AS
SELECT 
    c.customer_Id,
    c.Gender,
    COUNT(CASE WHEN t.total_amt > 0 THEN 1 END) AS Total_Purchases,
    COUNT(CASE WHEN t.total_amt < 0 THEN 1 END) AS Total_Returns,
    SUM(t.total_amt) AS Net_Revenue,
    -- Return % Capped at 100%
    CASE 
        WHEN COUNT(CASE WHEN t.total_amt < 0 THEN 1 END) > COUNT(CASE WHEN t.total_amt > 0 THEN 1 END) THEN 100.00
        ELSE CAST((COUNT(CASE WHEN t.total_amt < 0 THEN 1 END) * 1.0) / NULLIF(COUNT(CASE WHEN t.total_amt > 0 THEN 1 END), 0) * 100 AS DECIMAL(10,2))
    END AS Return_Percent,
    -- Risk Flag
    CASE 
        WHEN COUNT(CASE WHEN t.total_amt > 0 THEN 1 END) = 0 THEN 'Legacy Returner (Pre-Data)'
        WHEN COUNT(CASE WHEN t.total_amt < 0 THEN 1 END) > COUNT(CASE WHEN t.total_amt > 0 THEN 1 END) THEN 'High Risk - Net Negative'
        WHEN (COUNT(CASE WHEN t.total_amt < 0 THEN 1 END) * 1.0) / NULLIF(COUNT(CASE WHEN t.total_amt > 0 THEN 1 END), 0) >= 0.8 THEN 'High Risk - Serial Returner'
        WHEN (COUNT(CASE WHEN t.total_amt < 0 THEN 1 END) * 1.0) / NULLIF(COUNT(CASE WHEN t.total_amt > 0 THEN 1 END), 0) > 0.5 THEN 'Medium Risk'
        ELSE 'Low Risk' 
    END AS Risk_Flag
FROM Transactions t
JOIN Customers c ON t.cust_id = c.customer_Id
GROUP BY c.customer_Id, c.Gender
HAVING COUNT(*) > 3;
GO
