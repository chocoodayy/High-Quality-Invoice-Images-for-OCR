-- Database Schema cho Foodpanda Analytics Project
-- Người phụ trách: Người 1 - Data Engineer

-- Tạo database (nếu chưa tồn tại)
CREATE DATABASE IF NOT EXISTS foodpanda_db;
USE foodpanda_db;

-- Bảng chính lưu trữ dữ liệu orders từ CSV
CREATE TABLE IF NOT EXISTS foodpanda_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Thông tin khách hàng
    customer_id VARCHAR(50) NOT NULL,
    gender VARCHAR(20),
    age VARCHAR(20),
    city VARCHAR(100),
    signup_date DATE,
    
    -- Thông tin đơn hàng
    order_id VARCHAR(50) NOT NULL,
    order_date DATE,
    restaurant_name VARCHAR(255),
    dish_name VARCHAR(255),
    category VARCHAR(100),
    quantity INT,
    price DECIMAL(10, 2),
    payment_method VARCHAR(50),
    
    -- Thông tin khách hàng thân thiết
    order_frequency INT,
    last_order_date DATE,
    loyalty_points INT DEFAULT 0,
    churned VARCHAR(20),
    
    -- Đánh giá và giao hàng
    rating INT,
    rating_date DATE,
    delivery_status VARCHAR(50),
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes để tối ưu query
    INDEX idx_customer_id (customer_id),
    INDEX idx_order_id (order_id),
    INDEX idx_order_date (order_date),
    INDEX idx_restaurant_name (restaurant_name),
    INDEX idx_city (city),
    INDEX idx_delivery_status (delivery_status),
    INDEX idx_churned (churned)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- View: Tổng hợp đơn hàng theo ngày
CREATE OR REPLACE VIEW vw_daily_orders AS
SELECT 
    order_date,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(*) AS total_items,
    SUM(price) AS total_revenue,
    AVG(price) AS avg_order_value
FROM foodpanda_orders
GROUP BY order_date
ORDER BY order_date DESC;

-- View: Thống kê theo nhà hàng
CREATE OR REPLACE VIEW vw_restaurant_stats AS
SELECT 
    restaurant_name,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(quantity) AS total_items_sold,
    SUM(price) AS total_revenue,
    AVG(price) AS avg_order_value,
    AVG(rating) AS avg_rating
FROM foodpanda_orders
GROUP BY restaurant_name
ORDER BY total_revenue DESC;

-- View: Thống kê khách hàng
CREATE OR REPLACE VIEW vw_customer_stats AS
SELECT 
    customer_id,
    gender,
    age,
    city,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(price) AS total_spent,
    AVG(price) AS avg_order_value,
    MAX(order_date) AS last_order_date,
    loyalty_points,
    churned
FROM foodpanda_orders
GROUP BY customer_id, gender, age, city, loyalty_points, churned
ORDER BY total_spent DESC;

