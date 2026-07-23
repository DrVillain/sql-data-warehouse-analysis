/*
===============================================================================
Report: gold.report_customers
===============================================================================
Purpose:
    This report consolidates key customer metrics and behaviors, built on
    top of gold.fact_sales and gold.dim_customers.
 
Highlights:
    1. Gathers essential fields such as customer name, age, and transaction
       details.
    2. Segments customers into age groups and behavioral tiers:
       - Age groups: Under 20, 20-29, 30-39, 40-49, 50 and above
       - Customer tiers: VIP, Regular, New (based on spending and activity)
    3. Aggregates customer-level metrics:
       - total orders
       - total sales
       - total quantity purchased
       - total products purchased (unique)
       - customer activity (in months)
    4. Calculates valuable KPIs:
       - recency (months since last order)
       - average order value (AOV)
       - average monthly spent
===============================================================================
*/

CREATE VIEW gold.report_customers AS 

-- ===============================================================================
-- 1. Base Query: retrieve core columns from fact_sales and dim_customers
-- ===============================================================================  
WITH source_query AS (
	SELECT 
		s.order_number,
		s.product_key,
		s.order_date,
		s.sales_amount,
		s.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ', c.last_name) customer_name,
		DATEDIFF(YEAR, c.birthdate, GETDATE()) customer_age
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_customers c
		ON s.customer_key = c.customer_key
	WHERE s.order_date IS NOT NULL
),

-- ===============================================================================
-- 2. Customer Aggregations: summarize key metrics at the customer level
-- ===============================================================================  
customer_aggregation AS(
	SELECT 
		customer_key,
		customer_number,
		customer_name,
		customer_age,
		COUNT(DISTINCT order_number) total_orders,
		SUM(sales_amount) total_spent,
		SUM(quantity) total_quantity,
		COUNT(DISTINCT product_key) total_products,
		MIN(order_date) first_order,
		MAX(order_date) latest_order,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) months_active
	FROM source_query
	GROUP BY 
		customer_key,
		customer_number,
		customer_name,
		customer_age
)

-- ===============================================================================
-- 3. Final Query: combine all customer results into one output
-- ===============================================================================
SELECT 
	customer_key,
	customer_number,
	customer_name,
	CASE 
		WHEN customer_age < 20 THEN 'Under 20'
		WHEN customer_age BETWEEN 20 AND 29 THEN '20-29'
		WHEN customer_age BETWEEN 30 AND 39 THEN '30-39'
		WHEN customer_age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and above'
	END age_group,
	CASE
		WHEN months_active >= 12 AND total_spent > 5000 THEN 'VIP'
		WHEN months_active >= 12 AND total_spent <= 5000 THEN 'Regular'
		ELSE 'New'
	END customer_tier,
	latest_order,
	DATEDIFF(MONTH, latest_order, GETDATE()) recency_months,
	total_orders,
	total_spent,
	total_quantity,
	months_active,
	-- Calculating avg order value
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE
			total_spent/total_orders
	END avg_order_value,
	-- Calculating avg spent monthly
	CASE 
		WHEN months_active = 0 THEN 0
		ELSE
			total_spent/months_active
	END avg_spent_month
FROM customer_aggregation
