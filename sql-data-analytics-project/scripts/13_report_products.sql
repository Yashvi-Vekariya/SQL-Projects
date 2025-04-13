/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
DROP VIEW IF EXISTS DataWarehouseAnalytics.report_products;

CREATE VIEW DataWarehouseAnalytics.report_products AS
SELECT 
    p2.product_key,
    p2.product_name,
    p2.category,
    p2.subcategory,
    p2.cost,
    p2.last_sale_date,
    TIMESTAMPDIFF(MONTH, p2.last_sale_date, CURDATE()) AS recency_in_months,
    CASE
        WHEN p2.total_sales > 50000 THEN 'High-Performer'
        WHEN p2.total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    p2.lifespan,
    p2.total_orders,
    p2.total_sales,
    p2.total_quantity,
    p2.total_customers,
    p2.avg_selling_price,
    -- Average Order Revenue (AOR)
    CASE 
        WHEN p2.total_orders = 0 THEN 0
        ELSE p2.total_sales / p2.total_orders
    END AS avg_order_revenue,
    -- Average Monthly Revenue
    CASE
        WHEN p2.lifespan = 0 THEN p2.total_sales
        ELSE p2.total_sales / p2.lifespan
    END AS avg_monthly_revenue
FROM (
    SELECT
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost,
        TIMESTAMPDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan,
        MAX(f.order_date) AS last_sale_date,
        COUNT(DISTINCT f.order_number) AS total_orders,
        COUNT(DISTINCT f.customer_key) AS total_customers,
        SUM(f.sales_amount) AS total_sales,
        SUM(f.quantity) AS total_quantity,
        ROUND(AVG(f.sales_amount / NULLIF(f.quantity, 0)),1) AS avg_selling_price
    FROM DataWarehouseAnalytics.fact_sales f
    LEFT JOIN DataWarehouseAnalytics.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
) AS p2;