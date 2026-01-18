-- GOLD LAYER: Business Views & Key Performance Indicators (KPIs)
-- Goal: Create "Virtual Tables" (Views) for Power BI/Tableau reporting
-- Author: Ramprasan Dasari

-- ====================================================================
-- 1. VIEW: Total Sales by Month (Trend Analysis)
-- ====================================================================
-- Why? The business needs to see if we are growing or shrinking over time.
CREATE VIEW v_Monthly_Sales_Trend AS
SELECT 
    YEAR(tran_date) AS Year,
    MONTH(tran_date) AS Month,
    FORMAT(tran_date, 'MMM-yyyy') AS Month_Name, -- e.g., "Jan-2014"
    SUM(total_amt) AS Net_Revenue,               -- Total Money Made
    COUNT(transaction_id) AS Total_Transactions
FROM Transactions
WHERE total_amt > 0 -- We only look at valid sales here, not returns
GROUP BY YEAR(tran_date), MONTH(tran_date), FORMAT(tran_date, 'MMM-yyyy');

-- ====================================================================
-- 2. VIEW: Product Category Performance
-- ====================================================================
-- Why? To identify our best-selling and worst-selling categories.
CREATE VIEW v_Product_Performance AS
SELECT 
    p.prod_cat AS Category,
    p.prod_subcat AS Sub_Category,
    SUM(t.Qty) AS Total_Quantity_Sold,
    SUM(t.total_amt) AS Total_Revenue,
    AVG(t.total_amt) AS Avg_Transaction_Value
FROM Transactions t
JOIN Product_Categories p 
    ON t.prod_cat_code = p.prod_cat_code 
    AND t.prod_sub_cat_code = p.prod_sub_cat_code
GROUP BY p.prod_cat, p.prod_subcat;

-- ====================================================================
-- 3. VIEW: Customer Demographics (Who is buying?)
-- ====================================================================
-- Why? Marketing wants to know who our target audience is.
CREATE VIEW v_Customer_Demographics AS
SELECT 
    c.Gender,
    c.city_code,
    COUNT(DISTINCT t.cust_id) AS Active_Customers,
    SUM(t.total_amt) AS Total_Spent
FROM Transactions t
JOIN Customers c ON t.cust_id = c.customer_Id
WHERE t.total_amt > 0
GROUP BY c.Gender, c.city_code;

-- ====================================================================
-- 4. VIEW: Return Rate Analysis
-- ====================================================================
-- Why? Returns lose money. We need to track how often items come back.
CREATE VIEW v_Return_Analysis AS
SELECT 
    p.prod_cat AS Category,
    COUNT(CASE WHEN t.Qty < 0 THEN 1 END) AS Returned_Items_Count,
    ABS(SUM(CASE WHEN t.total_amt < 0 THEN t.total_amt ELSE 0 END)) AS Total_Refund_Value
FROM Transactions t
JOIN Product_Categories p ON t.prod_cat_code = p.prod_cat_code
GROUP BY p.prod_cat;
