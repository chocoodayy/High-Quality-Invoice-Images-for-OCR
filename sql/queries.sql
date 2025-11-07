-- SQL Queries để extract dữ liệu phục vụ phân tích
-- Người phụ trách: Người 1 - Data Engineer

USE foodpanda_db;

-- 1. Tổng hợp đơn hàng theo ngày
SELECT * FROM vw_daily_orders
ORDER BY order_date DESC
LIMIT 30;

-- 2. Top 10 nhà hàng có doanh thu cao nhất
SELECT * FROM vw_restaurant_stats
LIMIT 10;

-- 3. Top 10 khách hàng chi tiêu nhiều nhất
SELECT * FROM vw_customer_stats
LIMIT 10;

-- 4. Thống kê theo thành phố
SELECT 
    city,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(price) AS total_revenue,
    AVG(price) AS avg_order_value
FROM foodpanda_orders
GROUP BY city
ORDER BY total_revenue DESC;

-- 5. Thống kê theo phương thức thanh toán
SELECT 
    payment_method,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(price) AS total_revenue,
    AVG(price) AS avg_order_value
FROM foodpanda_orders
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- 6. Tỷ lệ khách hàng churned
SELECT 
    churned,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(COUNT(DISTINCT customer_id) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM foodpanda_orders), 2) AS percentage
FROM foodpanda_orders
GROUP BY churned;

-- 7. Thống kê theo category món ăn
SELECT 
    category,
    COUNT(*) AS total_items,
    SUM(quantity) AS total_quantity,
    SUM(price) AS total_revenue,
    AVG(price) AS avg_price
FROM foodpanda_orders
GROUP BY category
ORDER BY total_revenue DESC;

-- 8. Thống kê delivery status
SELECT 
    delivery_status,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM foodpanda_orders), 2) AS percentage
FROM foodpanda_orders
GROUP BY delivery_status
ORDER BY count DESC;

-- 9. Phân tích rating
SELECT 
    rating,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM foodpanda_orders WHERE rating IS NOT NULL), 2) AS percentage
FROM foodpanda_orders
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY rating DESC;

-- 10. Khách hàng có loyalty points cao nhất
SELECT 
    customer_id,
    city,
    loyalty_points,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(price) AS total_spent
FROM foodpanda_orders
GROUP BY customer_id, city, loyalty_points
ORDER BY loyalty_points DESC
LIMIT 20;

