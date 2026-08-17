/*====================================================================
                    AMAZON FRESH ANALYTICS PROJECT
====================================================================*/

CREATE DATABASE amazonfresh;

USE amazonfresh;


/*====================================================================
TASK 1 : RETRIEVE CUSTOMERS FROM A SPECIFIC CITY
Purpose:
Identify customers belonging to a specific city for
location-based marketing campaigns.
====================================================================*/

SELECT
    CustomerID,
    Name,
    City
FROM customers
WHERE City = 'North William';


/*====================================================================
TASK 2 : RETRIEVE PRODUCTS UNDER FRUITS CATEGORY
Purpose:
Retrieve products belonging to the Fruits category.
====================================================================*/

SELECT *
FROM products_corrected
WHERE Category = 'Fruits';


/*--------------------------------------------------------------------
After Normalisation:
Category information is stored in the Categories table.
The JOIN retrieves the category name for each product.
--------------------------------------------------------------------*/

SELECT
    p.ProductID,
    p.ProductName,
    c.CategoryName
FROM products_corrected AS p
JOIN categories AS c
    ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Fruits';


/*====================================================================
TASK 3 : DELETE CUSTOMERS BELOW 18 YEARS
Purpose:
Identify customers below 18 before deleting them.
This enforces the project's age-related business rule.
====================================================================*/

SELECT *
FROM customers
WHERE Age <= 18;


/* Delete customers whose age is 18 or below */

DELETE FROM customers
WHERE Age <= 18;


/*====================================================================
TASK 4 : APPLY CONSTRAINTS ON CUSTOMERS TABLE
Purpose:
Apply data integrity rules to the Customers table.

Rules:
1. Name cannot be NULL.
2. Name must be unique.
3. Age cannot be NULL.
4. Age must be greater than 18.
====================================================================*/

ALTER TABLE customers
MODIFY COLUMN Name VARCHAR(100) NOT NULL,
MODIFY COLUMN Age INT NOT NULL,
ADD CONSTRAINT chk_age CHECK (Age > 18),
ADD UNIQUE INDEX Name_UNIQUE (Name);


/*====================================================================
TASK 4 : ORDERS TABLE MODIFICATIONS
Purpose:
Define OrderID as the Primary Key and CustomerID as a
Foreign Key to establish the Customer-Order relationship.
====================================================================*/

ALTER TABLE orders_corrected
MODIFY COLUMN OrderID CHAR(36) NOT NULL,
MODIFY COLUMN CustomerID CHAR(36) NOT NULL,
ADD PRIMARY KEY (OrderID),
ADD INDEX CustomerID_idx (CustomerID);


/* Add Foreign Key relationship between Orders and Customers */

ALTER TABLE orders_corrected
ADD CONSTRAINT fk_customer_orders
FOREIGN KEY (CustomerID)
REFERENCES customers(CustomerID)
ON DELETE CASCADE
ON UPDATE CASCADE;


/*====================================================================
TASK 4 : PRODUCTS TABLE CONSTRAINTS
Purpose:
Define ProductID as Primary Key and connect each product
to its supplier using SupplierID.
====================================================================*/

ALTER TABLE products_corrected
MODIFY COLUMN ProductID CHAR(36) NOT NULL,
MODIFY COLUMN SupplierID CHAR(36) NOT NULL,
ADD PRIMARY KEY (ProductID),
ADD INDEX SupplierID_idx (SupplierID);


/* Add Foreign Key relationship between Products and Suppliers */

ALTER TABLE products_corrected
ADD CONSTRAINT fk_supplier
FOREIGN KEY (SupplierID)
REFERENCES suppliers_corrected(SupplierID)
ON DELETE NO ACTION
ON UPDATE NO ACTION;


/*====================================================================
TASK 4 : REVIEWS TABLE CONSTRAINTS
Purpose:
Define ReviewID as Primary Key and establish relationships
between Reviews, Products and Customers.
====================================================================*/

