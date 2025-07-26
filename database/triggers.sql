-- Triggers for Online Shopping System
-- Automated business logic and data integrity enforcement

USE online_shopping;

DELIMITER //

-- =============================================
-- Trigger 1: Auto-update stock when order is placed
-- =============================================
DROP TRIGGER IF EXISTS after_order_detail_insert//
CREATE TRIGGER after_order_detail_insert
    AFTER INSERT ON Order_Details
    FOR EACH ROW
BEGIN
    DECLARE v_old_stock INT;
    
    -- Get current stock before update
    SELECT stock_quantity INTO v_old_stock 
    FROM Products 
    WHERE product_id = NEW.product_id;
    
    -- Log the inventory change
    INSERT INTO Inventory_Log 
    (product_id, change_type, quantity_changed, old_quantity, new_quantity, reference_id, reason, created_by)
    VALUES 
    (NEW.product_id, 'Order', -NEW.quantity, v_old_stock, v_old_stock - NEW.quantity, NEW.order_id, 
     CONCAT('Order placed - Order ID: ', NEW.order_id), 'System');
END//

-- =============================================
-- Trigger 2: Prevent negative stock
-- =============================================
DROP TRIGGER IF EXISTS before_product_stock_update//
CREATE TRIGGER before_product_stock_update
    BEFORE UPDATE ON Products
    FOR EACH ROW
BEGIN
    -- Prevent negative stock
    IF NEW.stock_quantity < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Stock quantity cannot be negative';
    END IF;
    
    -- Auto-update the updated_at timestamp
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END//

-- =============================================
-- Trigger 3: Validate order before insertion
-- =============================================
DROP TRIGGER IF EXISTS before_order_insert//
CREATE TRIGGER before_order_insert
    BEFORE INSERT ON Orders
    FOR EACH ROW
BEGIN
    -- Ensure total amount is positive
    IF NEW.total_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Order total amount must be greater than 0';
    END IF;
    
    -- Validate customer exists and is active
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE customer_id = NEW.customer_id AND is_active = TRUE) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid or inactive customer';
    END IF;
END//

-- =============================================
-- Trigger 4: Validate order details before insertion
-- =============================================
DROP TRIGGER IF EXISTS before_order_detail_insert//
CREATE TRIGGER before_order_detail_insert
    BEFORE INSERT ON Order_Details
    FOR EACH ROW
BEGIN
    DECLARE v_stock_quantity INT;
    DECLARE v_product_price DECIMAL(10,2);
    DECLARE v_is_active BOOLEAN;
    
    -- Get product information
    SELECT stock_quantity, price, is_active
    INTO v_stock_quantity, v_product_price, v_is_active
    FROM Products 
    WHERE product_id = NEW.product_id;
    
    -- Check if product exists and is active
    IF v_is_active IS NULL OR v_is_active = FALSE THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Product not found or inactive';
    END IF;
    
    -- Check stock availability
    IF v_stock_quantity < NEW.quantity THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('Insufficient stock. Available: ', v_stock_quantity, ', Requested: ', NEW.quantity);
    END IF;
    
    -- Validate unit price matches current product price
    IF NEW.unit_price != v_product_price THEN
        SET NEW.unit_price = v_product_price;
    END IF;
    
    -- Ensure quantity is positive
    IF NEW.quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Order quantity must be greater than 0';
    END IF;
END//

-- =============================================
-- Trigger 5: Update order total when order details change
-- =============================================
DROP TRIGGER IF EXISTS after_order_detail_insert_update_total//
CREATE TRIGGER after_order_detail_insert_update_total
    AFTER INSERT ON Order_Details
    FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(12,2);
    
    -- Calculate new total for the order
    SELECT SUM(subtotal) INTO v_new_total
    FROM Order_Details
    WHERE order_id = NEW.order_id;
    
    -- Update order total
    UPDATE Orders 
    SET total_amount = v_new_total,
        updated_at = CURRENT_TIMESTAMP
    WHERE order_id = NEW.order_id;
END//

-- =============================================
-- Trigger 6: Log inventory changes on direct stock updates
-- =============================================
DROP TRIGGER IF EXISTS after_product_stock_update//
CREATE TRIGGER after_product_stock_update
    AFTER UPDATE ON Products
    FOR EACH ROW
BEGIN
    DECLARE v_change_type VARCHAR(50);
    DECLARE v_quantity_changed INT;
    
    -- Only log if stock quantity actually changed
    IF OLD.stock_quantity != NEW.stock_quantity THEN
        SET v_quantity_changed = NEW.stock_quantity - OLD.stock_quantity;
        
        -- Determine change type
        IF v_quantity_changed > 0 THEN
            SET v_change_type = 'Stock In';
        ELSE
            SET v_change_type = 'Stock Out';
        END IF;
        
        -- Log the change
        INSERT INTO Inventory_Log 
        (product_id, change_type, quantity_changed, old_quantity, new_quantity, reason, created_by)
        VALUES 
        (NEW.product_id, v_change_type, v_quantity_changed, OLD.stock_quantity, NEW.stock_quantity, 
         'Direct stock update', 'Admin');
    END IF;
END//

-- =============================================
-- Trigger 7: Prevent deletion of products with existing orders
-- =============================================
DROP TRIGGER IF EXISTS before_product_delete//
CREATE TRIGGER before_product_delete
    BEFORE DELETE ON Products
    FOR EACH ROW
