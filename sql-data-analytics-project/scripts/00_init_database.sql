/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
    and all required tables, then loads data from CSV files.
	
WARNING:
    Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Check if the database exists and drop it if it does
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
    PRINT 'Existing DataWarehouseAnalytics database dropped.';
END;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;
PRINT 'DataWarehouseAnalytics database created successfully.';
GO

USE DataWarehouseAnalytics;
GO

-- Create Schemas
CREATE SCHEMA gold;
PRINT 'Gold schema created successfully.';
GO

-- Create Dimension and Fact tables
CREATE TABLE gold.dim_customers(
    customer_key int,
    customer_id int,
    customer_number nvarchar(50),
    first_name nvarchar(50),
    last_name nvarchar(50),
    country nvarchar(50),
    marital_status nvarchar(50),
    gender nvarchar(50),
    birthdate date,
    create_date date
);
PRINT 'Customers dimension table created.';
GO

CREATE TABLE gold.dim_products(
    product_key int,
    product_id int,
    product_number nvarchar(50),
    product_name nvarchar(50),
    category_id nvarchar(50),
    category nvarchar(50),
    subcategory nvarchar(50),
    maintenance nvarchar(50),
    cost int,
    product_line nvarchar(50),
    start_date date 
);
PRINT 'Products dimension table created.';
GO

CREATE TABLE gold.fact_sales(
    order_number nvarchar(50),
    product_key int,
    customer_key int,
    order_date date,
    shipping_date date,
    due_date date,
    sales_amount int,
    quantity tinyint,
    price int 
);
PRINT 'Sales fact table created.';
GO

-- Import data from CSV files
-- NOTE: Ensure SQL Server has read access to the folder and files.

-- Customers dimension
PRINT 'Importing customer data...';
BULK INSERT gold.dim_customers
FROM 'C:\sql\sql-data-analytics-project\datasets\csv-files\gold.dim_customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\r\n',
    TABLOCK,
    CHECK_CONSTRAINTS,
    ERRORFILE = 'C:\sql\sql-data-analytics-project\errors\customer_errors.txt'
);
GO

-- Products dimension
PRINT 'Importing product data...';
BULK INSERT gold.dim_products
FROM 'C:\sql\sql-data-analytics-project\datasets\csv-files\gold.dim_products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\r\n',
    TABLOCK,
    CHECK_CONSTRAINTS,
    ERRORFILE = 'C:\sql\sql-data-analytics-project\errors\product_errors.txt'
);
GO

-- Sales fact
PRINT 'Importing sales data...';
BULK INSERT gold.fact_sales
FROM 'C:\sql\sql-data-analytics-project\datasets\csv-files\gold.fact_sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\r\n',
    TABLOCK,
    CHECK_CONSTRAINTS,
    ERRORFILE = 'C:\sql\sql-data-analytics-project\errors\sales_errors.txt'
);
GO

-- Verify data was loaded correctly
PRINT 'Verifying data load...';
PRINT 'Customer count:';
SELECT COUNT(*) AS CustomerCount FROM gold.dim_customers;

PRINT 'Product count:';
SELECT COUNT(*) AS ProductCount FROM gold.dim_products;

PRINT 'Sales count:';
SELECT COUNT(*) AS SalesCount FROM gold.fact_sales;
GO

PRINT 'Data warehouse setup complete!';