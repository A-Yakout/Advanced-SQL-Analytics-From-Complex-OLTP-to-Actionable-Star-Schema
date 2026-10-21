-- 2-Advanced Analytics

-- a-Change Over Time
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY DATETRUNC(month, order_date)) as Running_sales
FROM(
SELECT
	DATETRUNC(month, order_date) as order_date,
	SUM(line_total) AS total_sales
FROM fact_sales
GROUP BY DATETRUNC(month, order_date)
) t 

--b-Cummulative Analysis
SELECT
	order_mnth,
	total_sales,
	-- Reset the total sales by each year, cumulative sales for each year
	SUM(total_sales) OVER(PARTITION BY DATETRUNC(YEAR,order_mnth) ORDER BY order_mnth) as Running_total_yearly,
	SUM(total_sales) OVER(ORDER BY order_mnth) as Running_totalSales
	FROM (
SELECT
	DATETRUNC(month, order_date) as order_mnth,
	SUM(line_total) as total_sales
	FROM fact_sales
GROUP BY DATETRUNC(month, order_date)
) t

-- c-Performance Analysis
-- Comparing average sales for each product to the overall average
SELECT
	product_name,
	order_year,
	total_sales,
	--LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) as last_year_sales,
	-- total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) as diff_year,
	AVG(total_sales) OVER(PARTITION BY product_name) as avg_sales,
	total_sales - AVG(total_sales) OVER(PARTITION BY product_name) as diff_avg,
	CASE WHEN total_sales - AVG(total_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
		 WHEN total_sales - AVG(total_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
		 ELSE 'Avg' 
	END AS Avg_change
FROM (
SELECT
	product_name,
	DATETRUNC(YEAR, order_date) as order_year,
	SUM(line_total) as total_sales
FROM fact_sales f 
LEFT JOIN dim_product p 
ON f.product_id = p.product_id
GROUP BY DATETRUNC(YEAR, order_date),product_name
) t 

-- Year-Over-Year Analysis
SELECT
	product_name,
	order_year,
	total_sales,
	LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) as last_year_sales,
	total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) as diff_year,
	--AVG(total_sales) OVER(PARTITION BY product_name) as avg_sales,
	--total_sales - AVG(total_sales) OVER(PARTITION BY product_name) as diff_avg,
	CASE WHEN total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increasing'
		 WHEN total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decreasing'
		 ELSE 'Constant' 
	END AS Avg_change
FROM (
SELECT
	product_name,
	DATETRUNC(YEAR, order_date) as order_year,
	SUM(line_total) as total_sales
FROM fact_sales f 
LEFT JOIN dim_product p 
ON f.product_id = p.product_id
GROUP BY DATETRUNC(YEAR, order_date),product_name
) t 

-- d-Part-to-Whole Analysis
-- Analysing the Categories of our company to find out the percentage of each of them in sales contributing to the overall
WITH cte_analysis as (
SELECT
	category,
	SUM(line_total) as total_sales
FROM dim_product p 
JOIN fact_sales f 
ON p.product_id = f.product_id
GROUP BY category
) 
SELECT 
	category,
	total_sales,
	SUM(total_sales) OVER() overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER())*100.0 ,2), '%') as pcg_of_all
FROM cte_analysis
ORDER BY total_sales DESC

-- e-Data Segmentation
-- Aggregating a measure with another segmented measure (cost range segmented into categories)
WITH life_span AS (
SELECT
    c.customer_id,
    c.customer_type,
    c.customer_name,
	SUM(line_total) as total_sales,
    MIN(s.order_date) AS frst_ordr,
    MAX(s.order_date) AS lst_ordr,
	DATEDIFF(month,MIN(s.order_date),MAX(s.order_date)) as life_Span
FROM dim_customer c
LEFT JOIN fact_sales s 
    ON c.customer_id = s.customer_id
GROUP BY 
    c.customer_id,
    c.customer_type,
    c.customer_name
)
SELECT
	cust_segmnt,
	COUNT(customer_id) as total_customers
FROM(
SELECT
	customer_id,
	CASE WHEN life_span >= 12 AND total_sales > 5000 THEN 'VIP'
		 WHEN life_span >= 12 AND total_sales <=5000 THEN 'Regular'
		 ELSE 'New'
	END as cust_segmnt
FROM life_span 
) t 
GROUP BY cust_segmnt
ORDER BY total_customers DESC