BEGIN
    DECLARE v_order_count INT;
    
    -- Check if product has existing orders
    SELECT COUNT(*) INTO v_order_count
    FROM Order_Details
    WHERE product_id = OLD.product_id;
    
    IF v_order_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot delete product with existing orders. Set as inactive instead.';
    END IF;
END//

-- =============================================
-- Trigger 8: Restore stock when order is cancelled
-- =============================================
DROP TRIGGER IF EXISTS after_order_status_update//
CREATE TRIGGER after_order_status_update
    AFTER UPDATE ON Orders
    FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_old_stock INT;
    
    DECLARE order_cursor CURSOR FOR
        SELECT product_id, quantity 
        FROM Order_Details 
        WHERE order_id = NEW.order_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- If order status changed to Cancelled, restore stock
    IF OLD.order_status != 'Cancelled' AND NEW.order_status = 'Cancelled' THEN
        OPEN order_cursor;
        
        read_loop: LOOP
            FETCH order_cursor INTO v_product_id, v_quantity;
            IF done THEN
                LEAVE read_loop;
            END IF;
            
            -- Get current stock
            SELECT stock_quantity INTO v_old_stock
            FROM Products 
            WHERE product_id = v_product_id;
            
            -- Restore stock
            UPDATE Products 
            SET stock_quantity = stock_quantity + v_quantity
            WHERE product_id = v_product_id;
            
            -- Log the restoration
            INSERT INTO Inventory_Log 
            (product_id, change_type, quantity_changed, old_quantity, new_quantity, reference_id, reason, created_by)
            VALUES 
            (v_product_id, 'Return', v_quantity, v_old_stock, v_old_stock + v_quantity, NEW.order_id, 
             CONCAT('Order cancelled - Order ID: ', NEW.order_id), 'System');
        END LOOP;
        
        CLOSE order_cursor;
    END IF;
END//

-- =============================================
-- Trigger 9: Validate customer email format
-- =============================================
DROP TRIGGER IF EXISTS before_customer_insert//
CREATE TRIGGER before_customer_insert
    BEFORE INSERT ON Customers
    FOR EACH ROW
BEGIN
    -- Validate email format
    IF NEW.email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid email format';
    END IF;
    
    -- Validate phone number (Indian format)
    IF NEW.phone IS NOT NULL AND NEW.phone NOT REGEXP '^[6-9][0-9]{9}$' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid phone number format (should be 10 digits starting with 6-9)';
    END IF;
    
    -- Convert email to lowercase
    SET NEW.email = LOWER(NEW.email);
END//

-- =============================================
-- Trigger 10: Auto-calculate order total on order detail updates
-- =============================================
DROP TRIGGER IF EXISTS after_order_detail_update//
CREATE TRIGGER after_order_detail_update
    AFTER UPDATE ON Order_Details
    FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(12,2);
    
    -- Recalculate order total
    SELECT SUM(subtotal) INTO v_new_total
    FROM Order_Details
    WHERE order_id = NEW.order_id;
    
    -- Update order total
    UPDATE Orders 
    SET total_amount = v_new_total,
        updated_at = CURRENT_TIMESTAMP
    WHERE order_id = NEW.order_id;
END//

-- =============================================
-- Trigger 11: Update order total when order detail is deleted
-- =============================================
DROP TRIGGER IF EXISTS after_order_detail_delete//
CREATE TRIGGER after_order_detail_delete
    AFTER DELETE ON Order_Details
    FOR EACH ROW
BEGIN
    DECLARE v_new_total DECIMAL(12,2);
    
    -- Recalculate order total
    SELECT COALESCE(SUM(subtotal), 0) INTO v_new_total
    FROM Order_Details
    WHERE order_id = OLD.order_id;
    
    -- Update order total
    UPDATE Orders 
    SET total_amount = v_new_total,
        updated_at = CURRENT_TIMESTAMP
    WHERE order_id = OLD.order_id;
    
    -- Restore stock for deleted item
    UPDATE Products 
    SET stock_quantity = stock_quantity + OLD.quantity
    WHERE product_id = OLD.product_id;
    
    -- Log stock restoration
    INSERT INTO Inventory_Log 
    (product_id, change_type, quantity_changed, old_quantity, new_quantity, reference_id, reason, created_by)
    VALUES 
    (OLD.product_id, 'Return', OLD.quantity, 
     (SELECT stock_quantity FROM Products WHERE product_id = OLD.product_id) - OLD.quantity,
     (SELECT stock_quantity FROM Products WHERE product_id = OLD.product_id),
     OLD.order_id, CONCAT('Order item removed - Order ID: ', OLD.order_id), 'System');
END//

DELIMITER ;

-- =============================================
-- Display Triggers Information
-- =============================================
SELECT 'Triggers Created Successfully!' AS Status;

-- Show all triggers in the database
SELECT 
    TRIGGER_NAME,
    EVENT_MANIPULATION,
    EVENT_OBJECT_TABLE,
    TRIGGER_SCHEMA
FROM INFORMATION_SCHEMA.TRIGGERS 
WHERE TRIGGER_SCHEMA = 'online_shopping'
ORDER BY EVENT_OBJECT_TABLE, TRIGGER_NAME;
