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