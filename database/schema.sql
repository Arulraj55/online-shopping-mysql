-- Online Shopping System Database Schema
-- Created for ARTIFI TECH MySQL Internship Project

-- Create Database
DROP DATABASE IF EXISTS online_shopping;
CREATE DATABASE online_shopping;
USE online_shopping;

-- =============================================
-- Table 1: Categories
-- =============================================
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================
-- Table 2: Products
-- =============================================
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    category_id INT,
    sku VARCHAR(50) UNIQUE,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL,
    INDEX idx_product_name (product_name),
    INDEX idx_category (category_id),
    INDEX idx_price (price),
    INDEX idx_stock (stock_quantity)
);

-- =============================================
-- Table 3: Customers
-- =============================================
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(10),
    country VARCHAR(50) DEFAULT 'India',
    date_of_birth DATE,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_name (first_name, last_name)
);

-- =============================================
-- Table 4: Orders
-- =============================================
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount > 0),
    order_status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    payment_status ENUM('Pending', 'Paid', 'Failed', 'Refunded') DEFAULT 'Pending',
    shipping_address TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    INDEX idx_customer (customer_id),
    INDEX idx_order_date (order_date),
    INDEX idx_status (order_status),
    INDEX idx_total (total_amount)
);

-- =============================================
-- Table 5: Order Details
-- =============================================
CREATE TABLE Order_Details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    subtotal DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE RESTRICT,
    INDEX idx_order (order_id),
    INDEX idx_product (product_id),
    UNIQUE KEY unique_order_product (order_id, product_id)
);

-- =============================================
-- Table 6: Inventory Log (Track Stock Changes)
-- =============================================
CREATE TABLE Inventory_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    change_type ENUM('Stock In', 'Stock Out', 'Adjustment', 'Order', 'Return') NOT NULL,
    quantity_changed INT NOT NULL,
    old_quantity INT NOT NULL,
    new_quantity INT NOT NULL,
    reference_id INT, -- Can be order_id or other reference
    reason VARCHAR(255),
    created_by VARCHAR(100) DEFAULT 'System',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    INDEX idx_product_log (product_id),
    INDEX idx_change_type (change_type),
    INDEX idx_created_at (created_at)
);

-- =============================================
-- Table 7: Product Reviews (Optional Enhancement)
-- =============================================
CREATE TABLE Product_Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE,
    
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    INDEX idx_product_review (product_id),
    INDEX idx_customer_review (customer_id),
    INDEX idx_rating (rating)
);

-- =============================================
-- Table 8: Shopping Cart (For Session Management)
-- =============================================
CREATE TABLE Shopping_Cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_customer_product (customer_id, product_id),
    INDEX idx_customer_cart (customer_id)
);

-- =============================================
-- Create Views for Common Queries
-- =============================================

-- View: Product Summary with Category
CREATE VIEW Product_Summary AS
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    p.stock_quantity,
    c.category_name,
    p.is_active,
    CASE 
        WHEN p.stock_quantity = 0 THEN 'Out of Stock'
        WHEN p.stock_quantity < 5 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM Products p
LEFT JOIN Categories c ON p.category_id = c.category_id;

-- View: Order Summary
CREATE VIEW Order_Summary AS
SELECT 
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    o.order_date,
    o.total_amount,
    o.order_status,
    o.payment_status,
    COUNT(od.order_detail_id) AS total_items
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
LEFT JOIN Order_Details od ON o.order_id = od.order_id
GROUP BY o.order_id, c.first_name, c.last_name, c.email, o.order_date, o.total_amount, o.order_status, o.payment_status;

-- View: Customer Order History
CREATE VIEW Customer_Order_History AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    MAX(o.order_date) AS last_order_date,
    AVG(o.total_amount) AS avg_order_value
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- =============================================
-- Display Schema Information
-- =============================================
SELECT 'Database Schema Created Successfully!' AS Status;

SHOW TABLES;

-- Show table structures
DESCRIBE Products;
DESCRIBE Customers;
DESCRIBE Orders;
DESCRIBE Order_Details;
