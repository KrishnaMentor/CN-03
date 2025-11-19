CREATE DATABASE Ecommerce;

USE Ecommerce;

DESC customers_india_adjusted;
DESC order_details_india_adjusted;
DESC orders_india_adjusted;
DESC products_india_adjusted;

-- DDL [Data Definition Language] -> Changes the Structure
ALTER TABLE customers_india_adjusted
RENAME TO Customers;

ALTER TABLE order_details_india_adjusted
RENAME TO Order_Details;

ALTER TABLE orders_india_adjusted
RENAME TO Orders;

ALTER TABLE products_india_adjusted
RENAME TO Products;

-- Understanding the Data ........ [ERD] 
SELECT * FROM Customers; -- Dimension Table[1]
SELECT * FROM Products; -- Dimension Table[1]
SELECT * FROM Order_Details; -- Fact Table[F.K][*]
SELECT * FROM Orders; -- Fact Table [Customer Key -> F.K] [*]
/* 
	1:M Cardinality 
    M:1 Cardinality
    M:N Cardinality -> 10 record * 100 records -> 1000 records[Duplicates]
    1:1 Cardinality
*/

SELECT * FROM Customers;

SELECT
	Location,
    COUNT(*) AS number_of_customers
FROM Customers
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- Challenge2 : CTE 
WITH CustomersOrders AS (
	SELECT 
		Customer_id,
        COUNT(Order_id) AS NumberOfOrders
	FROM Orders
    GROUP BY 1
)
SELECT 
	NumberOfOrders,
    COUNT(*) AS CustomerCount
FROM CustomersOrders
GROUP BY 1
ORDER BY 1;

-- Challenge 3 : Purchase High Value Products 
SELECT * FROM Order_Details;

SELECT
	Product_id,
    AVG(quantity) AS AvgQuantity,
    SUM(quantity * price_per_unit) AS TotalRevenue
FROM Order_details
GROUP BY Product_id
HAVING AvgQuantity = 2
ORDER BY TotalRevenue DESC;

-- Challenge 4 : Category_Wise Customers Reach

SELECT
	p.Category,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM Products p
JOIN Order_Details od
ON p.product_id = od.product_id 
JOIN Orders o
ON o.order_id = od.order_id
GROUP BY 1
ORDER BY 2 DESC;

-- Challenge 5 : Sales Trend Analysis 
USE Ecommerce;
SELECT * FROM Orders; -- YYYY-MM-DD [SQL Pattern]
-- 22/05/2021 -> dd/mm/yyyy -> %d/%m/%Y
DESC Orders;

With MonthlySales AS (
	SELECT
		DATE_FORMAT(order_date , '%Y-%m') AS Month,
        SUM(total_amount) AS TotalSales
	FROM Orders
    GROUP BY Month
    ORDER BY Month
)
SELECT 
	Month,
	TotalSales,
    ROUND((TotalSales - LAG(TotalSales) OVER(ORDER BY Month)) /
    (LAG(TotalSales) OVER(ORDER BY Month)) * 100 ,2) AS PercentChange
FROM MonthlySales;

-- Challenge 6 : Average Order Value Fluctuations

With MonthlyOrderValues AS (
	SELECT
		DATE_FORMAT(order_date , '%Y-%m') AS Month,
        ROUND(AVG(total_amount),2) AS AvgOrderValue
	FROM Orders
    GROUP BY Month
    ORDER BY Month
)
SELECT 
	Month,
	AvgOrderValue,
    ROUND(AvgOrderValue - LAG(AvgOrderValue) OVER(ORDER BY Month),2) AS ChangeInValue
FROM MonthlyOrderValues
ORDER BY ChangeInValue DESC;


/*
 It's a multiline Comment ... .
 You can hide all the important message here....
*/

-- Challenge 7 - Inventory Refresh Rate

SELECT * FROM Order_Details;

SELECT 
	Product_id,
    COUNT(order_id) AS SalesFrequency
FROM Order_Details
GROUP BY Product_id
ORDER BY SalesFrequency DESC
LIMIT 5;

-- Challenge 8 - Low Engagement Products

SELECT
	p.Product_id,
    p.Name,
    COUNT(DISTINCT o.customer_id) AS UniqueCustomerCount
FROM Products p
JOIN Order_Details od
ON p.Product_id = od.Product_id
JOIN Orders o
ON o.order_id = od.order_id 
GROUP BY p.Product_id,p.Name
HAVING UniqueCustomerCount < 40;

-- Error Code: 1052. Column 'Product_id' in field list is ambiguous


-- Challenge 9 - Customer Acquisitions Trends

SELECT * From Orders;

SELECT
	Customer_id,
    DATE_FORMAT(min(order_date) , '%Y-%m') AS FirstPurchaseMonth,
    COUNT(DISTINCT Customer_id) AS TotalNewCustomers
FROM Orders
GROUP BY Customer_id;

SELECT * From Orders;

-- Challenge 9 - Customer Acquisitions Trends
WITH MonthlyNewCustomers AS (
	SELECT
		Customer_id,
		DATE_FORMAT(min(order_date) , '%Y-%m') AS FirstPurchaseMonth,
		COUNT(DISTINCT Customer_id) AS TotalNewCustomers
	FROM Orders
	GROUP BY Customer_id
)
SELECT
	FirstPurchaseMonth,
    SUM(TotalNewCustomers) AS TotalNewCustomers
FROM MonthlyNewCustomers 
GROUP BY FirstPurchaseMonth
ORDER BY FirstPurchaseMonth ASC;

-- Challenge 10 - Peak Sales Period Identification

SELECT * FROM Orders;

SELECT
	DATE_FORMAT(order_date , '%Y-%m') AS Month,
    SUM(total_amount) AS TotalSales
FROM Orders
GROUP BY Month 
ORDER BY TotalSales DESC 
LIMIT 3;