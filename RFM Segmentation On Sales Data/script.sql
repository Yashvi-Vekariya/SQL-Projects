-- Creating the Database
CREATE DATABASE rfm_analysis;
USE rfm_analysis;

-- Creating the table with proper column names
CREATE TABLE rfm_data (
    ORDERNUMBER INT,
    QUANTITY INT,
    PRICEEACH DECIMAL(10,2),
    ORDERLINENUMBER INT,
    SALES DECIMAL(10,2),
    ORDERDATE DATE,
    STATUS VARCHAR(20),
    QTR_ID INT,
    MONTH_ID INT,
    YEAR_ID INT,
    PRODUCTLINE VARCHAR(50),
    MSRP DECIMAL(10,2),
    CUSTOMERNAME VARCHAR(100),
    CUSTOMERID INT,
    PHONE VARCHAR(20),
    ADDRESSLINE1 VARCHAR(100),
    ADDRESSLINE2 VARCHAR(100),
    CITY VARCHAR(50),
    STATE VARCHAR(50),
    POSTALCODE VARCHAR(20),
    COUNTRY VARCHAR(50),
    TERRITORY VARCHAR(50),
    CONTACTFIRSTNAME VARCHAR(50),
    CONTACTLASTNAME VARCHAR(50),
    DEALSIZE VARCHAR(20)
);

-- Enable local infile loading
SET GLOBAL local_infile = 1;

-- Increase max_allowed_packet size to handle larger files
SET GLOBAL max_allowed_packet = 1073741824; -- 1GB

-- Load data from CSV file
-- Make sure to adjust the file path to where your CSV is located
LOAD DATA LOCAL INFILE 
'D:/SQL-Projects/RFM Segmentation On Sales Data/RFM Data.csv'
INTO TABLE rfm_data
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'  -- Using Windows line endings
IGNORE 1 ROWS;

-- Inspecting Data
SELECT * FROM rfm_data LIMIT 10;

-- Distinct value checks
SELECT DISTINCT STATUS FROM rfm_data;
SELECT DISTINCT COUNTRY FROM rfm_data;
SELECT DISTINCT YEAR_ID FROM rfm_data;
SELECT DISTINCT PRODUCTLINE FROM rfm_data;
SELECT DISTINCT DEALSIZE FROM rfm_data;
SELECT DISTINCT TERRITORY FROM rfm_data;

-- Sales by product line
SELECT 
    PRODUCTLINE, 
    ROUND(SUM(SALES), 0) AS Revenue, 
    COUNT(DISTINCT ORDERNUMBER) AS NO_OF_ORDERS
FROM 
    rfm_data
GROUP BY 
    PRODUCTLINE
ORDER BY 
    3 DESC;

-- Sales by year
SELECT 
    YEAR_ID, 
    SUM(SALES) AS Revenue
FROM 
    rfm_data
GROUP BY 
    YEAR_ID
ORDER BY 
    2 DESC;

-- Sales by deal size
SELECT  
    DEALSIZE,  
    SUM(SALES) AS Revenue
FROM 
    rfm_data
GROUP BY 
    DEALSIZE
ORDER BY 
    2 DESC;

-- Top cities by sales in UK
SELECT 
    CITY, 
    SUM(SALES) AS Revenue
FROM 
    rfm_data
WHERE 
    COUNTRY = 'UK'
GROUP BY 
    CITY
ORDER BY 
    Revenue DESC
LIMIT 100;  -- Added this limit to avoid potential issues

-- Best months for sales by year
-- Year 2003
SELECT  
    MONTH_ID, 
    SUM(SALES) AS Revenue, 
    COUNT(ORDERNUMBER) AS Frequency
FROM 
    rfm_data
WHERE 
    YEAR_ID = 2003
GROUP BY  
    MONTH_ID
ORDER BY 
    2 DESC;

-- Year 2004
SELECT  
    MONTH_ID, 
    SUM(SALES) AS Revenue, 
    COUNT(ORDERNUMBER) AS Frequency
FROM 
    rfm_data
WHERE 
    YEAR_ID = 2004
GROUP BY  
    MONTH_ID
ORDER BY 
    2 DESC;

-- Year 2005
SELECT  
    MONTH_ID, 
    SUM(SALES) AS Revenue, 
    COUNT(ORDERNUMBER) AS Frequency
FROM 
    rfm_data
WHERE 
    YEAR_ID = 2005
GROUP BY  
    MONTH_ID
ORDER BY 
    2 DESC;

-- Top product lines in November 2004
SELECT  
    MONTH_ID, 
    PRODUCTLINE, 
    SUM(SALES) AS Revenue, 
    COUNT(ORDERNUMBER) AS Order_Count
FROM 
    rfm_data
WHERE 
    YEAR_ID = 2004 AND MONTH_ID = 11
GROUP BY  
    MONTH_ID, PRODUCTLINE
ORDER BY 
    3 DESC;

-- Best-selling products in USA by year
SELECT 
    COUNTRY, 
    YEAR_ID, 
    PRODUCTLINE, 
    SUM(SALES) AS Revenue
FROM 
    rfm_data
WHERE 
    COUNTRY = 'USA'
GROUP BY  
    COUNTRY, YEAR_ID, PRODUCTLINE
ORDER BY 
    4 DESC;

-- RFM Analysis
-- First getting the most recent order date
SELECT 
    MAX(ORDERDATE) AS Latest_Order_Date
FROM
    rfm_data;

-- Fixed RFM Analysis - Separating the CTE and the final query
WITH RFM_Base AS (
    SELECT 
        CUSTOMERNAME,
        SUM(SALES) AS MonetaryValue,
        AVG(SALES) AS AvgMonetaryValue,
        COUNT(DISTINCT ORDERNUMBER) AS Frequency,
        MAX(ORDERDATE) AS Last_Order_Date,
        (SELECT MAX(ORDERDATE) FROM rfm_data) AS Final_Date
    FROM 
        rfm_data
    GROUP BY 
        CUSTOMERNAME
),
RFM_Calc AS (
    SELECT 
        *,
        DATEDIFF(Final_Date, Last_Order_Date) AS Recency
    FROM 
        RFM_Base
),
RFM_Scores AS (
    SELECT 
        *,
        NTILE(4) OVER (ORDER BY Recency DESC) AS rfm_recency,
        NTILE(4) OVER (ORDER BY Frequency) AS rfm_frequency,
        NTILE(4) OVER (ORDER BY MonetaryValue) AS rfm_monetary
    FROM 
        RFM_Calc
),
RFM_Final AS (
    SELECT 
        *,
        CONCAT(rfm_recency, rfm_frequency, rfm_monetary) AS RFM_SCORE
    FROM 
        RFM_Scores
)
-- Final output query
SELECT 
    CUSTOMERNAME,
    MonetaryValue,
    AvgMonetaryValue,
    Frequency,
    Last_Order_Date,
    Recency,
    rfm_recency,
    rfm_frequency,
    rfm_monetary,
    RFM_SCORE,
    CASE 
        WHEN RFM_SCORE IN ('414', '314', '424', '434', '444', '324', '334') THEN 'Loyal Customers'
        WHEN RFM_SCORE IN ('113', '124', '214') THEN 'Potential Churners'
        WHEN RFM_SCORE IN ('411', '422') THEN 'New Customers'
        WHEN RFM_SCORE IN ('314', '244') THEN 'Big Spenders'
        WHEN RFM_SCORE IN ('134', '244') THEN 'Can''t Lose Them'
        ELSE 'Other'
    END AS Customer_Segment
FROM 
    RFM_Final
ORDER BY 
    MonetaryValue DESC;