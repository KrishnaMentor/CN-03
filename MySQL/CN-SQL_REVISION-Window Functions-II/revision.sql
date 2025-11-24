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

-- ================= MAX() Window Function ======================
USE Bike_Analysis;

SELECT * FROM Customers;
-- Find the Maximum AnnualIncome based on EducationLevel & Occupation?

SELECT DISTINCT EducationLevel FROM Customers;
SELECT DISTINCT Occupation FROM Customers;

SELECT DISTINCT EducationLevel,Occupation FROM Customers; -- 25 row(s) returned

SELECT
	CustomerKey,
    FullName,
    EducationLevel,
    Occupation,
    AnnualIncome,
    MAX(AnnualIncome) OVER(
		PARTITION BY EducationLevel , Occupation
	) AS Max_income_by_edu_occ
FROM Customers;

-- ROW_NUMBER() 
SELECT
	CustomerKey,
    FullName,
    EducationLevel,
    Occupation,
    AnnualIncome,
    ROW_NUMBER() OVER(
		PARTITION BY EducationLevel , Occupation
        ORDER BY AnnualIncome DESC
	) AS Row_Index
FROM Customers;


-- LEAD [Next Sale] and LAG [Past Sale]
USE Weekend_analysis;
DESC Sale;

SELECT
	*,
    LAG(SaleAmount) OVER(PARTITION BY Salesperson ORDER BY SaleDate) AS PreviousSale,
    LEAD(SaleAmount) OVER(PARTITION BY Salesperson ORDER BY SaleDate) AS NextSale
FROM Sale;

-- Challenge : 1 - Find the PreviousMonthRevenue and NextMonthRevenue FROM Sales2015.
SELECT * FROM Sales2015;

DESC Sales2015;

SELECT
	DATE_FORMAT(s.OrderDate , '%Y-%m') AS YearMonth,
    ROUND(SUM(p.ProductPrice * s.OrderQuantity),0) AS TotalRevenue,
    
    LAG(ROUND(SUM(p.ProductPrice * s.OrderQuantity),0))
    OVER(ORDER BY DATE_FORMAT(s.OrderDate , '%Y-%m')) AS PreviousMonthRevenue,
    
	LEAD(ROUND(SUM(p.ProductPrice * s.OrderQuantity),0))
    OVER(ORDER BY DATE_FORMAT(s.OrderDate , '%Y-%m')) AS NextMonthRevenue

FROM Sales2015 s
JOIN Products p
ON p.ProductKey = s.ProductKey
GROUP BY 1;
    
-- ===================  NTILE() ================
-- NTILE(Number Of Buckets) OVER(ORDER BY Columns)

SELECT * FROM Products;

SELECT ProductName, ProductPrice FROM Products
ORDER BY 2; -- 295 / 4 -> 73/74

SELECT
	ProductName,
    ProductPrice,
    NTILE(4) OVER(ORDER BY ProductPrice) As Price_Quartile
FROM Products;


-- ===================== First_value() ======================
-- Find the Customers who purchased each products based on the earliest date....

SELECT * FROM Sales2015;

SELECT
	s.ProductKey,
    c.FullName,
    s.OrderDate,
    FIRST_VALUE(c.FullName) OVER (PARTITION BY s.ProductKey  ORDER BY s.OrderDate) 
    AS FirstPurchase
FROM Sales2015 s
JOIN Customers c
ON c.CustomerKey = s.CustomerKey;


-- -- ===================== Last_value() ======================
-- Find the Last Region where each products were sold based on the Latest OrderDate....

SELECT
	s.ProductKey,
    t.Region,
    s.OrderDate,
    LAST_VALUE(t.Region) OVER (PARTITION BY s.ProductKey  ORDER BY s.OrderDate
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_region_product_sold
FROM Sales2015 s
JOIN Territories t
ON t.SalesTerritoryKey = s.TerritoryKey;


-- ===================== Nth_value() ======================
-- Find the 5th Customers who purchased each products based on the earliest date....

SELECT * FROM Sales2015;

SELECT
	s.ProductKey,
    c.FullName,
    s.OrderDate,
    NTH_VALUE(c.FullName , 5) OVER (PARTITION BY s.ProductKey  ORDER BY s.OrderDate
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS FifthPurchaser
FROM Sales2015 s
JOIN Customers c
ON c.CustomerKey = s.CustomerKey;


-- Challenge : 
-- Find the Products which are either below the lower bound[Low Outlier] and above the upper bound[High Outlier]

-- Outlier Detection [High Outliers] [Positive Skewed]

WITH Product_Stats AS(
	SELECT 
		ProductPrice,
        NTILE(4) OVER (ORDER BY ProductPrice) AS Price_quartile
	FROM Products
),
Quartiles AS (
	SELECT 
		MAX(CASE WHEN Price_quartile = 1 THEN ProductPrice END) AS Q1,
		MAX(CASE WHEN Price_quartile = 3 THEN ProductPrice END) AS Q3
	FROM Product_Stats
),
iqr_bounds AS(
	SELECT
		Q1,
        Q3,
        Q3 - Q1 AS IQR,
        Q1 - (1.5 * (Q3 - Q1)) AS Lower_Bound,
        Q3 + (1.5 * (Q3 - Q1)) AS Upper_Bound
	FROM Quartiles
)
SELECT
	p.ProductKey,
    p.ProductName,
    p.ProductPrice
FROM Products p
JOIN iqr_bounds iqr
ON p.ProductPrice < iqr.Lower_Bound OR p.ProductPrice > iqr.Upper_Bound
ORDER BY ProductPrice; -- 18 row(s) returned
