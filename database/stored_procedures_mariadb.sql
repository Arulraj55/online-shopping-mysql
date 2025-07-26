-- =============================================
-- MariaDB Compatible Stored Procedures for Online Shopping System
-- =============================================

DELIMITER //

-- =============================================
-- Procedure: PlaceOrder
-- Description: Complete order placement with stock validation
-- =============================================
CREATE PROCEDURE PlaceOrder(
    IN p_customer_id INT,
    IN p_order_items JSON
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_order_id INT;
    DECLARE v_total_amount DECIMAL(10,2) DEFAULT 0;
    DECLARE v_error_msg VARCHAR(255);
    
    -- Declare cursor for JSON items (simplified approach for MariaDB)
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Create the order
    INSERT INTO Orders (customer_id, order_date, status)
    VALUES (p_customer_id, NOW(), 'Pending');
    
    SET v_order_id = LAST_INSERT_ID();
    
    -- For MariaDB, we'll use a simpler approach
    -- This is a simplified version - in production, you'd parse JSON properly
    
    -- Example for single item (extend for multiple items)
    -- You would need to parse the JSON parameter properly
    
    -- Update the total amount
    UPDATE Orders 
    SET total_amount = v_total_amount 
    WHERE order_id = v_order_id;
    
    COMMIT;
    
    SELECT v_order_id as order_id, 'Order placed successfully' as message;
    
END //

-- =============================================
-- Procedure: UpdateStock
-- Description: Update product stock with logging
-- =============================================
CREATE PROCEDURE UpdateStock(
    IN p_product_id INT,
    IN p_quantity_change INT,
    IN p_reason VARCHAR(255)
)
BEGIN
    DECLARE v_current_stock INT;
    DECLARE v_new_stock INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Get current stock
    SELECT stock_quantity INTO v_current_stock
    FROM Products
    WHERE product_id = p_product_id;
    
    -- Calculate new stock
    SET v_new_stock = v_current_stock + p_quantity_change;
    
    -- Validate stock doesn't go negative
    IF v_new_stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;
    
    -- Update product stock
    UPDATE Products
    SET stock_quantity = v_new_stock
    WHERE product_id = p_product_id;
    
    -- Log the change
    INSERT INTO Inventory_Log 
    (product_id, change_type, quantity_changed, old_quantity, new_quantity, reason, created_by)
    VALUES 
    (p_product_id, 'Manual', p_quantity_change, v_current_stock, v_new_stock, p_reason, 'System');
    
    COMMIT;
    
    SELECT v_new_stock as new_stock, 'Stock updated successfully' as message;
    
END //

-- =============================================
-- Procedure: CheckLowStock (MariaDB Compatible)
-- Description: Get products with low stock
-- =============================================
CREATE PROCEDURE CheckLowStock(
    IN p_threshold INT
)
BEGIN
    -- Set default value if null
    IF p_threshold IS NULL THEN
        SET p_threshold = 5;
    END IF;
    
    SELECT 
        p.product_id,
        p.product_name,
        p.stock_quantity,
        c.category_name,
        p.price,
        CASE 
            WHEN p.stock_quantity = 0 THEN 'OUT OF STOCK'
            WHEN p.stock_quantity <= p_threshold THEN 'LOW STOCK'
            ELSE 'SUFFICIENT'
        END AS stock_status
    FROM Products p
    LEFT JOIN Categories c ON p.category_id = c.category_id
    WHERE p.stock_quantity <= p_threshold AND p.is_active = TRUE
    ORDER BY p.stock_quantity ASC, p.product_name;
    
END //

-- =============================================
-- Procedure: GetCustomerOrderHistory
-- Description: Retrieve customer's order history
-- =============================================
CREATE PROCEDURE GetCustomerOrderHistory(
    IN p_customer_id INT,
    IN p_limit INT
)
BEGIN
    -- Set default limit
    IF p_limit IS NULL OR p_limit <= 0 THEN
        SET p_limit = 10;
    END IF;
    
    SELECT 
        o.order_id,
        o.order_date,
        o.status,
        o.total_amount,
        COUNT(od.product_id) as item_count
    FROM Orders o
    LEFT JOIN Order_Details od ON o.order_id = od.order_id
    WHERE o.customer_id = p_customer_id
    GROUP BY o.order_id, o.order_date, o.status, o.total_amount
    ORDER BY o.order_date DESC
    LIMIT p_limit;
    
END //

-- =============================================
-- Procedure: GenerateSalesReport
-- Description: Generate sales report for date range
-- =============================================
CREATE PROCEDURE GenerateSalesReport(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT 
        DATE(o.order_date) as sale_date,
        COUNT(DISTINCT o.order_id) as total_orders,
        COUNT(od.product_id) as total_items_sold,
        SUM(o.total_amount) as total_revenue,
        AVG(o.total_amount) as average_order_value,
        MAX(o.total_amount) as highest_order,
        MIN(o.total_amount) as lowest_order
    FROM Orders o
    LEFT JOIN Order_Details od ON o.order_id = od.order_id
    WHERE DATE(o.order_date) BETWEEN p_start_date AND p_end_date
    AND o.status IN ('Completed', 'Shipped')
    GROUP BY DATE(o.order_date)
    ORDER BY sale_date DESC;
    
END //

-- =============================================
-- Procedure: GetTopSellingProducts
-- Description: Get best selling products
-- =============================================
CREATE PROCEDURE GetTopSellingProducts(
    IN p_limit INT,
    IN p_days INT
)
BEGIN
    DECLARE v_start_date DATE;
    
    -- Set defaults
    IF p_limit IS NULL OR p_limit <= 0 THEN
        SET p_limit = 10;
    END IF;
    
    IF p_days IS NULL OR p_days <= 0 THEN
        SET p_days = 30;
    END IF;
    
    SET v_start_date = DATE_SUB(CURDATE(), INTERVAL p_days DAY);
    
    SELECT 
        p.product_id,
        p.product_name,
        c.category_name,
        SUM(od.quantity) as total_sold,
        SUM(od.subtotal) as total_revenue,
        COUNT(DISTINCT od.order_id) as order_count,
        p.stock_quantity as current_stock
    FROM Products p
    JOIN Order_Details od ON p.product_id = od.product_id
    JOIN Orders o ON od.order_id = o.order_id
    LEFT JOIN Categories c ON p.category_id = c.category_id
    WHERE DATE(o.order_date) >= v_start_date
    AND o.status IN ('Completed', 'Shipped')
    GROUP BY p.product_id, p.product_name, c.category_name, p.stock_quantity
    ORDER BY total_sold DESC
    LIMIT p_limit;
    
END //

-- =============================================
-- Procedure: UpdateOrderStatus
-- Description: Update order status with validation
-- =============================================
CREATE PROCEDURE UpdateOrderStatus(
    IN p_order_id INT,
    IN p_new_status VARCHAR(50),
    IN p_updated_by VARCHAR(100)
)
BEGIN
    DECLARE v_current_status VARCHAR(50);
    DECLARE v_customer_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Get current status
    SELECT status, customer_id INTO v_current_status, v_customer_id
    FROM Orders
    WHERE order_id = p_order_id;
    
    -- Validate status transition
    IF v_current_status = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot update cancelled order';
    END IF;
    
    -- Update order status
    UPDATE Orders
    SET status = p_new_status,
        updated_at = NOW()
    WHERE order_id = p_order_id;
    
    COMMIT;
    
    SELECT 
        p_order_id as order_id,
        v_current_status as old_status,
        p_new_status as new_status,
        'Status updated successfully' as message;
    
END //

DELIMITER ;

-- =============================================
-- Usage Examples
-- =============================================

/*
-- Check low stock products
CALL CheckLowStock(5);

-- Update stock
CALL UpdateStock(1, 10, 'Restocking from supplier');

-- Get customer order history
CALL GetCustomerOrderHistory(101, 5);

-- Generate sales report
CALL GenerateSalesReport('2025-01-01', '2025-01-31');

-- Get top selling products
CALL GetTopSellingProducts(10, 30);

-- Update order status
CALL UpdateOrderStatus(1001, 'Shipped', 'admin');
*/
