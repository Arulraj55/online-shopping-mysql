-- =============================================
-- MariaDB Compatible Indexes for Online Shopping System
-- =============================================

-- Basic Performance Indexes
-- =============================================

-- Primary key indexes (automatically created)
-- Products, Customers, Orders, Order_Details, Categories, Inventory_Log

-- Foreign Key Indexes
-- =============================================
CREATE INDEX idx_products_category ON Products(category_id);
CREATE INDEX idx_orders_customer ON Orders(customer_id);
CREATE INDEX idx_order_details_order ON Order_Details(order_id);
CREATE INDEX idx_order_details_product ON Order_Details(product_id);
CREATE INDEX idx_inventory_log_product ON Inventory_Log(product_id);
CREATE INDEX idx_product_reviews_product ON Product_Reviews(product_id);
CREATE INDEX idx_product_reviews_customer ON Product_Reviews(customer_id);
CREATE INDEX idx_shopping_cart_customer ON Shopping_Cart(customer_id);
CREATE INDEX idx_shopping_cart_product ON Shopping_Cart(product_id);

-- Search and Filter Indexes
-- =============================================

-- Product search optimization
CREATE INDEX idx_products_name ON Products(product_name);
CREATE INDEX idx_products_price ON Products(price);
CREATE INDEX idx_products_stock ON Products(stock_quantity);
CREATE INDEX idx_products_active ON Products(is_active);

-- Customer search
CREATE INDEX idx_customers_email ON Customers(email);
CREATE INDEX idx_customers_name ON Customers(first_name, last_name);

-- Order management indexes
CREATE INDEX idx_orders_date ON Orders(order_date);
CREATE INDEX idx_orders_status ON Orders(status);
CREATE INDEX idx_orders_total ON Orders(total_amount);

-- Inventory tracking
CREATE INDEX idx_inventory_log_date ON Inventory_Log(created_at);
CREATE INDEX idx_inventory_log_type ON Inventory_Log(change_type);

-- Composite Indexes for Complex Queries
-- =============================================

-- Products by category and stock
CREATE INDEX idx_products_category_stock ON Products(category_id, stock_quantity);

-- Orders by customer and date
CREATE INDEX idx_orders_customer_date ON Orders(customer_id, order_date);

-- Active products with stock
CREATE INDEX idx_products_active_stock ON Products(is_active, stock_quantity);

-- Order details for reporting
CREATE INDEX idx_order_details_order_product ON Order_Details(order_id, product_id);

-- Date-based Indexes (MariaDB Compatible)
-- =============================================

-- For monthly/yearly reports - using DATE function instead of YEAR/MONTH
CREATE INDEX idx_orders_date_only ON Orders((DATE(order_date)));

-- Full-text Search Indexes
-- =============================================

-- Product search (name and description)
CREATE FULLTEXT INDEX idx_products_fulltext ON Products(product_name, description);

-- Customer search
CREATE FULLTEXT INDEX idx_customers_fulltext ON Customers(first_name, last_name);

-- Performance Monitoring Indexes
-- =============================================

-- For analytics and reporting
CREATE INDEX idx_products_price_range ON Products(price, category_id);
CREATE INDEX idx_orders_amount_range ON Orders(total_amount, order_date);

-- Shopping cart optimization
CREATE INDEX idx_cart_customer_added ON Shopping_Cart(customer_id, added_at);

-- Review system optimization
CREATE INDEX idx_reviews_product_rating ON Product_Reviews(product_id, rating);
CREATE INDEX idx_reviews_date ON Product_Reviews(review_date);

-- =============================================
-- Index Usage Examples
-- =============================================

/*
-- These indexes optimize the following common queries:

-- 1. Product catalog with filters
SELECT * FROM Products 
WHERE category_id = 1 AND stock_quantity > 0 AND is_active = TRUE
ORDER BY product_name;

-- 2. Customer order history
SELECT * FROM Orders 
WHERE customer_id = 101 
ORDER BY order_date DESC;

-- 3. Sales reports by date range
SELECT DATE(order_date) as sale_date, SUM(total_amount) as daily_sales
FROM Orders 
WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY DATE(order_date);

-- 4. Low stock products
SELECT * FROM Products 
WHERE stock_quantity <= 5 AND is_active = TRUE
ORDER BY stock_quantity ASC;

-- 5. Product search
SELECT * FROM Products 
WHERE MATCH(product_name, description) AGAINST('laptop computer' IN NATURAL LANGUAGE MODE);
*/
