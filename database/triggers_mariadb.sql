-- =============================================
-- MariaDB Compatible Triggers for Online Shopping System
-- =============================================

-- Note: MariaDB has some limitations with triggers
-- These are simplified versions that work with MariaDB

DELIMITER //

-- =============================================
-- Trigger: Validate stock before order detail insert
-- =============================================
CREATE TRIGGER before_order_detail_insert
    BEFORE INSERT ON Order_Details
    FOR EACH ROW
BEGIN
    DECLARE v_available_stock INT;
    
    -- Check available stock
    SELECT stock_quantity INTO v_available_stock
    FROM Products
    WHERE product_id = NEW.product_id;
    
    -- Validate sufficient stock
    IF v_available_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Insufficient stock for this product';
    END IF;
    
    -- Calculate subtotal if not provided
    IF NEW.subtotal IS NULL OR NEW.subtotal = 0 THEN
        SET NEW.subtotal = NEW.quantity * (
            SELECT price FROM Products WHERE product_id = NEW.product_id
        );
    END IF;
    
END //

-- =============================================
-- Trigger: Update stock after order detail insert
-- =============================================
CREATE TRIGGER after_order_detail_insert
    AFTER INSERT ON Order_Details
    FOR EACH ROW
BEGIN
    DECLARE v_old_stock INT;
    
    -- Get current stock
    SELECT stock_quantity INTO v_old_stock 
    FROM Products 
    WHERE product_id = NEW.product_id;
    
    -- Update product stock
    UPDATE Products 
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    
    -- Log inventory change (simplified - no access to information_schema)
    INSERT INTO Inventory_Log 
    (product_id, change_type, quantity_changed, old_quantity, new_quantity, reference_id, reason, created_by)
    VALUES 
    (NEW.product_id, 'Order', -NEW.quantity, v_old_stock, v_old_stock - NEW.quantity, 
     NEW.order_id, CONCAT('Order placed - Order ID: ', NEW.order_id), 'System');
    
END //

-- =============================================
-- Trigger: Restore stock when order detail is deleted
-- =============================================
CREATE TRIGGER after_order_detail_delete
    AFTER DELETE ON Order_Details
    FOR EACH ROW
BEGIN
    DECLARE v_old_stock INT;
    
    -- Get current stock
    SELECT stock_quantity INTO v_old_stock 
    FROM Products 
    WHERE product_id = OLD.product_id;
    
    -- Restore stock
    UPDATE Products 
    SET stock_quantity = stock_quantity + OLD.quantity
    WHERE product_id = OLD.product_id;
    
    -- Log inventory change
    INSERT INTO Inventory_Log 
    (product_id, change_type, quantity_changed, old_quantity, new_quantity, reference_id, reason, created_by)
    VALUES 
    (OLD.product_id, 'Return', OLD.quantity, v_old_stock, v_old_stock + OLD.quantity, 
     OLD.order_id, CONCAT('Order cancelled - Order ID: ', OLD.order_id), 'System');
    
END //

-- =============================================
-- Trigger: Update order total when order details change
-- =============================================
CREATE TRIGGER after_order_detail_change
    AFTER INSERT ON Order_Details
    FOR EACH ROW
BEGIN
    -- Update order total
    UPDATE Orders 
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM Order_Details 
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
    
END //

-- =============================================
-- Trigger: Update order total when order details are deleted
-- =============================================
CREATE TRIGGER after_order_detail_delete_total
    AFTER DELETE ON Order_Details
    FOR EACH ROW
BEGIN
    -- Update order total
    UPDATE Orders 
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM Order_Details 
        WHERE order_id = OLD.order_id
    )
    WHERE order_id = OLD.order_id;
    
END //

-- =============================================
-- Trigger: Validate product data before insert/update
-- =============================================
CREATE TRIGGER before_product_insert_update
    BEFORE INSERT ON Products
    FOR EACH ROW
BEGIN
    -- Ensure price is positive
    IF NEW.price <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Product price must be greater than 0';
    END IF;
    
    -- Ensure stock is not negative
    IF NEW.stock_quantity < 0 THEN
        SET NEW.stock_quantity = 0;
    END IF;
    
    -- Set default values
    IF NEW.is_active IS NULL THEN
        SET NEW.is_active = TRUE;
    END IF;
    
END //

CREATE TRIGGER before_product_update
    BEFORE UPDATE ON Products
    FOR EACH ROW
BEGIN
    -- Ensure price is positive
    IF NEW.price <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Product price must be greater than 0';
    END IF;
    
    -- Ensure stock is not negative
    IF NEW.stock_quantity < 0 THEN
        SET NEW.stock_quantity = 0;
    END IF;
    
    -- Log stock changes
    IF OLD.stock_quantity != NEW.stock_quantity THEN
        INSERT INTO Inventory_Log 
        (product_id, change_type, quantity_changed, old_quantity, new_quantity, reason, created_by)
        VALUES 
        (NEW.product_id, 'Manual', NEW.stock_quantity - OLD.stock_quantity, 
         OLD.stock_quantity, NEW.stock_quantity, 'Stock updated manually', 'System');
    END IF;
    
END //

-- =============================================
-- Trigger: Validate customer data
-- =============================================
CREATE TRIGGER before_customer_insert
    BEFORE INSERT ON Customers
    FOR EACH ROW
BEGIN
    -- Validate email format (basic check)
    IF NEW.email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid email format';
    END IF;
    
    -- Set default registration date
    IF NEW.registration_date IS NULL THEN
        SET NEW.registration_date = NOW();
    END IF;
    
END //

-- =============================================
-- Trigger: Validate order data
-- =============================================
CREATE TRIGGER before_order_insert
    BEFORE INSERT ON Orders
    FOR EACH ROW
BEGIN
    -- Set default order date
    IF NEW.order_date IS NULL THEN
        SET NEW.order_date = NOW();
    END IF;
    
    -- Set default status
    IF NEW.status IS NULL OR NEW.status = '' THEN
        SET NEW.status = 'Pending';
    END IF;
    
    -- Initialize total amount
    IF NEW.total_amount IS NULL THEN
        SET NEW.total_amount = 0;
    END IF;
    
END //

-- =============================================
-- Trigger: Prevent deletion of products with orders
-- =============================================
CREATE TRIGGER before_product_delete
    BEFORE DELETE ON Products
    FOR EACH ROW
BEGIN
    DECLARE v_order_count INT;
    
    -- Check if product has orders
    SELECT COUNT(*) INTO v_order_count
    FROM Order_Details
    WHERE product_id = OLD.product_id;
    
    IF v_order_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot delete product with existing orders. Mark as inactive instead.';
    END IF;
    
END //

DELIMITER ;

-- =============================================
-- Trigger Status Check
-- =============================================

/*
-- To verify triggers are created:
SHOW TRIGGERS LIKE '%order%';
SHOW TRIGGERS LIKE '%product%';
SHOW TRIGGERS LIKE '%customer%';

-- Test trigger functionality:

-- 1. Test stock validation
INSERT INTO Order_Details (order_id, product_id, quantity) 
VALUES (1001, 1, 999); -- Should fail if insufficient stock

-- 2. Test automatic subtotal calculation
INSERT INTO Order_Details (order_id, product_id, quantity) 
VALUES (1001, 1, 2); -- Should auto-calculate subtotal

-- 3. Test order total update
-- Order total should automatically update when order details change

-- 4. Test product validation
INSERT INTO Products (product_name, price, stock_quantity, category_id) 
VALUES ('Test Product', -100, -5, 1); -- Should adjust negative values

*/
