-- Performance Optimization Indexes for Online Shopping System
-- Creating indexes to improve query performance

USE online_shopping;

-- =============================================
-- Drop existing indexes if they exist (except primary keys and foreign keys)
-- =============================================

-- Note: Some indexes are already created in the schema.sql file
-- This file adds additional performance indexes

-- =============================================
-- Products Table Indexes
-- =============================================

-- Composite index for product search by category and price range
CREATE INDEX idx_products_category_price ON Products(category_id, price);

-- Index for active products with stock
CREATE INDEX idx_products_active_stock ON Products(is_active, stock_quantity);

-- Full-text search index for product names and descriptions
ALTER TABLE Products ADD FULLTEXT(product_name, description);

-- Index for SKU lookups (if not already unique)
-- CREATE INDEX idx_products_sku ON Products(sku); -- Already created as unique

-- Composite index for product listing queries
CREATE INDEX idx_products_listing ON Products(is_active, category_id, price, stock_quantity);

-- =============================================
-- Orders Table Indexes
-- =============================================

-- Composite index for order reporting queries
CREATE INDEX idx_orders_date_status ON Orders(order_date, order_status);

-- Index for customer order history
CREATE INDEX idx_orders_customer_date ON Orders(customer_id, order_date);

-- Index for payment status queries
CREATE INDEX idx_orders_payment_status ON Orders(payment_status, order_date);

-- Composite index for order analysis
CREATE INDEX idx_orders_status_payment_total ON Orders(order_status, payment_status, total_amount);

-- Index for order date range queries
CREATE INDEX idx_orders_date_range ON Orders(order_date, total_amount);

-- =============================================
-- Order_Details Table Indexes
-- =============================================

-- Composite index for product sales analysis
CREATE INDEX idx_order_details_product_order ON Order_Details(product_id, order_id);

-- Index for order line item queries
CREATE INDEX idx_order_details_order_product ON Order_Details(order_id, product_id, quantity);

-- Index for product quantity analysis
CREATE INDEX idx_order_details_product_qty ON Order_Details(product_id, quantity, unit_price);

-- =============================================
-- Customers Table Indexes
-- =============================================

-- Composite index for customer search
CREATE INDEX idx_customers_name_email ON Customers(last_name, first_name, email);

-- Index for active customers
CREATE INDEX idx_customers_active ON Customers(is_active, registration_date);

-- Index for customer location queries
CREATE INDEX idx_customers_location ON Customers(city, state, country);

-- Index for customer registration analysis
CREATE INDEX idx_customers_registration ON Customers(registration_date, is_active);

-- =============================================
-- Inventory_Log Table Indexes
-- =============================================

-- Composite index for inventory tracking
CREATE INDEX idx_inventory_product_date ON Inventory_Log(product_id, created_at);

-- Index for change type analysis
CREATE INDEX idx_inventory_change_type ON Inventory_Log(change_type, created_at);

-- Index for reference tracking
CREATE INDEX idx_inventory_reference ON Inventory_Log(reference_id, change_type);

-- Composite index for inventory reports
CREATE INDEX idx_inventory_product_type_date ON Inventory_Log(product_id, change_type, created_at);

-- =============================================
-- Categories Table Indexes
-- =============================================

-- Index for category name searches
CREATE INDEX idx_categories_name ON Categories(category_name);

-- =============================================
-- Product_Reviews Table Indexes
-- =============================================

-- Composite index for product review queries
CREATE INDEX idx_reviews_product_rating ON Product_Reviews(product_id, rating, review_date);

-- Index for customer reviews
CREATE INDEX idx_reviews_customer ON Product_Reviews(customer_id, review_date);

-- Index for verified reviews
CREATE INDEX idx_reviews_verified ON Product_Reviews(is_verified, rating, review_date);

-- =============================================
-- Shopping_Cart Table Indexes
-- =============================================

-- Index for cart queries by customer
CREATE INDEX idx_cart_customer_date ON Shopping_Cart(customer_id, added_date);

-- Index for product in cart analysis
CREATE INDEX idx_cart_product ON Shopping_Cart(product_id, added_date);

-- =============================================
-- Advanced Composite Indexes for Complex Queries
-- =============================================

-- Index for sales reporting queries
CREATE INDEX idx_sales_analysis ON Orders(order_date, order_status, customer_id, total_amount);

-- Index for product performance analysis
CREATE INDEX idx_product_performance ON Order_Details(product_id, quantity, unit_price, order_id);

-- Index for customer behavior analysis
CREATE INDEX idx_customer_behavior ON Orders(customer_id, order_date, total_amount, order_status);

-- Index for inventory management
CREATE INDEX idx_inventory_management ON Products(stock_quantity, is_active, category_id, updated_at);

-- =============================================
-- Covering Indexes for Specific Query Patterns
-- =============================================

-- Covering index for product listing with all needed columns
CREATE INDEX idx_product_listing_cover ON Products(category_id, is_active, product_id, product_name, price, stock_quantity);

-- Covering index for order summary queries
CREATE INDEX idx_order_summary_cover ON Orders(order_date, order_status, order_id, customer_id, total_amount);

-- =============================================
-- Function-based Indexes (MySQL 8.0+)
-- =============================================

-- Index for date-based queries (year, month)
CREATE INDEX idx_orders_year_month ON Orders((YEAR(order_date)), (MONTH(order_date)));

-- Index for customer name search (full name)
CREATE INDEX idx_customers_full_name ON Customers((CONCAT(first_name, ' ', last_name)));

-- =============================================
-- Analyze Table Statistics
-- =============================================

-- Update table statistics for the optimizer
ANALYZE TABLE Products;
ANALYZE TABLE Orders;
ANALYZE TABLE Order_Details;
ANALYZE TABLE Customers;
ANALYZE TABLE Categories;
ANALYZE TABLE Inventory_Log;
ANALYZE TABLE Product_Reviews;
ANALYZE TABLE Shopping_Cart;

-- =============================================
-- Display Index Information
-- =============================================

SELECT 'Performance Indexes Created Successfully!' AS Status;

-- Show all indexes for each table
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX,
    INDEX_TYPE
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'online_shopping'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- =============================================
-- Index Usage Guidelines
-- =============================================

SELECT '
INDEX USAGE GUIDELINES:

1. Product Searches:
   - Use idx_products_category_price for category + price range queries
   - Use FULLTEXT index for product name/description searches
   - Use idx_products_active_stock for available product queries

2. Order Queries:
   - Use idx_orders_customer_date for customer order history
   - Use idx_orders_date_status for order reporting
   - Use idx_orders_date_range for date range analysis

3. Sales Analysis:
   - Use idx_order_details_product_order for product sales data
   - Use idx_sales_analysis for comprehensive sales reports

4. Inventory Management:
   - Use idx_inventory_product_date for stock movement tracking
   - Use idx_inventory_management for current stock status

5. Customer Analysis:
   - Use idx_customers_name_email for customer searches
   - Use idx_customer_behavior for purchase pattern analysis

Performance Tips:
- Always include indexed columns in WHERE clauses
- Use EXPLAIN to verify index usage
- Monitor slow query log for optimization opportunities
- Update table statistics regularly using ANALYZE TABLE
' AS Guidelines;
