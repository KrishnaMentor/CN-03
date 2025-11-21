-- CTE [Common Table Expression] 
USE bike_analysis;

-- Challenge : ProductPrice > AvgProductPrice within their Subcategory

SELECT * FROM Products;

With AvgProductSubcategory AS (
	SELECT
		ProductSubcategoryKey,
        ROUND(AVG(ProductPrice),0) AS AvgPrice
	FROM Products
    GROUP BY 1
)
SELECT * FROM AvgProductSubcategory;

SELECT 
	ProductKey,
    ProductSubcategoryKey,
    ProductName,
    ProductPrice
FROM Products WHERE ProductSubcategoryKey = 1;

With AvgProductSubcategory AS (
	SELECT
		ProductSubcategoryKey,
        ROUND(AVG(ProductPrice),0) AS AvgPrice
	FROM Products
    GROUP BY 1
)
SELECT
	p.ProductSubcategoryKey
	ProductKey,
    ProductName,
    ProductPrice,
    AvgPrice
FROM Products p 
JOIN AvgProductSubcategory a
ON a.ProductSubcategoryKey = p.ProductSubcategoryKey
WHERE ProductPrice > AvgPrice
ORDER BY p.ProductSubcategoryKey;

-- Challenge 2 : Find the TotalReturns & TotalRevenue for each Cateogries
-- using Multiple CTEs.....

WITH CategoryReturns AS(
	SELECT
		pc.CategoryName,
		SUM(ReturnQuantity) AS TotalReturns
	FROM `Product-Categories` pc
    JOIN `Product-Subcategories` ps
    ON pc.ProductCategoryKey = ps.ProductCategoryKey
    JOIN Products p 
    ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
    JOIN Returns r 
    ON p.ProductKey = r.productKey
    GROUP BY 1
)
SELECT * FROM CategoryReturns;

WITH CategoryRevenue AS(
	SELECT
		pc.CategoryName,
		ROUND(SUM(p.ProductPrice * s.OrderQuantity),0) AS TotalRevenue
	FROM `Product-Categories` pc
    JOIN `Product-Subcategories` ps
    ON pc.ProductCategoryKey = ps.ProductCategoryKey
    JOIN Products p 
    ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
    JOIN `Sales-2017` s
    ON p.ProductKey = s.productKey
    GROUP BY 1
)
SELECT * FROM CategoryRevenue;

-- Finalizing the above 2 separate CTE.

WITH CategoryReturns AS(
	SELECT
		pc.CategoryName,
		SUM(ReturnQuantity) AS TotalReturns
	FROM `Product-Categories` pc
    JOIN `Product-Subcategories` ps
    ON pc.ProductCategoryKey = ps.ProductCategoryKey
    JOIN Products p 
    ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
    JOIN Returns r 
    ON p.ProductKey = r.productKey
    GROUP BY 1
),
CategorySales AS(
	SELECT
		pc.CategoryName,
		ROUND(SUM(p.ProductPrice * s.OrderQuantity),0) AS TotalRevenue
	FROM `Product-Categories` pc
    JOIN `Product-Subcategories` ps
    ON pc.ProductCategoryKey = ps.ProductCategoryKey
    JOIN Products p 
    ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
    JOIN `Sales-2017` s
    ON p.ProductKey = s.productKey
    GROUP BY 1
)
SELECT 
	cr.CategoryName,
    TotalReturns,
    TotalRevenue
FROM CategoryReturns cr
JOIN CategorySales cs
ON cr.CategoryName = cs.CategoryName
ORDER BY TotalRevenue DESC;

-- Let's add AllSales CTE for referencing Sales of 2015/16/17.
-- Union [Removes Duplicates While Appending] VS Union ALL [Just Append identical table]
WITH AllSales AS(
	SELECT * FROM `Sales-2015`
    UNION ALL 
	SELECT * FROM `Sales-2016`
    UNION ALL
	SELECT * FROM `Sales-2017`
),
CategoryReturns AS(
	SELECT
		pc.CategoryName,
		SUM(ReturnQuantity) AS TotalReturns
	FROM `Product-Categories` pc
    JOIN `Product-Subcategories` ps
    ON pc.ProductCategoryKey = ps.ProductCategoryKey
    JOIN Products p 
    ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
    JOIN Returns r 
    ON p.ProductKey = r.productKey
    GROUP BY 1
),
CategorySales AS(
	SELECT
		pc.CategoryName,
		ROUND(SUM(p.ProductPrice * s.OrderQuantity),0) AS TotalRevenue
	FROM `Product-Categories` pc
    JOIN `Product-Subcategories` ps
    ON pc.ProductCategoryKey = ps.ProductCategoryKey
    JOIN Products p 
    ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
    JOIN AllSales s
    ON p.ProductKey = s.productKey
    GROUP BY 1
)
SELECT 
	cr.CategoryName,
    TotalReturns,
    TotalRevenue
FROM CategoryReturns cr
JOIN CategorySales cs
ON cr.CategoryName = cs.CategoryName
ORDER BY TotalRevenue DESC;

-- ========================== WINDOW FUNCTIONS ==========================

USE Weekend_Analysis;
SELECT * FROM Sale;

/*
SELECT 
  window_function(...) OVER (
    PARTITION BY column_name
    ORDER BY column_name
    ROWS/RANGE ...
  ) AS result_column
FROM table_name;
*/
-- Challenge 1 : Find the Cumulative TotalSales by SalesPerson
SELECT DISTINCT SalesPerson FROM Sale;

SELECT
	*,
    SUM(SaleAmount) OVER(
		PARTITION BY SalesPerson
        ORDER BY SaleDate
    ) AS CumulativeSalesPerPerson
FROM Sale;

-- Challenge 2 : Rank the SalesPerson by SaleAmount
SELECT
	*,
    RANK() OVER(
		ORDER BY SaleAmount DESC
	) AS SalesRank
FROM Sale;

-- Challenge 2 : Rank the SalesPerson by SaleAmount
SELECT
	*,
    DENSE_RANK() OVER(
		ORDER BY SaleAmount DESC
	) AS SalesRank
FROM Sale;

-- =============== Moving Average - 3 days ==========

-- Challenge 3 : Find the 3 days Moving Average Sales

SELECT 
	*,
    AVG(SaleAmount) OVER(
		ORDER BY SaleDate
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS MovingAverage
FROM Sale;