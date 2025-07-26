# Online Shopping System - MySQL Database Project

A comprehensive MySQL-based e-commerce database system with advanced features including automated stock management, order processing, and performance optimization through stored procedures and triggers.

## 🎯 Project Overview

This project demonstrates hands-on experience in database management and backend development by implementing a complete Online Shopping System using MySQL. The system efficiently handles product management, customer orders, stock tracking, and generates comprehensive reports.

## 🏗️ Project Structure

```
online-shopping-mysql/
├── database/
│   ├── schema.sql              # Database structure creation
│   ├── initial_data.sql        # Sample data insertion
│   ├── stored_procedures.sql   # Custom procedures
│   ├── triggers.sql           # Automated triggers
│   └── indexes.sql            # Performance optimization
├── backend/
│   ├── config/
│   │   └── database.js        # Database connection
│   ├── models/
│   │   ├── Product.js         # Product model
│   │   ├── Customer.js        # Customer model
│   │   └── Order.js           # Order model
│   ├── controllers/
│   │   ├── productController.js
│   │   ├── customerController.js
│   │   └── orderController.js
│   ├── routes/
│   │   ├── products.js
│   │   ├── customers.js
│   │   └── orders.js
│   ├── middleware/
│   │   └── validation.js
│   ├── app.js                 # Express application
│   └── package.json           # Dependencies
├── queries/
│   ├── crud_operations.sql    # Basic CRUD queries
│   ├── advanced_queries.sql   # Complex queries
│   └── reports.sql           # Reporting queries
├── reports/
│   ├── sales_reports.sql     # Sales analysis
│   └── inventory_reports.sql # Stock management
└── README.md                 # This file
```

## 🗄️ Database Schema

### Core Tables

1. **Products** - Store product information
2. **Customers** - Customer registration data
3. **Orders** - Order header information
4. **Order_Details** - Individual order items
5. **Categories** - Product categorization
6. **Inventory_Log** - Stock movement tracking

## ✨ Key Features

### 📦 Product Management
- ✅ Add, update, and remove products dynamically
- ✅ Category-based organization
- ✅ Real-time stock tracking
- ✅ Price history management

### 👥 Customer Management
- ✅ Customer registration and profile management
- ✅ Order history tracking
- ✅ Customer analytics

### 🛒 Order Processing
- ✅ Automated order placement
- ✅ Real-time stock validation
- ✅ Automatic stock deduction
- ✅ Order status tracking
- ✅ Prevent out-of-stock purchases

### 📊 Advanced Features
- ✅ Stored procedures for complex operations
- ✅ Triggers for automated stock management
- ✅ Indexing for performance optimization
- ✅ Comprehensive reporting system
- ✅ Sales analytics and insights

## 🚀 Getting Started

### Prerequisites
- MySQL Server 8.0 or higher
- Node.js (for backend API)
- MySQL Workbench (recommended)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/online-shopping-mysql.git
   cd online-shopping-mysql
   ```

2. **Set up the database:**
   ```bash
   mysql -u root -p < database/schema.sql
   mysql -u root -p < database/initial_data.sql
   mysql -u root -p < database/stored_procedures.sql
   mysql -u root -p < database/triggers.sql
   mysql -u root -p < database/indexes.sql
   ```

3. **Install backend dependencies:**
   ```bash
   cd backend
   npm install
   ```

4. **Configure database connection:**
   - Edit `backend/config/database.js`
   - Update connection parameters

5. **Start the application:**
   ```bash
   npm start
   ```

## 📋 Sample Data

### Products Table (Initial State)
| Product_ID | Product_Name | Price  | Stock_Quantity | Category_ID |
|------------|--------------|--------|----------------|-------------|
| 1          | Laptop       | 50000  | 10             | 1           |
| 2          | Smartphone   | 25000  | 5              | 1           |
| 3          | Headphones   | 2000   | 15             | 2           |

### Customers Table
| Customer_ID | Name       | Email              | Contact    |
|-------------|------------|--------------------|------------|
| 101         | John Doe   | john@example.com   | 9876543210 |
| 102         | Jane Smith | jane@example.com   | 9123456789 |

### Order Example (After Purchase)
| Order_ID | Customer_ID | Order_Date | Total_Amount | Status    |
|----------|-------------|------------|--------------|-----------|
| 1001     | 101         | 2025-03-15 | 52000        | Completed |

### Order Details
| OrderDetail_ID | Order_ID | Product_ID | Quantity | Subtotal |
|----------------|----------|------------|----------|----------|
| 5001           | 1001     | 1          | 1        | 50000    |
| 5002           | 1001     | 3          | 1        | 2000     |

## 🔧 Database Operations

### Core CRUD Operations
```sql
-- Create Product
INSERT INTO Products (product_name, price, stock_quantity, category_id) 
VALUES ('New Product', 1500, 20, 1);

-- Read Products
SELECT * FROM Products WHERE stock_quantity > 0;

-- Update Stock
UPDATE Products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;

-- Delete Product
DELETE FROM Products WHERE product_id = 1;
```

### Advanced Operations
```sql
-- Place Order (with stock validation)
CALL PlaceOrder(101, '[{"product_id": 1, "quantity": 1}]');

-- Generate Sales Report
CALL GenerateSalesReport('2025-01-01', '2025-12-31');

-- Check Low Stock Products
SELECT * FROM Products WHERE stock_quantity < 5;
```

## 📈 Performance Optimization

### Indexes Created
- Primary keys on all tables
- Foreign key indexes
- Composite indexes on frequently queried columns
- Full-text search indexes

### Stored Procedures
- `PlaceOrder()` - Automated order processing
- `UpdateStock()` - Stock management
- `GenerateSalesReport()` - Report generation
- `CheckInventory()` - Stock validation

### Triggers
- `after_order_insert` - Auto stock deduction
- `before_order_update` - Stock validation
- `inventory_log_trigger` - Track stock changes

## 📊 Reports & Analytics

### Available Reports
1. **Sales Reports**
   - Daily/Monthly/Yearly sales
   - Top-selling products
   - Customer purchase patterns

2. **Inventory Reports**
   - Current stock levels
   - Low stock alerts
   - Stock movement history

3. **Customer Analytics**
   - Customer lifetime value
   - Purchase frequency
   - Order patterns

## 🛡️ Business Rules Implemented

1. **Stock Management**
   - Automatic stock deduction on order placement
   - Prevent orders when insufficient stock
   - Real-time inventory tracking

2. **Order Processing**
   - Validate customer existence
   - Check product availability
   - Calculate order totals automatically
   - Update order status workflow

3. **Data Integrity**
   - Foreign key constraints
   - Check constraints for business rules
   - Transaction management for order processing

## 🔍 Testing

### Test Scenarios Included
1. **Product Management Tests**
   - Add/Update/Delete products
   - Stock level validation

2. **Order Processing Tests**
   - Successful order placement
   - Insufficient stock handling
   - Order cancellation

3. **Performance Tests**
   - Query optimization validation
   - Index effectiveness testing

## 📝 Learning Outcomes

This project demonstrates:
- ✅ **Database Design** - Normalized schema design
- ✅ **SQL Mastery** - Complex queries and operations
- ✅ **Performance Optimization** - Indexes and query tuning
- ✅ **Business Logic** - Stored procedures and triggers
- ✅ **Data Integrity** - Constraints and validation
- ✅ **Reporting** - Analytics and business intelligence

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Project Team

Developed as part of **ARTIFI TECH** Database Management internship program.

## 📞 Support

For questions or support:
- Create an issue in the GitHub repository
- Email: support@example.com

---

**Built with ❤️ for learning Database Management and MySQL**
