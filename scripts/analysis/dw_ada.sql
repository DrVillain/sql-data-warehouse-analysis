/*
===============================================================================
Advanced Data Analysis
===============================================================================
Purpose:
    This script performs deeper analytical queries on the Gold layer views
    (dim_customers, dim_products, fact_sales) from the sql-data-warehouse
    practice project. It goes beyond exploratory analysis into trends,
    performance comparisons, contribution analysis, and segmentation.

Data Source:
    gold.dim_customers, gold.dim_products, gold.fact_sales
    (see: https://github.com/DrVillain/sql-data-warehouse-practice-project)

Sections:
    1. Change Over Time Analysis
    2. Cumulative Analysis
    3. Performance Analysis (Year-over-Year)
    4. Part-to-Whole Analysis
    5. Data Segmentation
===============================================================================
*/

-- ===============================================================================
-- 1. Change Over Time Analysis
-- ===============================================================================
-- granularity: year, month

SELECT 
	YEAR(order_date) year,
	MONTH(order_date) month,
	SUM(sales_amount) total_sales,
	COUNT(DISTINCT customer_key) total_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
	YEAR(order_date),
	MONTH(order_date)
ORDER BY 
	YEAR(order_date),
	MONTH(order_date);


-- ===============================================================================
-- 2. Cumulative Analysis
-- ===============================================================================
-- running total, moving average

SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date) running_total_sales,
	AVG(avg_price) OVER(ORDER BY order_date) moving_average_price
FROM (
	SELECT 
		DATETRUNC(MONTH, order_date) order_date,
		SUM(sales_amount) total_sales,
		AVG(price) avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date) 
)T;


-- ===============================================================================
-- 3. Performance Analysis (Year-over-Year)
-- ===============================================================================
-- yearly performance of products by comparing each product's sales
-- to both its average sales performance and the previous year

WITH yearly_product_sales AS (
	SELECT 
		YEAR(s.order_date) order_year,
		p.product_name prd_name,
		SUM(s.sales_amount) current_sales
	FROM gold.dim_products p
	LEFT JOIN gold.fact_sales s
		ON p.product_key = s.product_key
	WHERE order_date IS NOT NULL
	GROUP BY
		YEAR(s.order_date),
		p.product_name
)

SELECT 
	order_year,
	prd_name,
	current_sales,
	AVG(current_sales) OVER(PARTITION BY prd_name) avg_sales,
	current_sales - AVG(current_sales) OVER(PARTITION BY prd_name) diff_avg,
	CASE
		WHEN current_sales - AVG(current_sales) OVER(PARTITION BY prd_name) < 0 THEN 'Below Avg'
		WHEN current_sales - AVG(current_sales) OVER(PARTITION BY prd_name) > 0 THEN 'Above Avg'
		ELSE 'Avg'
	END avg_change,
	-- y-o-y analysis
	LAG(current_sales) OVER(PARTITION BY prd_name ORDER BY order_year) py_sales,
	current_sales - LAG(current_sales) OVER(PARTITION BY prd_name ORDER BY order_year) diff_py,
	CASE
		WHEN current_sales - LAG(current_sales) OVER(PARTITION BY prd_name ORDER BY order_year) < 0 THEN 'Decrease'
		WHEN current_sales - LAG(current_sales) OVER(PARTITION BY prd_name ORDER BY order_year) > 0 THEN 'Increase'
		ELSE 'No Change'
	END py_change
FROM yearly_product_sales
ORDER BY 
	prd_name, 
	order_year;


-- ===============================================================================
-- 4. Part-to-Whole Analysis
-- ===============================================================================
-- finding what categories contribute the most to the overall sales

WITH category_sales AS (
	SELECT 
		p.category category,
		SUM(s.sales_amount) total_sales
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
		ON s.product_key = p.product_key
	GROUP BY p.category
	
)
SELECT
	category,
	total_sales,
	SUM(total_sales) OVER() overall_sales,
	CONCAT(ROUND(CAST(total_sales AS FLOAT)/SUM(total_sales) OVER() * 100, 2), '%')  prcnt_of_total
FROM category_sales
ORDER BY total_sales DESC;


-- ===============================================================================
-- 5. Data Segmentation
-- ===============================================================================

-- segment products into cost ranges and count how many products fall into each

WITH product_segment AS (
SELECT 
	product_key,
	product_name,
	cost,
	CASE
		WHEN cost < 100 THEN 'Below 100'
		WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE 'Above 1000'
	END cost_range
FROM gold.dim_products
)

SELECT
	cost_range,
	COUNT(product_key) total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC;


/*
grouping customers into three segments based on their spending behavior
VIP: 12 months of history & spending more than 5000
REGULAR: 12 months of history & spending 5000 or less
lifespan less than 12 months
*/

WITH cte AS (
	SELECT 
		customer_key,
		MIN(order_date) first_order,
		MAX(order_date) latest_order,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) lifespan,
		SUM(sales_amount) total_spending
	FROM gold.fact_sales
	GROUP BY customer_key
),

segment AS (
	SELECT
		c.customer_key,
		CASE
			WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			ELSE 'New'
		END customer_tier
	FROM cte c
)

SELECT 
	customer_tier,
	COUNT(customer_key) total_customers
FROM segment
GROUP BY customer_tier
ORDER BY total_customers DESC;
