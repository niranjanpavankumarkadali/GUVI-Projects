-- Query to create database and use it
CREATE DATABASE retail_sales_project;
USE retail_sales_project;

-- Query to create tables
CREATE TABLE retail_2009_2010 (
    Invoice VARCHAR(20),
    StockCode VARCHAR(50),
    Description TEXT,
    Quantity INT,
    InvoiceDate VARCHAR(50),
    Price DECIMAL(10,2),
    CustomerID VARCHAR(20),
    Country VARCHAR(100)
)
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

CREATE TABLE retail_2010_2011 (
    Invoice VARCHAR(20),
    StockCode VARCHAR(50),
    Description TEXT,
    Quantity INT,
    InvoiceDate VARCHAR(50),
    Price DECIMAL(10,2),
    CustomerID VARCHAR(20),
    Country VARCHAR(100)
)
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Data loading and data cleaning
-- query to load data into tables
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.6/Uploads/Tyear 2009-10.csv'
INTO TABLE retail_2009_2010
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.6/Uploads/Tyear 2010-11.csv'
INTO TABLE retail_2010_2011
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SHOW WARNINGS; -- show if any warnings are present for the rows in table

-- query to verify if the data is loaded successfully
SELECT *
FROM retail_2009_2010
LIMIT 10;

SELECT *
FROM retail_2010_2011
LIMIT 10;

-- query to check how many rows have been loaded
SELECT COUNT(*)
FROM retail_2009_2010;

SELECT COUNT(*)
FROM retail_2010_2011;

-- query to check incorrect price rows
SELECT *
FROM retail_2009_2010
WHERE Price = 0
OR Price IS NULL;

SELECT *
FROM retail_2010_2011
WHERE Price = 0
OR Price IS NULL;

-- query to check weird price values
SELECT Invoice, Description, Price
FROM retail_2009_2010
ORDER BY Price DESC;

SELECT Invoice, Description, Price
FROM retail_2010_2011
ORDER BY Price DESC;

-- query to remove bad rows
DELETE FROM retail_2009_2010
WHERE Price <= 0
OR Quantity <= 0;

DELETE FROM retail_2010_2011
WHERE Price <= 0
OR Quantity <= 0;

-- Add new column for different invoice date format
ALTER TABLE retail_2009_2010
ADD COLUMN InvoiceDate_New DATETIME;

ALTER TABLE retail_2010_2011
ADD COLUMN InvoiceDate_New DATETIME;

-- update the new column with required format
UPDATE retail_2009_2010
SET InvoiceDate_New =
STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i');

UPDATE retail_2010_2011
SET InvoiceDate_New =
STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i');

-- verify the conversion
SELECT InvoiceDate, InvoiceDate_New
FROM retail_2009_2010
LIMIT 10;

SELECT InvoiceDate, InvoiceDate_New
FROM retail_2010_2011
LIMIT 10;

-- replace old column with new column
ALTER TABLE retail_2009_2010
DROP COLUMN InvoiceDate;
ALTER TABLE retail_2009_2010
CHANGE InvoiceDate_New InvoiceDate DATETIME;

ALTER TABLE retail_2010_2011
DROP COLUMN InvoiceDate;
ALTER TABLE retail_2010_2011
CHANGE InvoiceDate_New InvoiceDate DATETIME;

-- verify row count
SELECT COUNT(*) FROM retail_2009_2010;
SELECT COUNT(*) FROM retail_2010_2011;

-- Combine both tables into one master table
CREATE TABLE retail_combined AS
SELECT * FROM retail_2009_2010
UNION ALL
SELECT * FROM retail_2010_2011;

-- check NULL values
SELECT *
FROM retail_combined
WHERE CustomerID IS NULL;

-- remove cancelled invoices. Ideally cancelled invoices starts with 'c'.
DELETE FROM retail_combined
WHERE Invoice LIKE 'C%';

-- remove negative quantity values from table
DELETE FROM retail_combined
WHERE Quantity <= 0;

-- remove negative price values from table
DELETE FROM retail_combined
WHERE Price <= 0;

-- add new column named total_sales to the table
ALTER TABLE retail_combined
ADD COLUMN total_sales DECIMAL(12,2);

-- calculate the value of total_sales
UPDATE retail_combined
SET total_sales = Quantity * Price;

-- add new columns named transaction_year and transaction_month
ALTER TABLE retail_combined
ADD COLUMN transaction_year INT,
ADD COLUMN transaction_month INT;

-- update values of new columns transaction_year and transaction_month
UPDATE retail_combined
SET
transaction_year = YEAR(InvoiceDate),
transaction_month = MONTH(InvoiceDate);

-- Exploratory Data Analysis (EDA)
-- KPI 1 — Total Revenue
SELECT ROUND(SUM(total_sales),2) AS total_revenue
FROM retail_combined;

-- KPI 2 — Total Orders
SELECT COUNT(DISTINCT Invoice) AS total_orders
FROM retail_combined;

-- KPI 3 — Total Customers
SELECT COUNT(DISTINCT CustomerID) AS total_customers
FROM retail_combined;

-- KPI 4 — Average Order Value
SELECT ROUND(
    SUM(total_sales) /
    COUNT(DISTINCT Invoice),2
) AS avg_order_value
FROM retail_combined;

-- KPI 5 — Revenue Per Customer
SELECT ROUND(
    SUM(total_sales) /
    COUNT(DISTINCT CustomerID),2
) AS revenue_per_customer
FROM retail_combined;

-- Analysis
-- Top 10 Products
SELECT
    Description,
    ROUND(SUM(total_sales),2) AS revenue
FROM retail_combined
GROUP BY Description
ORDER BY revenue DESC
LIMIT 10;

-- Top Countries
SELECT
    Country,
    ROUND(SUM(total_sales),2) AS revenue
FROM retail_combined
GROUP BY Country
ORDER BY revenue DESC;

-- Monthly Revenue Trend
SELECT
    transaction_year,
    transaction_month,
    ROUND(SUM(total_sales),2) AS monthly_sales
FROM retail_combined
GROUP BY transaction_year, transaction_month
ORDER BY transaction_year, transaction_month;

-- Top Customers
SELECT
    CustomerID,
    ROUND(SUM(total_sales),2) AS revenue
FROM retail_combined
GROUP BY CustomerID
ORDER BY revenue DESC
LIMIT 10;

-- Repeat Customers
SELECT
    CustomerID,
    COUNT(DISTINCT Invoice) AS total_orders
FROM retail_combined
GROUP BY CustomerID
HAVING total_orders > 1
ORDER BY total_orders DESC;

-- display everything in retail_combined table so that we can export it
SELECT * FROM retail_combined;

-- create retail_final table for exporting data
CREATE TABLE retail_final AS
SELECT
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price,
    CustomerID,
    Country,
    Quantity * Price AS total_sales
FROM retail_combined
WHERE
    Quantity > 0
    AND Price > 0
    AND CustomerID IS NOT NULL;

-- display retail_final table    
SELECT * FROM retail_final;

-- export dataset
(
SELECT
'Invoice',
'StockCode',
'Description',
'Quantity',
'InvoiceDate',
'Price',
'CustomerID',
'Country',
'total_sales'
)

UNION ALL

(
SELECT
Invoice,
StockCode,
Description,
Quantity,
InvoiceDate,
Price,
CustomerID,
Country,
total_sales
FROM retail_final
)

INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 9.6/Uploads/retail_final.tsv'
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n';