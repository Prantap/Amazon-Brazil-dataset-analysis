ALTER DATABASE amazon_analysis SET datestyle = 'DMY';

UPDATE order_items
SET price = ROUND(price::numeric)::integer;

--"ANALYSIS-1"
--1. To simplify its financial reports, Amazon India needs to standardize payment values.
--Round the average payment values to integer (no decimal) for each payment type and 
--display the results sorted in ascending order.
--Output: payment_type, rounded_avg_payment

SELECT 
    payment_type,
    ROUND(AVG(payment_value)) AS rounded_avg_payment
FROM payments
GROUP BY payment_type
ORDER BY rounded_avg_payment ASC;

--2.To refine its payment strategy, Amazon India wants to know the distribution of 
--orders by payment type. Calculate the percentage of total orders for each payment 
--type, rounded to one decimal place, and display them in descending order 
--Output: payment_type, percentage_orders

SELECT 
    payment_type,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS percentage_orders
FROM payments
GROUP BY payment_type
ORDER BY percentage_orders DESC;

--3.Amazon India seeks to create targeted promotions for products within specific price ranges. Identify all products priced between 100 and 500 BRL that contain the word 'Smart' in their name. Display these products, sorted by price in descending order.
--Output: product_id, price
SELECT 
    oi.product_id,
    oi.price
FROM order_items oi
JOIN product p 
    ON oi.product_id = p.product_id
WHERE oi.price BETWEEN 100 AND 500
  AND p.product_category_name ILIKE '%Smart%'
ORDER BY oi.price DESC;


--4.To identify seasonal sales patterns, Amazon India needs to focus on the most successful months. Determine the top 3 months with the highest total sales value, rounded to the nearest integer.
--Output: month, total_sales
SELECT 
    TO_CHAR(order_purchase_timestamp, 'YYYY-MM') AS month,
    ROUND(SUM(oi.price)) AS total_sales
FROM orders o
JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY TO_CHAR(order_purchase_timestamp, 'YYYY-MM')
ORDER BY total_sales DESC
LIMIT 3;


--5.Amazon India is interested in product categories with significant price variations. Find categories where the difference between the maximum and minimum product prices is greater than 500 BRL.
--Output: product_category_name, price_difference
SELECT 
    p.product_category_name,
    (MAX(oid.price) - MIN(oid.price)) AS price_difference
FROM order_items oid
JOIN product p 
    ON oid.product_id = p.product_id
GROUP BY p.product_category_name
HAVING (MAX(oid.price) - MIN(oid.price)) > 500
ORDER BY price_difference DESC;

--6.To enhance the customer experience, Amazon India wants to find which payment types have the most consistent transaction amounts. Identify the payment types with the least variance in transaction amounts, sorting by the smallest standard deviation first.
--Output: payment_type, std_deviation
SELECT 
    payment_type,
    ROUND(STDDEV(payment_value), 2) AS std_deviation
FROM payments
GROUP BY payment_type
ORDER BY std_deviation ASC;

--7.Amazon India wants to identify products that may have incomplete name in order to fix it from their end. Retrieve the list of products where the product category name is missing or contains only a single character.
--Output: product_id, product_category_name
SELECT 
    product_id, 
    product_category_name
FROM product
WHERE product_category_name IS NULL
OR LENGTH(product_category_name) = 1;

--"ANALYSIS-2"
--1.Amazon India wants to understand which payment types are most popular across different order value segments (e.g., low, medium, high). Segment order values into three ranges: orders less than 200 BRL, between 200 and 1000 BRL, and over 1000 BRL. Calculate the count of each payment type within these ranges and display the results in descending order of count 
--Output: order_value_segment, payment_type, count
SELECT 
    CASE 
        WHEN oi.price < 200 THEN 'Low (<200 BRL)'
        WHEN oi.price BETWEEN 200 AND 1000 THEN 'Medium (200-1000 BRL)'
        ELSE 'High (>1000 BRL)'
    END AS order_value_segment,
    p.payment_type,
    COUNT(*) AS count
FROM order_items oi
JOIN payments p ON oi.order_id = p.order_id
GROUP BY order_value_segment, p.payment_type
ORDER BY count DESC;

--2.Output: order_value_segment, payment_type, count Amazon India wants to analyse the price range and average price for each product category. Calculate the minimum, maximum, and average price for each category, and list them in descending order by the average price. 
--Output: product_category_name, min_price, max_price, avg_price
SELECT 
    pr.product_category_name,
    MIN(oi.price) AS min_price,
    MAX(oi.price) AS max_price,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items oi
JOIN product pr ON oi.product_id = pr.product_id
GROUP BY pr.product_category_name
ORDER BY avg_price DESC;

--3.Amazon India wants to identify the customers who have placed multiple orders over time. Find all customers with more than one order, and display their customer unique IDs along with the total number of orders they have placed. 
--Output: customer_unique_id, total_orders 
SELECT 
    o.customer_id AS customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM orders o
GROUP BY o.customer_id
HAVING COUNT(o.order_id) > 1;


