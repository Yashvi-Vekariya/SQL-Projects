/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
       - total orders
       - total sales
       - total quantity purchased
       - total products
       - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value
        - average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
DROP VIEW IF EXISTS DataWarehouseAnalytics.report_customers;

CREATE VIEW DataWarehouseAnalytics.report_customers AS
SELECT
    ca.customer_key,
    ca.customer_number,
    ca.customer_name,
    ca.age,
    CASE 
        WHEN ca.age < 20 THEN 'Under 20'
        WHEN ca.age BETWEEN 20 AND 29 THEN '20-29'
        WHEN ca.age BETWEEN 30 AND 39 THEN '30-39'
        WHEN ca.age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,
    CASE 
        WHEN ca.lifespan >= 12 AND ca.total_sales > 5000 THEN 'VIP'
        WHEN ca.lifespan >= 12 AND ca.total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    ca.last_order_date,
    TIMESTAMPDIFF(MONTH, ca.last_order_date, CURDATE()) AS recency,
    ca.total_orders,
    ca.total_sales,
    ca.total_quantity,
    ca.total_products,
    ca.lifespan,
    -- Compute average order value (AOV)
    CASE WHEN ca.total_orders = 0 THEN 0
         ELSE ca.total_sales / ca.total_orders
    END AS avg_order_value,
    -- Compute average monthly spend
    CASE WHEN ca.lifespan = 0 THEN ca.total_sales
         ELSE ca.total_sales / ca.lifespan
    END AS avg_monthly_spend
FROM (
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM (
        SELECT
            f.order_number,
            f.product_key,
            f.order_date,
            f.sales_amount,
            f.quantity,
            c.customer_key,
            c.customer_number,
            CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
            TIMESTAMPDIFF(YEAR, c.birthdate, CURDATE()) age
        FROM DataWarehouseAnalytics.fact_sales f
        LEFT JOIN DataWarehouseAnalytics.dim_customers c
        ON c.customer_key = f.customer_key
        WHERE order_date IS NOT NULL
    ) AS base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
) AS ca;