ALTER TABLE reviews_corrected
MODIFY COLUMN ReviewID CHAR(36) NOT NULL,
MODIFY COLUMN ProductID CHAR(36) NOT NULL,
MODIFY COLUMN CustomerID CHAR(36) NOT NULL,
ADD PRIMARY KEY (ReviewID),
ADD INDEX ProductID_idx (ProductID),
ADD INDEX CustomerID_idx (CustomerID);


/* Connect Reviews with Products and Customers */

ALTER TABLE reviews_corrected
ADD CONSTRAINT fk_review_product
FOREIGN KEY (ProductID)
REFERENCES products_corrected(ProductID),

ADD CONSTRAINT fk_review_customer
FOREIGN KEY (CustomerID)
REFERENCES customers(CustomerID);


/*====================================================================
TASK 5 : INSERT SAMPLE PRODUCTS
Purpose:
Insert new product records into the Products table.
====================================================================*/

INSERT INTO products_corrected
(
    ProductID,
    ProductName,
    PricePerUnit,
    StockQuantity,
    SupplierID,
    CategoryID
)
VALUES
(
    '11111111-1111-1111-1111-111111111111',
    'Apple',
    120,
    100,
    '64ce4c68-a8b5-445e-af96-a2f1491226a',
    1
),
(
    '22222222-2222-2222-2222-222222222222',
    'Banana',
    60,
    150,
    '64ce4c68-a8b5-445e-af96-a2f1491226a',
    1
);


/*====================================================================
TASK 6 : UPDATE STOCK QUANTITY
Purpose:
Update the stock quantity of a specific product.
====================================================================*/

UPDATE products_corrected
SET StockQuantity = 200
WHERE ProductID = '11111111-1111-1111-1111-111111111111';


/*====================================================================
TASK 7 : DELETE SUPPLIER FROM A SPECIFIC CITY
Purpose:
First identify suppliers from the selected city,
then delete the supplier record.
====================================================================*/

SELECT *
FROM suppliers_corrected
WHERE City = 'South Tyler';


DELETE FROM suppliers_corrected
WHERE City = 'South Tyler';


/*====================================================================
TASK 8 : ADD CHECK CONSTRAINT FOR PRODUCT RATINGS
Purpose:
Ensure that customer ratings are always between 1 and 5.
====================================================================*/

ALTER TABLE reviews_corrected
ADD CONSTRAINT chk_rating
CHECK (Rating BETWEEN 1 AND 5);


/*====================================================================
TASK 8 : DEFAULT VALUE FOR PRIME MEMBERSHIP
Purpose:
Set 'No' as the default value when PrimeMember is not provided.
====================================================================*/

ALTER TABLE customers
MODIFY COLUMN PrimeMember VARCHAR(10) DEFAULT 'No';


/*====================================================================
TASK 9 : ORDERS AFTER 2024-01-01
Purpose:
Retrieve orders placed after January 1, 2024.
====================================================================*/

SELECT *
FROM orders_corrected
WHERE OrderDate > '2024-01-01';


/*====================================================================
TASK 9 : PRODUCTS WITH AVERAGE RATING GREATER THAN 4
Purpose:
Identify products receiving high customer ratings.
====================================================================*/

SELECT
    ProductID,
    AVG(Rating) AS AverageRating
FROM reviews_corrected
GROUP BY ProductID
HAVING AVG(Rating) > 4;


/*====================================================================
TASK 9 : PRODUCT SALES
Purpose:
Calculate total sales generated by each product
and rank products from highest to lowest sales.
====================================================================*/

SELECT
    p.ProductName,
    SUM(od.Quantity * od.UnitPrice) AS TotalSales
FROM order_details_corrected AS od
JOIN products_corrected AS p
    ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalSales DESC;


/*====================================================================
TASK 10 : HIGH-VALUE CUSTOMERS
Purpose:
Calculate total customer spending and rank customers
according to their spending.
====================================================================*/

