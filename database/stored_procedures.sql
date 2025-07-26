-- Stored Procedures for Online Shopping System
-- Advanced database operations for order processing and management

USE online_shopping;

DELIMITER //

-- =============================================
-- Procedure 1: Place Order with Stock Validation
-- =============================================
DROP PROCEDURE IF EXISTS PlaceOrder//
CREATE PROCEDURE PlaceOrder(
    IN p_customer_id INT,
    IN p_shipping_address TEXT,
    IN p_order_items JSON
)
BEGIN
    DECLARE v_order_id INT;
    DECLARE v_total_amount DECIMAL(12,2) DEFAULT 0;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_unit_price DECIMAL(10,2);
    DECLARE v_current_stock INT;
    DECLARE v_item_count INT;
    DECLARE v_counter INT DEFAULT 0;
    DECLARE v_error_msg VARCHAR(255) DEFAULT '';
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Validate customer exists
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE customer_id = p_customer_id AND is_active = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid or inactive customer';
    END IF;
    
    -- Get item count
    SET v_item_count = JSON_LENGTH(p_order_items);
    
    -- Validate all items and calculate total
    WHILE v_counter < v_item_count DO
        SET v_product_id = JSON_UNQUOTE(JSON_EXTRACT(p_order_items, CONCAT('$[', v_counter, '].product_id')));
        SET v_quantity = JSON_UNQUOTE(JSON_EXTRACT(p_order_items, CONCAT('$[', v_counter, '].quantity')));
        
        -- Validate product exists and is active
        SELECT price, stock_quantity 
        INTO v_unit_price, v_current_stock
        FROM Products 
        WHERE product_id = v_product_id AND is_active = TRUE;
        
        IF v_unit_price IS NULL THEN
            SET v_error_msg = CONCAT('Product ID ', v_product_id, ' not found or inactive');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
        END IF;
        
        -- Check stock availability
        IF v_current_stock < v_quantity THEN
            SET v_error_msg = CONCAT('Insufficient stock for product ID ', v_product_id, 
                                   '. Available: ', v_current_stock, ', Requested: ', v_quantity);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
        END IF;
        
        -- Add to total amount
        SET v_total_amount = v_total_amount + (v_unit_price * v_quantity);
        SET v_counter = v_counter + 1;
    END WHILE;
    
    -- Create order
    INSERT INTO Orders (customer_id, total_amount, shipping_address)
    VALUES (p_customer_id, v_total_amount, p_shipping_address);
    
    SET v_order_id = LAST_INSERT_ID();
    
    -- Reset counter for order details insertion
    SET v_counter = 0;
    
    -- Insert order details and update stock
    WHILE v_counter < v_item_count DO
        SET v_product_id = JSON_UNQUOTE(JSON_EXTRACT(p_order_items, CONCAT('$[', v_counter, '].product_id')));
        SET v_quantity = JSON_UNQUOTE(JSON_EXTRACT(p_order_items, CONCAT('$[', v_counter, '].quantity')));
        
        -- Get current price
        SELECT price INTO v_unit_price FROM Products WHERE product_id = v_product_id;
        
        -- Insert order detail
        INSERT INTO Order_Details (order_id, product_id, quantity, unit_price)
        VALUES (v_order_id, v_product_id, v_quantity, v_unit_price);
        
        -- Update stock
        UPDATE Products 
        SET stock_quantity = stock_quantity - v_quantity
        WHERE product_id = v_product_id;
        
        SET v_counter = v_counter + 1;
    END WHILE;
    
    COMMIT;
    
    -- Return order information
    SELECT v_order_id AS order_id, v_total_amount AS total_amount, 'Order placed successfully' AS message;
    
END//

-- =============================================
-- Procedure 2: Update Order Status
-- =============================================
DROP PROCEDURE IF EXISTS UpdateOrderStatus//
CREATE PROCEDURE UpdateOrderStatus(
    IN p_order_id INT,
    IN p_order_status VARCHAR(20),
    IN p_payment_status VARCHAR(20)
)
BEGIN
    DECLARE v_exists INT DEFAULT 0;
    
    -- Check if order exists
    SELECT COUNT(*) INTO v_exists FROM Orders WHERE order_id = p_order_id;
    
    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order not found';
    END IF;
    
    -- Validate status values
    IF p_order_status NOT IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid order status';
    END IF;
    
    IF p_payment_status NOT IN ('Pending', 'Paid', 'Failed', 'Refunded') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid payment status';
    END IF;
    
    UPDATE Orders 
    SET order_status = p_order_status,
        payment_status = p_payment_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE order_id = p_order_id;
    
    SELECT CONCAT('Order ', p_order_id, ' updated successfully') AS message;