--4.Amazon India wants to categorize customers into different types ('New – order qty. = 1' ; 'Returning' –order qty. 2 to 4; 'Loyal' – order qty. >4) based on their purchase history. Use a temporary table to define these categories and join it with the customers table to update and display the customer types. 
--Output: customer_unique_id, customer_type 
WITH customer_categories AS (
    SELECT 
        customer_id AS customer_unique_id,
        COUNT(order_id) AS total_orders,
        CASE 
            WHEN COUNT(order_id) = 1 THEN 'New'
            WHEN COUNT(order_id) BETWEEN 2 AND 4 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_type
    FROM orders GROUP BY customer_id
)
SELECT *
FROM customer_categories;


--5.Amazon India wants to know which product categories generate the most revenue. Use joins between the tables to calculate the total revenue for each product category. Display the top 5 categories. 
--Output: product_category_name, total_revenue
SELECT 
    pr.product_category_name,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM order_items oi
JOIN product pr ON oi.product_id = pr.product_id
GROUP BY pr.product_category_name
ORDER BY total_revenue DESC LIMIT 5;

--ANALYSIS-3
--1. The marketing team wants to compare the total sales between different seasons. Use a subquery to calculate total sales for each season (Spring, Summer, Autumn, Winter) based on order purchase dates, and display the results. Spring is in the months of March, April and May. Summer is from June to August and Autumn is between September and November and rest months are Winter. 
--Output: season, total_sales 
SELECT season, SUM(total_sales) AS total_sales
FROM (
    SELECT 
        CASE 
            WHEN EXTRACT(MONTH FROM order_purchase_timestamp) IN (3,4,5) THEN 'Spring'
            WHEN EXTRACT(MONTH FROM order_purchase_timestamp) IN (6,7,8) THEN 'Summer'
            WHEN EXTRACT(MONTH FROM order_purchase_timestamp) IN (9,10,11) THEN 'Autumn'
            ELSE 'Winter'
        END AS season,
        (oi.price + oi.freight_value) AS total_sales
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id) sub GROUP BY season;

--2.The inventory team is interested in identifying products that have sales volumes above the overall average. Write a query that uses a subquery to filter products with a total quantity sold above the average quantity. 
--Output: product_id, total_quantity_sold 
SELECT 
    oi.product_id,
    SUM(oi.order_item_id) AS total_quantity_sold
FROM order_items oi GROUP BY oi.product_id HAVING SUM(oi.order_item_id) > (
    SELECT AVG(product_sales) 
    FROM (
        SELECT SUM(order_item_id) AS product_sales
        FROM order_items
        GROUP BY product_id
    ) avg_sub
);


--3.To understand seasonal sales patterns, the finance team is analysing the monthly revenue trends over the past year (year 2018). Run a query to calculate total revenue generated each month and identify periods of peak and low sales. Export the data to Excel and create a graph to visually represent revenue changes across the months. 
--Output: month, total_revenue 
SELECT 
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS month,
    ROUND(SUM(oi.price + oi.freight_value),2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
GROUP BY TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM')
ORDER BY month;


--4.A loyalty program is being designed for Amazon India. Create a segmentation based on purchase frequency: ‘Occasional’ for customers with 1-2 orders, ‘Regular’ for 3-5 orders, and ‘Loyal’ for more than 5 orders. Use a CTE to classify customers and their count and generate a chart in Excel to show the proportion of each segment. 
--Output: customer_type, count 
WITH customer_segments AS (
    SELECT 
        o.customer_id,
        COUNT(o.order_id) AS total_orders,
        CASE 
            WHEN COUNT(o.order_id) BETWEEN 1 AND 2 THEN 'Occasional'
            WHEN COUNT(o.order_id) BETWEEN 3 AND 5 THEN 'Regular'
            ELSE 'Loyal'
        END AS customer_type FROM orders o GROUP BY o.customer_id
)
SELECT customer_type, COUNT(*) AS count FROM customer_segments GROUP BY customer_type;


--5.Amazon wants to identify high-value customers to target for an exclusive rewards program. You are required to rank customers based on their average order value (avg_order_value) to find the top 20 customers. 
--Output: customer_id, avg_order_value, and customer_rank 
SELECT 
    customer_id,
    ROUND(AVG(oi.price + oi.freight_value),2) AS avg_order_value,
    RANK() OVER (ORDER BY AVG(oi.price + oi.freight_value) DESC) AS customer_rank
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id GROUP BY customer_id
ORDER BY customer_rank LIMIT 20;


--6.Amazon wants to analyze sales growth trends for its key products over their lifecycle. Calculate monthly cumulative sales for each product from the date of its first sale. Use a recursive CTE to compute the cumulative sales (total_sales) for each product month by month. 
--Output: product_id, sale_month, and total_sales


--7.To understand how different payment methods affect monthly sales growth, Amazon wants to compute the total sales for each payment method and calculate the month-over-month growth rate for the past year (year 2018). Write query to first calculate total monthly sales for each payment method, then compute the percentage change from the previous month. 
--Output: payment_type, sale_month, monthly_total, monthly_change.