/*
====================================
Customer Report
====================================
*/
CREATE VIEW Customer_Report AS
WITH base_query AS (
SELECT 
	sales_order_id,
	s.product_id,
	c.customer_id,
	c.customer_type,
	c.customer_name,
	t.country,
	s.order_date,
	s.order_qty,
	s.line_total
FROM fact_sales s
LEFT JOIN dim_customer c
ON c.customer_id = s.customer_id
LEFT JOIN dim_territory t
ON t.territory_id = s.territory_id
),customer_aggregations AS (

SELECT 
	customer_id,
	customer_name,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH,MAX(order_date),GETDATE()) AS recency,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) as life_span,
	SUM(order_qty) AS total_quantity,
	SUM(line_total) AS total_spending,
	COUNT(DISTINCT product_id) AS total_products,
	COUNT(DISTINCT sales_order_id) AS total_orders
FROM base_query
GROUP BY 
	customer_id,
	customer_name
)
SELECT
	customer_id,
	customer_name,
	last_order_date,
	recency,
	life_span,
	CASE WHEN life_span >= 12 AND total_spending > 5000 THEN 'VIP'
		 WHEN life_span >= 12 AND total_spending <=5000 THEN 'Regular'
		 ELSE 'New'
	END as cust_segmnt,
	total_quantity,
	total_spending,
	CASE WHEN total_spending = 0 THEN 0
		 ELSE total_spending / total_orders 
	END as avg_order_value,
	-- Average Monthly Spend 
	CASE WHEN life_span = 0 THEN total_spending
		 ELSE total_spending / life_span 
	END as avg_monthly_spend,
	total_products,
	total_orders
FROM customer_aggregations

SELECT * 
FROM Customer_Report 