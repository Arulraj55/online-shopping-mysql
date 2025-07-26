# 🚀 Quick Start Guide - Online Shopping System

## Prerequisites ✅
- MySQL Server (XAMPP recommended for Windows)
- Node.js installed
- Git (optional, for cloning)

## Method 1: Using XAMPP (Recommended for Windows)

### Step 1: Install XAMPP
1. Download XAMPP from: https://www.apachefriends.org/download.html
2. Install with default settings
3. Open XAMPP Control Panel
4. Click "Start" next to MySQL (port 3306)

### Step 2: Set Up Database
1. Open command prompt in project directory
2. Run the setup script:
   ```cmd
   setup_database.bat
   ```
   OR manually execute these commands:
   ```cmd
   mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS online_shopping;"
   mysql -u root -p online_shopping < database/schema.sql
   mysql -u root -p online_shopping < database/initial_data.sql
   mysql -u root -p online_shopping < database/stored_procedures.sql
   mysql -u root -p online_shopping < database/triggers.sql
   mysql -u root -p online_shopping < database/indexes.sql
   ```

### Step 3: Configure Database Connection
1. Edit `backend/.env` file:
   ```env
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=          # Leave empty for XAMPP default
   DB_NAME=online_shopping
   PORT=3000
   ```

### Step 4: Start the Application
```cmd
cd backend
npm start
```

## Method 2: Using Docker

### Step 1: Start MySQL Container
```cmd
docker run --name mysql-shopping -e MYSQL_ROOT_PASSWORD=password123 -e MYSQL_DATABASE=online_shopping -p 3306:3306 -d mysql:8.0
```

### Step 2: Wait for MySQL to Start
```cmd
docker logs mysql-shopping
```

### Step 3: Import Database
```cmd
docker exec -i mysql-shopping mysql -u root -ppassword123 online_shopping < database/schema.sql
docker exec -i mysql-shopping mysql -u root -ppassword123 online_shopping < database/initial_data.sql
docker exec -i mysql-shopping mysql -u root -ppassword123 online_shopping < database/stored_procedures.sql
docker exec -i mysql-shopping mysql -u root -ppassword123 online_shopping < database/triggers.sql
docker exec -i mysql-shopping mysql -u root -ppassword123 online_shopping < database/indexes.sql
```

### Step 4: Configure and Start
```cmd
# Edit backend/.env with Docker settings
cd backend
npm start
```

## 🌐 Access the Application

Once running, you can access:
- **API Server**: http://localhost:3000
- **Health Check**: http://localhost:3000/health
- **API Docs**: http://localhost:3000/api-docs (if Swagger is configured)

## 🧪 Test the API

### Sample API Calls

1. **Get All Products**:
   ```cmd
   curl http://localhost:3000/api/products
   ```

2. **Get Product by ID**:
   ```cmd
   curl http://localhost:3000/api/products/1
   ```

3. **Create New Customer**:
   ```cmd
   curl -X POST http://localhost:3000/api/customers -H "Content-Type: application/json" -d "{\"name\":\"Test User\",\"email\":\"test@example.com\",\"contact\":\"1234567890\"}"
   ```

## 🔍 Database Verification

### Using MySQL Command Line:
```sql
-- Connect to database
mysql -u root -p online_shopping

-- Check tables
SHOW TABLES;

-- View sample data
SELECT * FROM Products LIMIT 5;
SELECT * FROM Customers LIMIT 5;
SELECT * FROM Orders LIMIT 5;

-- Test stored procedure
CALL PlaceOrder(101, '[{"product_id": 1, "quantity": 1}]');
```

### Using phpMyAdmin (with XAMPP):
1. Go to http://localhost/phpmyadmin
2. Select `online_shopping` database
3. Browse tables and data

## 📊 Available Endpoints

- `GET /api/products` - List all products
- `GET /api/products/:id` - Get product details
- `POST /api/products` - Create new product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product

- `GET /api/customers` - List customers
- `POST /api/customers` - Create customer
- `GET /api/customers/:id` - Get customer details

- `GET /api/orders` - List orders
- `POST /api/orders` - Place new order
- `GET /api/orders/:id` - Get order details
- `PUT /api/orders/:id/status` - Update order status

## 🚨 Troubleshooting

### MySQL Connection Issues:
1. Ensure MySQL is running (XAMPP Control Panel)
2. Check port 3306 is not blocked
3. Verify credentials in `.env` file

### Node.js Issues:
1. Check if Node.js is installed: `node --version`
2. Install dependencies: `npm install`
3. Check for port conflicts (default: 3000)

### Database Issues:
1. Verify database exists: `SHOW DATABASES;`
2. Check table creation: `SHOW TABLES;`
3. Verify sample data: `SELECT COUNT(*) FROM Products;`

## 🎯 Next Steps

1. **Frontend Development**: Add React/Vue.js frontend
2. **Authentication**: Implement JWT authentication
3. **Payment Integration**: Add payment gateway
4. **File Uploads**: Product image management
5. **Real-time Features**: WebSocket for order updates

## 📞 Support

If you encounter any issues:
1. Check the console for error messages
2. Verify all prerequisites are installed
3. Ensure MySQL is running and accessible
4. Check network connectivity and firewall settings

Happy coding! 🎉
