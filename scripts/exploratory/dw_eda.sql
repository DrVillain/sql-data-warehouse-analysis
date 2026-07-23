/*
===============================================================================
Exploratory Data Analysis
===============================================================================
Purpose:
    This script performs initial exploratory analysis on the Gold layer views
    (dim_customers, dim_products, fact_sales) from the sql-data-warehouse
    practice project. It covers database structure exploration, dimension
    exploration, date range checks, key business measures, magnitude
    analysis, and ranking analysis.

Data Source:
    gold.dim_customers, gold.dim_products, gold.fact_sales
    (see: https://github.com/DrVillain/sql-data-warehouse-practice-project)

Sections:
    1. Database Exploration
    2. Dimensions Exploration
    3. Date Range Exploration
    4. Measures Exploration (Key Metrics)
    5. Magnitude Analysis
    6. Ranking Analysis
===============================================================================
*/

-- ===============================================================================
-- 1. Database Exploration
-- ===============================================================================

-- explore all objects in the database
SELECT *
FROM INFORMATION_SCHEMA.TABLES;

-- explore all columns in a specific table
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';


-- ===============================================================================
-- 2. Dimensions Exploration
-- ===============================================================================

-- explore all countries our customers come from
SELECT DISTINCT country
FROM gold.dim_customers;

-- explore all categories, subcategories, and product names
SELECT DISTINCT category, subcategory, product_name
FROM gold.dim_products;


-- ===============================================================================
-- 3. Date Range Exploration
-- ===============================================================================

-- find the first and last order date and the total range in months
SELECT 
	MIN(order_date) first_order_dt,
	MAX(order_date) last_order_dt,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) order_range_months
FROM gold.fact_sales;

-- find the youngest and oldest customer based on birthdate
SELECT 
	MIN(birthdate) oldest_birthdate,
	DATEDIFF(YEAR, MIN(birthdate), GETDATE()) oldest_age,
	MAX(birthdate) youngest_birthdate,
	DATEDIFF(YEAR, MAX(birthdate), GETDATE()) youngest_age
FROM gold.dim_customers;


-- ===============================================================================
-- 4. Measures Exploration (Key Metrics)
-- ===============================================================================

-- overall sales, quantity, average price, and order count
SELECT 
	SUM(sales_amount) total_sales,
	SUM(quantity) n_items_sold,
	AVG(price) avg_selling_price,
	COUNT(DISTINCT order_number) n_of_orders
FROM gold.fact_sales;

-- total number of products
SELECT 
	COUNT(product_key),
	COUNT(DISTINCT product_key)
FROM gold.dim_products;

-- total number of customers
SELECT
	COUNT(customer_key),
	COUNT(DISTINCT customer_key)
FROM gold.dim_customers;

-- find the total number of customers that have placed an order
SELECT
	COUNT(DISTINCT customer_key) total_customers
FROM gold.fact_sales;

-- generate a report that shows all key metrics
SELECT 'Total Sales' AS measure_name, 
	SUM(sales_amount) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT 'Total Quantity' AS measure_name, 
	SUM(quantity) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT 'Average Price' AS measure_name, 
	AVG(price) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT 'Total Nr. Orders' AS measure_name, 
	COUNT(DISTINCT order_number) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT 'Total Nr. Products' AS measure_name, 
	COUNT(product_key) AS measure_value
FROM gold.dim_products

UNION ALL

SELECT 'Total Nr. Customers' AS measure_name, 
	COUNT(customer_key) AS measure_value
FROM gold.dim_customers;


-- ===============================================================================
-- 5. Magnitude Analysis
-- ===============================================================================

-- total customers by country
SELECT 
	country,
	COUNT(customer_key) total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- total customers by gender
SELECT 
	gender,
	COUNT(customer_key) total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- total products by category
SELECT
	category,
	COUNT(*) total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- average cost by category
SELECT
	category,
	AVG(cost) avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- total revenue for each category
SELECT 
	p.category,
	SUM(s.sales_amount) total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
	ON  s.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- total revenue for each customer
SELECT
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(s.sales_amount) total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
	ON s.customer_key = c.customer_key
GROUP BY 
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_revenue DESC;

-- distribution of items sold across countries
SELECT
	c.country,
	SUM(s.quantity) total_sold_items
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
	ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;


-- ===============================================================================
-- 6. Ranking Analysis
-- ===============================================================================

-- which 5 products generate the highest revenue? (simple approach)
SELECT TOP 5
	p.product_name,
	SUM(sales_amount) total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
	ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- which 5 products generate the highest revenue? (using window function, handles ties)
SELECT *
FROM (
	SELECT 
		p.product_name,
		SUM(sales_amount) total_revenue,
		RANK() OVER(ORDER BY SUM(sales_amount) DESC) product_rank
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
		ON s.product_key = p.product_key
	GROUP BY p.product_name
)t
WHERE product_rank <= 5;

-- which 5 products generate the lowest revenue?
SELECT TOP 5
	p.product_name,
	SUM(sales_amount) total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
	ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;

-- 10 customers who have generated the highest revenue
SELECT
	*
FROM (
	SELECT 
		c.customer_key,
		CONCAT(c.first_name, ' ', c.last_name) customer_name,
		SUM(s.sales_amount) total_revenue,
		ROW_NUMBER() OVER(ORDER BY SUM(s.sales_amount) DESC) customer_rank
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_customers c
		ON s.customer_key = c.customer_key
	GROUP BY c.customer_key, CONCAT(c.first_name, ' ', c.last_name)
)t
WHERE customer_rank <= 10;

-- 3 customers with the fewest orders placed
SELECT
	*
FROM (
	SELECT 
		c.customer_key,
		CONCAT(c.first_name, ' ', c.last_name) customer_name,
		COUNT(DISTINCT s.order_number) total_orders,
		ROW_NUMBER() OVER(ORDER BY COUNT(DISTINCT s.order_number) ASC) customer_rank
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_customers c
		ON s.customer_key = c.customer_key
	GROUP BY c.customer_key, CONCAT(c.first_name, ' ', c.last_name)
)t
WHERE customer_rank <= 3;