END//

-- =============================================
-- Procedure 3: Cancel Order and Restore Stock
-- =============================================
DROP PROCEDURE IF EXISTS CancelOrder//
CREATE PROCEDURE CancelOrder(
    IN p_order_id INT,
    IN p_reason VARCHAR(255)
)
BEGIN
    DECLARE v_order_status VARCHAR(20);
    DECLARE v_exists INT DEFAULT 0;
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    
    DECLARE order_cursor CURSOR FOR
        SELECT product_id, quantity 
        FROM Order_Details 
        WHERE order_id = p_order_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Check if order exists and get current status
    SELECT order_status INTO v_order_status
    FROM Orders 
    WHERE order_id = p_order_id;
    
    IF v_order_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order not found';
    END IF;
    
    -- Check if order can be cancelled
    IF v_order_status IN ('Delivered', 'Cancelled') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order cannot be cancelled';
    END IF;
    
    -- Restore stock for all items in the order
    OPEN order_cursor;
    
    read_loop: LOOP
        FETCH order_cursor INTO v_product_id, v_quantity;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        UPDATE Products 
        SET stock_quantity = stock_quantity + v_quantity
        WHERE product_id = v_product_id;
    END LOOP;
    
    CLOSE order_cursor;
    
    -- Update order status
    UPDATE Orders 
    SET order_status = 'Cancelled',
        notes = CONCAT(COALESCE(notes, ''), ' | Cancelled: ', p_reason),
        updated_at = CURRENT_TIMESTAMP
    WHERE order_id = p_order_id;
    
    COMMIT;
    
    SELECT CONCAT('Order ', p_order_id, ' cancelled successfully') AS message;
END//

-- =============================================
-- Procedure 4: Generate Sales Report
-- =============================================
DROP PROCEDURE IF EXISTS GenerateSalesReport//
CREATE PROCEDURE GenerateSalesReport(
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_report_type VARCHAR(20) -- 'summary', 'detailed', 'products', 'customers'
)
BEGIN
    IF p_report_type = 'summary' THEN
        SELECT 
            DATE(order_date) AS sale_date,
            COUNT(*) AS total_orders,
            SUM(total_amount) AS total_sales,
            AVG(total_amount) AS avg_order_value,
            COUNT(DISTINCT customer_id) AS unique_customers
        FROM Orders
        WHERE DATE(order_date) BETWEEN p_start_date AND p_end_date
        AND order_status != 'Cancelled'
        GROUP BY DATE(order_date)
        ORDER BY sale_date;
        
    ELSEIF p_report_type = 'products' THEN
        SELECT 
            p.product_name,
            p.category_id,
            SUM(od.quantity) AS total_sold,
            SUM(od.subtotal) AS total_revenue,
            AVG(od.unit_price) AS avg_price,
            COUNT(DISTINCT od.order_id) AS orders_count
        FROM Order_Details od
        JOIN Products p ON od.product_id = p.product_id
        JOIN Orders o ON od.order_id = o.order_id
        WHERE DATE(o.order_date) BETWEEN p_start_date AND p_end_date
        AND o.order_status != 'Cancelled'
        GROUP BY p.product_id, p.product_name, p.category_id
        ORDER BY total_revenue DESC;
        
    ELSEIF p_report_type = 'customers' THEN
        SELECT 
            c.customer_id,
            CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
            c.email,
            COUNT(o.order_id) AS total_orders,
            SUM(o.total_amount) AS total_spent,
            AVG(o.total_amount) AS avg_order_value,
            MAX(o.order_date) AS last_order_date
        FROM Customers c
        JOIN Orders o ON c.customer_id = o.customer_id
        WHERE DATE(o.order_date) BETWEEN p_start_date AND p_end_date
        AND o.order_status != 'Cancelled'
        GROUP BY c.customer_id, c.first_name, c.last_name, c.email
        ORDER BY total_spent DESC;
        
    ELSE -- detailed
        SELECT 
            o.order_id,
            CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
            o.order_date,
            o.total_amount,
            o.order_status,
            o.payment_status,
            COUNT(od.order_detail_id) AS items_count
        FROM Orders o
        JOIN Customers c ON o.customer_id = c.customer_id
        LEFT JOIN Order_Details od ON o.order_id = od.order_id
        WHERE DATE(o.order_date) BETWEEN p_start_date AND p_end_date
        GROUP BY o.order_id, c.first_name, c.last_name, o.order_date, o.total_amount, o.order_status, o.payment_status
        ORDER BY o.order_date DESC;
    END IF;
