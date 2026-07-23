/*
===============================================================================
Report: gold.report_products
===============================================================================
Purpose:
    This report consolidates key product metrics and behaviors, built on top
    of gold.fact_sales and gold.dim_products.
 
Highlights:
    1. Gathers essential fields such as product name, category, subcategory,
       and cost.
    2. Segments products by revenue into performance tiers:
       High-Performer, Mid-Range, Low-Performer.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - sales span (in months)
    4. Calculates valuable KPIs:
       - recency (months since last order)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
CREATE VIEW gold.report_products AS
  
-- ===============================================================================
-- 1. Base Query: retrieve core columns from fact_sales and dim_products
-- ===============================================================================
WITH source_query AS (
	SELECT
		s.order_number,
		s.order_date,
		s.customer_key,
		s.sales_amount,
		s.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
		ON s.product_key = p.product_key
	WHERE order_date IS NOT NULL
),

-- ===============================================================================
-- 2. Product Aggregations: summarize key metrics at the product level
-- ===============================================================================  
product_aggregation AS (
	SELECT 
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		MAX(order_date) latest_order_dt,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) sales_span_months,
		COUNT(DISTINCT order_number) total_orders,
		COUNT(DISTINCT customer_key) total_customers,
		SUM(sales_amount) total_sales,
		SUM(quantity) total_quantity_sold,
		ROUND(AVG(CAST(sales_amount AS FLOAT)/NULLIF(quantity, 0)), 1) avg_selling_price
	FROM source_query
	GROUP BY 
		product_key,
		product_name,
		category,
		subcategory,
		cost
)
  
-- ===============================================================================
-- 3. Final Query: combine all product results into one output
-- ===============================================================================
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	latest_order_dt,
	DATEDIFF(MONTH, latest_order_dt, GETDATE()) recency_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END product_performance,
	sales_span_months,
	total_orders,
	total_customers,
	total_sales,
	avg_selling_price,
	CASE
		WHEN total_orders = 0 THEN 0 
		ELSE total_sales / total_orders
	END avg_order_revenue,
	CASE
		WHEN sales_span_months = 0 THEN total_sales
		ELSE total_sales/sales_span_months
	END avg_monthly_revenue
FROM product_aggregation