SELECT
    c.CustomerID,
    c.Name,
    SUM(CAST(o.OrderAmount AS DECIMAL(10,2))) AS TotalSpending,
    RANK() OVER
    (
        ORDER BY SUM(CAST(o.OrderAmount AS DECIMAL(10,2))) DESC
    ) AS SpendingRank
FROM customers AS c
JOIN orders_corrected AS o
    ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID,
    c.Name;


/*====================================================================
TASK 11 : REVENUE PER ORDER
Purpose:
Calculate the total revenue generated by each order.
====================================================================*/

SELECT
    o.OrderID,
    SUM(od.Quantity * od.UnitPrice) AS TotalRevenue
FROM orders_corrected AS o
JOIN order_details_corrected AS od
    ON o.OrderID = od.OrderID
GROUP BY o.OrderID;


/*====================================================================
TASK 11 : CUSTOMERS WITH MAXIMUM ORDERS
Purpose:
Identify customers who have placed the highest number of orders.
====================================================================*/

SELECT
    c.CustomerID,
    c.Name,
    COUNT(o.OrderID) AS TotalOrders
FROM customers AS c
JOIN orders_corrected AS o
    ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID,
    c.Name
ORDER BY TotalOrders DESC;


/*====================================================================
TASK 11 : SUPPLIER WITH HIGHEST STOCK
Purpose:
Identify the supplier associated with the highest total
product stock.
====================================================================*/

SELECT
    s.SupplierName,
    SUM(p.StockQuantity) AS TotalStock
FROM suppliers_corrected AS s
JOIN products_corrected AS p
    ON s.SupplierID = p.SupplierID
GROUP BY s.SupplierName
ORDER BY TotalStock DESC
LIMIT 1;


/*====================================================================
TASK 12 : DATABASE NORMALISATION
Purpose:
Create a separate Categories table to reduce category
redundancy and improve database structure.
====================================================================*/

CREATE TABLE Categories
(
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100),
    SubCategoryName VARCHAR(100)
);


/* Add CategoryID to Products table */

ALTER TABLE products_corrected
ADD CategoryID INT;


/* Establish relationship between Products and Categories */

ALTER TABLE products_corrected
ADD CONSTRAINT fk_category
FOREIGN KEY (CategoryID)
REFERENCES Categories(CategoryID);


/*====================================================================
TASK 13 : TOP 3 PRODUCTS BY REVENUE
Purpose:
Identify the three products generating the highest revenue.
====================================================================*/

SELECT
    ProductName,
    Revenue
FROM
(
    SELECT
        p.ProductName,
        SUM(od.Quantity * od.UnitPrice) AS Revenue
    FROM order_details_corrected AS od
    JOIN products_corrected AS p
        ON od.ProductID = p.ProductID
    GROUP BY p.ProductName
) AS x
ORDER BY Revenue DESC
LIMIT 3;


/*====================================================================
TASK 13 : CUSTOMERS WITHOUT ORDERS
Purpose:
Identify customers who have registered but have never
placed an order.
====================================================================*/

SELECT
    CustomerID,
    Name
FROM customers
WHERE CustomerID NOT IN
(
    SELECT CustomerID
    FROM orders_corrected
);


/*====================================================================
TASK 14 : PRIME MEMBERS BY CITY
Purpose:
Identify cities having the highest number of Prime members.
====================================================================*/

SELECT
    City,
    COUNT(*) AS PrimeMembers
FROM customers
WHERE PrimeMember = 'Yes'
GROUP BY City
ORDER BY PrimeMembers DESC;


/*====================================================================
TASK 14 : TOP ORDERED CATEGORIES
Purpose:
Identify the three most frequently ordered product categories.
====================================================================*/

SELECT
    c.CategoryName,
    SUM(od.Quantity) AS TotalOrders
FROM order_details_corrected AS od
JOIN products_corrected AS p
    ON od.ProductID = p.ProductID
JOIN categories AS c
    ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY TotalOrders DESC
LIMIT 3;


/*====================================================================
                         END OF PROJECT
====================================================================*/