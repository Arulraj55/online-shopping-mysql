-- Initial Sample Data for Online Shopping System
-- This file populates the database with sample data for testing

USE online_shopping;

-- =============================================
-- Insert Categories
-- =============================================
INSERT INTO Categories (category_name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Audio & Video', 'Audio and video equipment'),
('Computers', 'Laptops, desktops, and computer accessories'),
('Mobile & Tablets', 'Smartphones, tablets, and accessories'),
('Gaming', 'Gaming consoles, games, and accessories'),
('Home & Garden', 'Home appliances and garden equipment'),
('Fashion', 'Clothing, shoes, and accessories'),
('Sports', 'Sports equipment and accessories'),
('Books', 'Books, e-books, and educational materials'),
('Health & Beauty', 'Health and beauty products');

-- =============================================
-- Insert Products
-- =============================================
INSERT INTO Products (product_name, description, price, stock_quantity, category_id, sku) VALUES
-- Electronics
('Dell Laptop XPS 13', 'High-performance ultrabook with Intel i7 processor', 75000.00, 10, 3, 'DELL-XPS-13'),
('MacBook Air M2', 'Apple MacBook Air with M2 chip', 85000.00, 8, 3, 'APPLE-MBA-M2'),
('Gaming Laptop ASUS ROG', 'ASUS ROG gaming laptop with RTX 4060', 95000.00, 5, 3, 'ASUS-ROG-4060'),

-- Mobile & Tablets
('iPhone 15 Pro', 'Latest iPhone with advanced camera system', 89999.00, 15, 4, 'APPLE-IP15-PRO'),
('Samsung Galaxy S24', 'Samsung flagship smartphone', 65000.00, 12, 4, 'SAMSUNG-S24'),
('OnePlus 12', 'OnePlus flagship with fast charging', 55000.00, 18, 4, 'ONEPLUS-12'),
('iPad Pro 11 inch', 'Apple iPad Pro with M2 chip', 72000.00, 7, 4, 'APPLE-IPAD-PRO'),

-- Audio & Video
('Sony WH-1000XM5', 'Premium noise-canceling headphones', 25000.00, 25, 2, 'SONY-WH1000XM5'),
('AirPods Pro 2nd Gen', 'Apple AirPods with active noise cancellation', 18000.00, 30, 2, 'APPLE-AIRPODS-PRO2'),
('JBL Flip 6', 'Portable Bluetooth speaker', 8000.00, 40, 2, 'JBL-FLIP6'),
('Sony 55 inch 4K TV', '55-inch 4K Ultra HD Smart TV', 55000.00, 6, 2, 'SONY-55X80K'),

-- Gaming
('PlayStation 5', 'Sony PS5 gaming console', 49999.00, 8, 5, 'SONY-PS5'),
('Xbox Series X', 'Microsoft Xbox Series X console', 47999.00, 10, 5, 'MS-XBOX-SX'),
('Nintendo Switch OLED', 'Nintendo Switch OLED model', 32000.00, 15, 5, 'NINTENDO-SW-OLED'),

-- Computers
('Mechanical Keyboard', 'RGB mechanical gaming keyboard', 8500.00, 50, 3, 'KEYBOARD-RGB'),
('Gaming Mouse', 'High-precision gaming mouse', 4500.00, 60, 3, 'MOUSE-GAMING'),
('4K Monitor 27 inch', '27-inch 4K IPS monitor', 28000.00, 12, 3, 'MONITOR-4K-27'),
('Webcam HD', 'Full HD 1080p webcam', 3500.00, 35, 3, 'WEBCAM-HD'),

-- Home & Garden
('Smart Home Hub', 'Voice-controlled smart home hub', 12000.00, 20, 6, 'SMARTHUB-001'),
('Robot Vacuum', 'Automated robot vacuum cleaner', 25000.00, 8, 6, 'ROBOT-VAC-001'),

-- Fashion
('Wireless Earbuds', 'True wireless earbuds with charging case', 5500.00, 45, 2, 'EARBUDS-TWS'),
('Smartwatch', 'Fitness tracking smartwatch', 15000.00, 25, 1, 'SMARTWATCH-FIT');

-- =============================================
-- Insert Customers
-- =============================================
INSERT INTO Customers (first_name, last_name, email, phone, address, city, state, postal_code, date_of_birth) VALUES
('John', 'Doe', 'john.doe@email.com', '9876543210', '123 Main Street, Apartment 4B', 'Mumbai', 'Maharashtra', '400001', '1990-05-15'),
('Jane', 'Smith', 'jane.smith@email.com', '9123456789', '456 Oak Avenue, House No. 78', 'Delhi', 'Delhi', '110001', '1985-08-22'),
('Raj', 'Patel', 'raj.patel@email.com', '9988776655', '789 Pine Road, Flat 12', 'Bangalore', 'Karnataka', '560001', '1992-12-10'),
('Priya', 'Sharma', 'priya.sharma@email.com', '9876512345', '321 Cedar Lane, Villa 5', 'Chennai', 'Tamil Nadu', '600001', '1988-03-18'),
('Michael', 'Johnson', 'michael.j@email.com', '9543216789', '654 Elm Street, Suite 2A', 'Pune', 'Maharashtra', '411001', '1995-07-25'),
('Sarah', 'Williams', 'sarah.w@email.com', '9234567890', '987 Maple Drive, Bungalow 9', 'Hyderabad', 'Telangana', '500001', '1991-11-08'),
('Amit', 'Kumar', 'amit.kumar@email.com', '9876234567', '147 Birch Avenue, Floor 3', 'Kolkata', 'West Bengal', '700001', '1989-09-14'),
('Lisa', 'Brown', 'lisa.brown@email.com', '9345678901', '258 Spruce Street, Apartment 7C', 'Ahmedabad', 'Gujarat', '380001', '1993-04-30');

-- =============================================
-- Insert Sample Orders
-- =============================================

-- Order 1: John Doe orders a Laptop and Headphones
INSERT INTO Orders (customer_id, total_amount, order_status, payment_status, shipping_address) VALUES
(1, 100000.00, 'Processing', 'Paid', '123 Main Street, Apartment 4B, Mumbai, Maharashtra, 400001');

SET @order1_id = LAST_INSERT_ID();

INSERT INTO Order_Details (order_id, product_id, quantity, unit_price) VALUES
(@order1_id, 1, 1, 75000.00),  -- Dell Laptop
(@order1_id, 8, 1, 25000.00);  -- Sony Headphones

-- Order 2: Jane Smith orders iPhone and AirPods
INSERT INTO Orders (customer_id, total_amount, order_status, payment_status, shipping_address) VALUES
(2, 107999.00, 'Shipped', 'Paid', '456 Oak Avenue, House No. 78, Delhi, Delhi, 110001');

SET @order2_id = LAST_INSERT_ID();

INSERT INTO Order_Details (order_id, product_id, quantity, unit_price) VALUES
(@order2_id, 4, 1, 89999.00),  -- iPhone 15 Pro
(@order2_id, 9, 1, 18000.00);  -- AirPods Pro

-- Order 3: Raj Patel orders Gaming setup
INSERT INTO Orders (customer_id, total_amount, order_status, payment_status, shipping_address) VALUES
(3, 152999.00, 'Delivered', 'Paid', '789 Pine Road, Flat 12, Bangalore, Karnataka, 560001');

SET @order3_id = LAST_INSERT_ID();

INSERT INTO Order_Details (order_id, product_id, quantity, unit_price) VALUES
(@order3_id, 12, 1, 49999.00),  -- PlayStation 5
(@order3_id, 3, 1, 95000.00),   -- Gaming Laptop
(@order3_id, 15, 1, 8500.00);   -- Mechanical Keyboard

-- Order 4: Priya Sharma orders multiple items
INSERT INTO Orders (customer_id, total_amount, order_status, payment_status, shipping_address) VALUES
(4, 83000.00, 'Processing', 'Paid', '321 Cedar Lane, Villa 5, Chennai, Tamil Nadu, 600001');

SET @order4_id = LAST_INSERT_ID();

INSERT INTO Order_Details (order_id, product_id, quantity, unit_price) VALUES
(@order4_id, 11, 1, 55000.00),  -- Sony 4K TV
(@order4_id, 17, 1, 28000.00);  -- 4K Monitor

-- Order 5: Small order from Michael
INSERT INTO Orders (customer_id, total_amount, order_status, payment_status, shipping_address) VALUES
(5, 13500.00, 'Pending', 'Pending', '654 Elm Street, Suite 2A, Pune, Maharashtra, 411001');

SET @order5_id = LAST_INSERT_ID();

INSERT INTO Order_Details (order_id, product_id, quantity, unit_price) VALUES
(@order5_id, 10, 1, 8000.00),   -- JBL Speaker
(@order5_id, 19, 1, 5500.00);   -- Wireless Earbuds

-- =============================================
-- Insert Shopping Cart Items (Active Sessions)
-- =============================================
INSERT INTO Shopping_Cart (customer_id, product_id, quantity) VALUES
(6, 5, 1),  -- Sarah has Samsung Galaxy in cart
(6, 16, 1), -- Sarah has Gaming Mouse in cart
(7, 2, 1),  -- Amit has MacBook in cart
(8, 20, 1), -- Lisa has Smartwatch in cart
(8, 18, 1); -- Lisa has Webcam in cart

-- =============================================
-- Insert Product Reviews
-- =============================================
INSERT INTO Product_Reviews (product_id, customer_id, rating, review_text, is_verified) VALUES
(1, 1, 5, 'Excellent laptop! Fast performance and great build quality.', TRUE),
(8, 1, 4, 'Great headphones, excellent noise cancellation. A bit pricey though.', TRUE),
(4, 2, 5, 'Amazing phone! Camera quality is outstanding.', TRUE),
(9, 2, 5, 'Perfect fit and sound quality. Love the noise cancellation.', TRUE),
(12, 3, 5, 'Best gaming console! Graphics are incredible.', TRUE),
(3, 3, 4, 'Powerful gaming laptop, runs all games smoothly.', TRUE),
(11, 4, 4, 'Good TV with excellent picture quality. Smart features work well.', TRUE),
(5, 6, 5, 'Best Android phone in this price range!', FALSE),
(10, 5, 3, 'Good speaker but battery life could be better.', TRUE);

-- =============================================
-- Update stock quantities based on orders
-- =============================================
UPDATE Products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;  -- Dell Laptop
UPDATE Products SET stock_quantity = stock_quantity - 1 WHERE product_id = 8;  -- Sony Headphones
UPDATE Products SET stock_quantity = stock_quantity - 1 WHERE product_id = 4;  -- iPhone 15 Pro
UPDATE Products SET stock_quantity = stock_quantity - 1 WHERE product_id = 9;  -- AirPods Pro
UPDATE Products SET stock_quantity = stock_quantity - 1 WHERE product_id = 12; -- PlayStation 5
UPDATE Products SET stock_quantity = stock_quantity - 1 WHERE product_id = 3;  -- Gaming Laptop
UPDATE Products SET stock_quantity = stock_quantity - 1 WHERE product_id = 15; -- Mechanical Keyboard
UPDATE Products SET stock_quantity = stock_quantity - 1 WHERE product_id = 11; -- Sony 4K TV
UPDATE Products SET stock_quantity = stock_quantity - 1 WHERE product_id = 17; -- 4K Monitor

-- =============================================
-- Display Sample Data Summary
-- =============================================
SELECT 'Sample Data Inserted Successfully!' AS Status;

-- Show data summary
SELECT 'Categories' AS Table_Name, COUNT(*) AS Record_Count FROM Categories
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Customers', COUNT(*) FROM Customers
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL
SELECT 'Order_Details', COUNT(*) FROM Order_Details
UNION ALL
SELECT 'Shopping_Cart', COUNT(*) FROM Shopping_Cart
UNION ALL
SELECT 'Product_Reviews', COUNT(*) FROM Product_Reviews;

-- Show sample products
SELECT 'Sample Products:' AS Info;
SELECT product_id, product_name, price, stock_quantity, 
       (SELECT category_name FROM Categories WHERE Categories.category_id = Products.category_id) AS category
FROM Products 
LIMIT 10;

-- Show sample orders
SELECT 'Sample Orders:' AS Info;
SELECT o.order_id, 
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       o.order_date, 
       o.total_amount, 
       o.order_status
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC;
