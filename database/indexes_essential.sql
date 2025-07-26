-- =============================================
-- ESSENTIAL Indexes Only (MariaDB Compatible)
-- Minimal set of most important indexes
-- =============================================

-- Essential Performance Indexes
-- =============================================

-- Order management (most important)
CREATE INDEX IF NOT EXISTS idx_orders_date_essential ON Orders(order_date);
CREATE INDEX IF NOT EXISTS idx_orders_status_essential ON Orders(order_status);
CREATE INDEX IF NOT EXISTS idx_orders_customer_essential ON Orders(customer_id);

-- Product management (most important)
CREATE INDEX IF NOT EXISTS idx_products_stock_essential ON Products(stock_quantity);
CREATE INDEX IF NOT EXISTS idx_products_active_essential ON Products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_category_essential ON Products(category_id);

-- Order details (most important)
CREATE INDEX IF NOT EXISTS idx_order_details_order_essential ON Order_Details(order_id);
CREATE INDEX IF NOT EXISTS idx_order_details_product_essential ON Order_Details(product_id);

-- Customer lookup (most important)
CREATE INDEX IF NOT EXISTS idx_customers_email_essential ON Customers(email);

-- Inventory tracking (most important)
CREATE INDEX IF NOT EXISTS idx_inventory_log_product_essential ON Inventory_Log(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_log_date_essential ON Inventory_Log(created_at);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_products_active_stock_essential ON Products(is_active, stock_quantity);
CREATE INDEX IF NOT EXISTS idx_orders_customer_date_essential ON Orders(customer_id, order_date);

-- =============================================
-- Verification
-- =============================================
SELECT 'Essential indexes created successfully' as status;
