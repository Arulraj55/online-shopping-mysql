-- =============================================
-- SAFE MariaDB Compatible Indexes
-- Only creates indexes if they don't already exist
-- =============================================

-- Check and create indexes safely
-- =============================================

-- Drop and recreate specific indexes if needed
-- Foreign Key Indexes
DROP INDEX IF EXISTS idx_products_category ON Products;
CREATE INDEX idx_products_category ON Products(category_id);

DROP INDEX IF EXISTS idx_orders_customer ON Orders;
CREATE INDEX idx_orders_customer ON Orders(customer_id);

DROP INDEX IF EXISTS idx_order_details_order ON Order_Details;
CREATE INDEX idx_order_details_order ON Order_Details(order_id);

DROP INDEX IF EXISTS idx_order_details_product ON Order_Details;
CREATE INDEX idx_order_details_product ON Order_Details(product_id);

-- Only create if Inventory_Log table exists and index doesn't exist
DROP INDEX IF EXISTS idx_inventory_log_product ON Inventory_Log;
CREATE INDEX idx_inventory_log_product ON Inventory_Log(product_id);

-- Search and Filter Indexes (with unique names)
-- =============================================

-- Product search optimization
DROP INDEX IF EXISTS idx_products_name_search ON Products;
CREATE INDEX idx_products_name_search ON Products(product_name);

DROP INDEX IF EXISTS idx_products_price_range ON Products;
CREATE INDEX idx_products_price_range ON Products(price);

DROP INDEX IF EXISTS idx_products_stock_level ON Products;
CREATE INDEX idx_products_stock_level ON Products(stock_quantity);

DROP INDEX IF EXISTS idx_products_active_status ON Products;
CREATE INDEX idx_products_active_status ON Products(is_active);

-- Customer search
DROP INDEX IF EXISTS idx_customers_email_search ON Customers;
CREATE INDEX idx_customers_email_search ON Customers(email);

DROP INDEX IF EXISTS idx_customers_name_search ON Customers;
CREATE INDEX idx_customers_name_search ON Customers(first_name, last_name);

-- Order management indexes (using correct column names)
DROP INDEX IF EXISTS idx_orders_date_search ON Orders;
CREATE INDEX idx_orders_date_search ON Orders(order_date);

DROP INDEX IF EXISTS idx_orders_status_search ON Orders;
CREATE INDEX idx_orders_status_search ON Orders(order_status);

DROP INDEX IF EXISTS idx_orders_payment_status ON Orders;
CREATE INDEX idx_orders_payment_status ON Orders(payment_status);

DROP INDEX IF EXISTS idx_orders_total_amount ON Orders;
CREATE INDEX idx_orders_total_amount ON Orders(total_amount);

-- Inventory tracking
DROP INDEX IF EXISTS idx_inventory_log_date_search ON Inventory_Log;
CREATE INDEX idx_inventory_log_date_search ON Inventory_Log(created_at);

DROP INDEX IF EXISTS idx_inventory_log_type_search ON Inventory_Log;
CREATE INDEX idx_inventory_log_type_search ON Inventory_Log(change_type);

-- Composite Indexes for Complex Queries
-- =============================================

-- Products by category and stock
DROP INDEX IF EXISTS idx_products_category_stock_comp ON Products;
CREATE INDEX idx_products_category_stock_comp ON Products(category_id, stock_quantity);

-- Orders by customer and date
DROP INDEX IF EXISTS idx_orders_customer_date_comp ON Orders;
CREATE INDEX idx_orders_customer_date_comp ON Orders(customer_id, order_date);

-- Active products with stock
DROP INDEX IF EXISTS idx_products_active_stock_comp ON Products;
CREATE INDEX idx_products_active_stock_comp ON Products(is_active, stock_quantity);

-- Order details for reporting
DROP INDEX IF EXISTS idx_order_details_order_product_comp ON Order_Details;
CREATE INDEX idx_order_details_order_product_comp ON Order_Details(order_id, product_id);

-- Order status and date for reports
DROP INDEX IF EXISTS idx_orders_status_date ON Orders;
CREATE INDEX idx_orders_status_date ON Orders(order_status, order_date);

-- Performance Monitoring Indexes
-- =============================================

-- For analytics and reporting
DROP INDEX IF EXISTS idx_products_price_category ON Products;
CREATE INDEX idx_products_price_category ON Products(price, category_id);

DROP INDEX IF EXISTS idx_orders_amount_date ON Orders;
CREATE INDEX idx_orders_amount_date ON Orders(total_amount, order_date);

-- Full-text Search Indexes (Optional - only if needed)
-- =============================================

-- Uncomment these if you want full-text search capability
-- DROP INDEX IF EXISTS idx_products_search_text ON Products;
-- CREATE FULLTEXT INDEX idx_products_search_text ON Products(product_name, description);

-- DROP INDEX IF EXISTS idx_customers_search_text ON Customers;
-- CREATE FULLTEXT INDEX idx_customers_search_text ON Customers(first_name, last_name);

-- Show created indexes for verification
SHOW INDEX FROM Products;
SHOW INDEX FROM Orders;
SHOW INDEX FROM Order_Details;
SHOW INDEX FROM Customers;
SHOW INDEX FROM Inventory_Log;
