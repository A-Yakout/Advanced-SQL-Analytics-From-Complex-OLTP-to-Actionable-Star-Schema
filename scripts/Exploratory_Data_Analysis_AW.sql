-- 1-Exploratory Data Analysis (EDA) 

-- a-Data Base Exploration
SELECT *
FROM INFORMATION_SCHEMA.VIEWS

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customer'

-- b-Dimention Exploration

-- 10 countries
SELECT
	DISTINCT country
FROM dim_territory

-- 17 sales person
SELECT 
	DISTINCT SalesPersonName
FROM dim_sales_person

-- 4 Categories
SELECT 
	DISTINCT category
FROM dim_product

-- 37 sub cateogry
SELECT 
	DISTINCT sub_category
FROM dim_product

-- Gets the full hierarchy of the products
SELECT 
	DISTINCT category, sub_category, product_name
FROM dim_product

-- Exploring products without selected Category
SELECT 
	*
FROM dim_product
WHERE category IS NULL

-- c-Date Exploration
-- orders scope 
SELECT
	MIN(CAST(order_date AS DATE)) as first_order,
	MAX(CAST(order_date AS DATE)) as last_order,
	DATEDIFF(year, MIN(order_date), MAX(order_date)) as orders_years_scope
FROM fact_sales

-- c-Measures Exploration
-- Generating Report of Measures Exploration
SELECT 
	'Total Sales' as measure_name,
	SUM(line_total) as measure_value
FROM fact_sales

UNION ALL 

SELECT
	'Total Orders' as measure_name,
	COUNT(DISTINCT sales_order_id) as measure_value
FROM fact_sales

UNION ALL 

SELECT
	'Total Quantity' as measure_name,
	SUM(order_qty) as measure_value
FROM fact_sales

UNION ALL 

SELECT
	'Average Price' as measure_name,
	AVG(unit_price) as measure_value
FROM fact_sales


SELECT
*
FROM fact_sales


-- e-Magnitude Analysis
-- Distribution of customers across countries
SELECT 
	country,
	COUNT(customer_id) as total_customers
FROM dim_customer c
LEFT JOIN dim_territory t
ON c.territory_id = t.territory_id
GROUP BY country
ORDER BY total_customers DESC

-- Average prices across different categories
SELECT
	category,
	AVG(unit_price) as avg_price
FROM dim_product p 
JOIN fact_sales f 
ON p.product_id = f.product_id
GROUP BY category
ORDER BY avg_price DESC

-- Sales by sales person
SELECT
	SalesPersonName,
	SUM(line_total) as total_sales
FROM dim_sales_person s
LEFT JOIN fact_sales f 
ON s.sales_person_id = f.sales_person_id
GROUP BY SalesPersonName
ORDER BY total_sales DESC

-- Total orders by country
SELECT
	country,
	COUNT(DISTINCT sales_order_id) as total_orders
FROM dim_territory t
LEFT JOIN fact_sales f 
ON t.territory_id = f.territory_id
GROUP BY country
ORDER BY total_orders DESC

-- f-Ranking analysis
-- Finding the top 5 products that make sales
SELECT
	TOP 5
	product_name,
	SUM(line_total) as total_sales
FROM fact_sales f 
LEFT JOIN dim_product p 
ON f.product_id = p.product_id
GROUP BY product_name
ORDER BY total_sales DESC

-- Top 5 countries with units sold
SELECT
	country,
	units_sold
FROM(
SELECT
	country,
	SUM(order_qty) as units_sold,
	RANK() OVER(ORDER BY SUM(order_qty) DESC) AS rnk
FROM dim_territory t 
LEFT JOIN fact_sales f
ON t.territory_id = f.territory_id
GROUP BY country
)t 
WHERE rnk <=5


SELECT
	*
FROM dim_customer 