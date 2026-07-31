USE retail_supply_chain;

-- ==========================================================
-- BUSINESS QUERIES
-- Retail Supply Chain Intelligence Platform
-- ==========================================================

/*
==============================================================
SECTION 1 : SALES & REVENUE ANALYSIS
==============================================================
*/

-- 1. Total Revenue Generated

SELECT
    ROUND(SUM(oi.price),2) AS total_revenue
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_status='delivered';


-- 2. Monthly Revenue Trend

SELECT
    DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m') AS month,
    ROUND(SUM(oi.price),2) AS monthly_revenue
FROM orders o
JOIN order_items oi
ON o.order_id=oi.order_id
WHERE o.order_status='delivered'
GROUP BY month
ORDER BY month;


-- 3. Average Order Value

SELECT
    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT oi.order_id),2
    ) AS average_order_value
FROM order_items oi
JOIN orders o
ON oi.order_id=o.order_id
WHERE o.order_status='delivered';


-- 4. Top 10 Revenue Generating Products

SELECT
    product_id,
    ROUND(SUM(price),2) AS revenue
FROM order_items
GROUP BY product_id
ORDER BY revenue DESC
LIMIT 10;


-- 5. Top 10 Revenue Generating Sellers

SELECT
    seller_id,
    ROUND(SUM(price),2) AS revenue
FROM order_items
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10;



/*
==============================================================
SECTION 2 : CUSTOMER ANALYSIS
==============================================================
*/


-- 6. Total Customers

SELECT
    COUNT(*) AS total_customers
FROM customers;


-- 7. Repeat Customers

SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(o.order_id)>1
ORDER BY total_orders DESC;


-- 8. Top 10 Customer Cities

SELECT
    customer_city,
    COUNT(*) AS customers
FROM customers
GROUP BY customer_city
ORDER BY customers DESC
LIMIT 10;


-- 9. Top 10 Customer States

SELECT
    customer_state,
    COUNT(*) AS customers
FROM customers
GROUP BY customer_state
ORDER BY customers DESC
LIMIT 10;


-- 10. Monthly Customer Growth

SELECT
    DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS month,
    COUNT(DISTINCT customer_id) AS new_customers
FROM orders
GROUP BY month
ORDER BY month;



/*
==============================================================
SECTION 3 : ORDER & DELIVERY ANALYSIS
==============================================================
*/


-- 11. Order Status Distribution

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 12. Average Delivery Time

SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),2
    ) AS average_delivery_days
FROM orders
WHERE order_status='delivered';


-- 13. Late Deliveries

SELECT
    COUNT(*) AS late_deliveries
FROM orders
WHERE order_delivered_customer_date >
      order_estimated_delivery_date;


-- 14. On-Time Delivery Percentage

SELECT
ROUND(
SUM(
CASE
WHEN order_delivered_customer_date <= order_estimated_delivery_date
THEN 1
ELSE 0
END
)*100.0/COUNT(*),2
) AS on_time_delivery_percentage
FROM orders
WHERE order_status='delivered';


-- 15. Monthly Order Trend

SELECT
DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS month,
COUNT(*) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;



/*
==============================================================
SECTION 4 : PAYMENT ANALYSIS
==============================================================
*/


-- 16. Payment Method Distribution

SELECT
payment_type,
COUNT(*) AS total_transactions
FROM payments
GROUP BY payment_type
ORDER BY total_transactions DESC;


-- 17. Revenue by Payment Type

SELECT
payment_type,
ROUND(SUM(payment_value),2) AS revenue
FROM payments
GROUP BY payment_type
ORDER BY revenue DESC;


-- 18. Average Payment Value

SELECT
ROUND(
AVG(payment_value),2
) AS average_payment
FROM payments;


-- 19. Average Installments Used

SELECT
ROUND(
AVG(payment_installments),2
) AS average_installments
FROM payments;


-- 20. Highest Value Orders

SELECT
order_id,
payment_value
FROM payments
ORDER BY payment_value DESC
LIMIT 10;



/*
==============================================================
SECTION 5 : CUSTOMER SATISFACTION
==============================================================
*/


-- 21. Average Review Score

SELECT
ROUND(
AVG(review_score),2
) AS average_rating
FROM reviews;


-- 22. Review Score Distribution

SELECT
review_score,
COUNT(*) AS total_reviews
FROM reviews
GROUP BY review_score
ORDER BY review_score DESC;


-- 23. Delivery Time vs Review Score

SELECT
r.review_score,
ROUND(
AVG(
DATEDIFF(
o.order_delivered_customer_date,
o.order_purchase_timestamp
)
),2
) AS average_delivery_days
FROM reviews r
JOIN orders o
ON r.order_id=o.order_id
WHERE o.order_status='delivered'
GROUP BY r.review_score
ORDER BY r.review_score DESC;


-- 24. Monthly Average Rating

SELECT
DATE_FORMAT(
o.order_purchase_timestamp,
'%Y-%m'
) AS month,
ROUND(
AVG(r.review_score),2
) AS average_rating
FROM reviews r
JOIN orders o
ON r.order_id=o.order_id
GROUP BY month
ORDER BY month;


-- 25. Orders with Low Ratings

SELECT
r.order_id,
r.review_score,
o.order_status
FROM reviews r
JOIN orders o
ON r.order_id=o.order_id
WHERE r.review_score <=2
ORDER BY r.review_score;