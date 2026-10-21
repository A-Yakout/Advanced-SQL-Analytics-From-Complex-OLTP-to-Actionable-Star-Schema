CREATE VIEW Product_Report AS
WITH base_query_pct AS (
SELECT 
	p.product_id,
	p.standard_cost,
	p.list_price,
	s.unit_price,
	p.product_name,
	p.sub_category,
	p.category,
	p.color,
	s.sales_order_id,
	s.customer_id,
	s.order_qty,
	s.order_date,
	s.line_total
FROM fact_sales s
LEFT JOIN dim_product p
ON p.product_id =s.product_id
),product_aggregation AS ( 
SELECT 
	product_id,
	product_name,
	category,
	sub_category,
	standard_cost,
	MAX(order_date) AS last_sale_date,
	COUNT(DISTINCT sales_order_id) AS total_orders,
	SUM(order_qty) AS total_quantity_sold,
	SUM(line_total) AS total_sales,
	COUNT(DISTINCT customer_id) as total_unique_customers,
	DATEDIFF(MONTH,MAX(order_date),GETDATE()) AS recencty,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS life_span
	
FROM base_query_pct
GROUP BY 
	product_id,
	product_name,
	category,
	sub_category,
	standard_cost
)
SELECT 
	product_id,
	product_name,
	category,
	sub_category,
	standard_cost,
	total_orders,
	total_quantity_sold,
	total_sales,
	total_unique_customers,
	recencty,
	life_span,
	CASE WHEN total_orders = 0 THEN 0 
		ELSE total_sales / total_orders 
	END as avg_order_value,
	CASE WHEN life_span = 0 THEN total_sales
		ELSE total_sales / life_span 
	END as avg_monthly_revenue,
	CASE 
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment
FROM product_aggregation

SELECT *
FROM Product_Report