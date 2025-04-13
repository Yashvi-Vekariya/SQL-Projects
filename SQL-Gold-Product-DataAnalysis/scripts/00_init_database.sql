-- Switch to master/root to manage databases
-- Drop the database if it exists
DROP DATABASE IF EXISTS DataWarehouseAnalytics;

-- Create the new database
CREATE DATABASE DataWarehouseAnalytics;

-- Switch to the new database
USE DataWarehouseAnalytics;

-- Create schema (in MySQL we typically use databases instead of schemas, 
-- but we can still use the tables with the schema name prefix)
-- Create dimension and fact tables
CREATE TABLE dim_customers (
    customer_key INT,
    customer_id INT,
    customer_number VARCHAR(50),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    country VARCHAR(50),
    marital_status VARCHAR(50),
    gender VARCHAR(50),
    birthdate DATE,
    create_date DATE
);

CREATE TABLE dim_products (
    product_key INT,
    product_id INT,
    product_number VARCHAR(50),
    product_name VARCHAR(50),
    category_id VARCHAR(50),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    maintenance VARCHAR(50),
    cost INT,
    product_line VARCHAR(50),
    start_date DATE
);

CREATE TABLE fact_sales (
    order_number VARCHAR(50),
    product_key INT,
    customer_key INT,
    order_date DATE,
    shipping_date DATE,
    due_date DATE,
    sales_amount INT,
    quantity TINYINT,
    price INT
);

-- Optional: Truncate tables before inserting (if running script multiple times)
TRUNCATE TABLE dim_customers;
TRUNCATE TABLE dim_products;
TRUNCATE TABLE fact_sales;

SET GLOBAL local_infile = 1;
-- Load data using MySQL's LOAD DATA INFILE syntax
LOAD DATA LOCAL INFILE 
'D:/SQL-Projects/SQL-data-analytics-project/datasets/csv-files/gold.dim_customers.csv'
INTO TABLE dim_customers
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'D:/SQL-Projects/SQL-data-analytics-project/datasets/csv-files/gold.dim_products.csv'
INTO TABLE dim_products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 
'D:/SQL-Projects/SQL-data-analytics-project/datasets/csv-files/gold.fact_sales.csv'
INTO TABLE fact_sales
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;