END//

-- =============================================
-- Procedure 5: Check Low Stock Products
-- =============================================
DROP PROCEDURE IF EXISTS CheckLowStock//
CREATE PROCEDURE CheckLowStock(
    IN p_threshold INT DEFAULT 5
)
BEGIN
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
END//

-- =============================================
-- Procedure 6: Add Product with Validation
-- =============================================
DROP PROCEDURE IF EXISTS AddProduct//
CREATE PROCEDURE AddProduct(
    IN p_product_name VARCHAR(255),
    IN p_description TEXT,
    IN p_price DECIMAL(10,2),
    IN p_stock_quantity INT,
    IN p_category_id INT,
    IN p_sku VARCHAR(50)
)
BEGIN
    DECLARE v_category_exists INT DEFAULT 0;
    DECLARE v_sku_exists INT DEFAULT 0;
    
    -- Validate price
    IF p_price <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price must be greater than 0';
    END IF;
    
    -- Validate stock quantity
    IF p_stock_quantity < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock quantity cannot be negative';
    END IF;
    
    -- Check if category exists
    SELECT COUNT(*) INTO v_category_exists FROM Categories WHERE category_id = p_category_id;
    IF v_category_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Category does not exist';
    END IF;
    
    -- Check if SKU already exists
    IF p_sku IS NOT NULL THEN
        SELECT COUNT(*) INTO v_sku_exists FROM Products WHERE sku = p_sku;
        IF v_sku_exists > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SKU already exists';
        END IF;
    END IF;
    
    INSERT INTO Products (product_name, description, price, stock_quantity, category_id, sku)
    VALUES (p_product_name, p_description, p_price, p_stock_quantity, p_category_id, p_sku);
    
    SELECT LAST_INSERT_ID() AS product_id, 'Product added successfully' AS message;
END//

-- =============================================
-- Procedure 7: Update Stock Quantity
-- =============================================
DROP PROCEDURE IF EXISTS UpdateStock//
CREATE PROCEDURE UpdateStock(
    IN p_product_id INT,
    IN p_new_quantity INT,
    IN p_change_type VARCHAR(50),
    IN p_reason VARCHAR(255)
)
BEGIN
    DECLARE v_old_quantity INT;
    DECLARE v_exists INT DEFAULT 0;
    
    -- Validate new quantity
    IF p_new_quantity < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock quantity cannot be negative';
    END IF;
    
    -- Check if product exists
    SELECT stock_quantity INTO v_old_quantity
    FROM Products 
    WHERE product_id = p_product_id AND is_active = TRUE;
    
    IF v_old_quantity IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not found or inactive';
    END IF;
    
    -- Update stock
    UPDATE Products 
    SET stock_quantity = p_new_quantity,
        updated_at = CURRENT_TIMESTAMP
    WHERE product_id = p_product_id;
    
    -- Log the change
    INSERT INTO Inventory_Log 
    (product_id, change_type, quantity_changed, old_quantity, new_quantity, reason, created_by)
    VALUES 
    (p_product_id, p_change_type, p_new_quantity - v_old_quantity, v_old_quantity, p_new_quantity, p_reason, 'Admin');
    
    SELECT CONCAT('Stock updated for product ', p_product_id) AS message;
END//

DELIMITER ;

-- =============================================
-- Display Stored Procedures Information
-- =============================================
SELECT 'Stored Procedures Created Successfully!' AS Status;

SHOW PROCEDURE STATUS WHERE Db = 'online_shopping';
