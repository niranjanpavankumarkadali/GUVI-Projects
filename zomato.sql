/*=========================================================
        ZOMATO ORDER & RESTAURANT ANALYSIS PROJECT
=========================================================*/

-- =====================================================
-- Create Database
-- =====================================================

CREATE DATABASE ZomatoDB;
USE ZomatoDB;

-- =====================================================
-- Task 1 : Identify Duplicate Restaurants
-- =====================================================

SELECT restaurant_id,
COUNT(*)
FROM Zomato_Restaurants
GROUP BY restaurant_id
HAVING COUNT(*) > 1;

-- Display Duplicate Records

SELECT *
FROM Zomato_Restaurants
WHERE restaurant_id IN
(
SELECT restaurant_id
FROM Zomato_Restaurants
GROUP BY restaurant_id
HAVING COUNT(*) > 1
);

-- =====================================================
-- Task 2 : Handle Missing Customer Ratings
-- =====================================================

UPDATE Zomato_Orders
SET customer_rating = 0
WHERE customer_rating IS NULL;

-- =====================================================
-- Task 3 : Handle Missing Delivery Time
-- =====================================================

UPDATE Zomato_Orders
SET delivery_time = 30
WHERE delivery_time IS NULL;

-- =====================================================
-- Task 4 : Restaurant Distribution by City
-- =====================================================

SELECT city,
COUNT(*) AS total_restaurants
FROM Zomato_Restaurants
GROUP BY city;

-- =====================================================
-- Task 5 : Top Cities by Total Orders
-- =====================================================

SELECT
r.city,
COUNT(o.order_id) AS total_orders
FROM Zomato_Orders o
JOIN Zomato_Restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY total_orders DESC
LIMIT 5;

-- =====================================================
-- Task 6 : Restaurant Revenue Analysis
-- =====================================================

SELECT
restaurant_id,
SUM(total_cost) AS total_revenue
FROM Zomato_Orders
GROUP BY restaurant_id;

-- =====================================================
-- Task 7 : Average Order Value by City
-- =====================================================

SELECT
r.city,
AVG(o.total_cost) AS avg_order_amount
FROM Zomato_Orders o
JOIN Zomato_Restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY r.city;

-- =====================================================
-- Task 8 : Top Restaurants by Sales
-- =====================================================

SELECT
r.restaurant_name,
SUM(o.total_cost) AS total_sales
FROM Zomato_Orders o
JOIN Zomato_Restaurants r
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_sales DESC;

-- =====================================================
-- Task 9 : Final Dataset for Power BI
-- =====================================================

SELECT
o.order_id,
o.restaurant_id,
r.restaurant_name,
r.city,
r.area,
r.cuisine,
o.order_date,
o.delivery_time,
o.total_cost,
o.item_count,
o.payment_method,
o.customer_rating
FROM Zomato_Orders o
JOIN Zomato_Restaurants r
ON o.restaurant_id = r.restaurant_id
LIMIT 5;