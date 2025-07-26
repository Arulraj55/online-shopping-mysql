# API Testing Guide for Online Shopping System

## Quick API Tests

### 1. Health Check
```bash
curl http://localhost:3000/health
```

### 2. Get All Products
```bash
curl http://localhost:3000/api/products
```

### 3. Get Product by ID
```bash
curl http://localhost:3000/api/products/1
```

### 4. Create New Product
```bash
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "product_name": "Gaming Mouse",
    "description": "High-precision gaming mouse",
    "price": 2500,
    "stock_quantity": 50,
    "category_id": 2
  }'
```

### 5. Update Product
```bash
curl -X PUT http://localhost:3000/api/products/1 \
  -H "Content-Type: application/json" \
  -d '{
    "price": 48000,
    "stock_quantity": 8
  }'
```

### 6. Get Low Stock Products
```bash
curl http://localhost:3000/api/products/low-stock?threshold=10
```

### 7. Get Products by Category
```bash
curl http://localhost:3000/api/products/category/1
```

## Database Stored Procedure Tests

### Test Low Stock Check
```sql
CALL CheckLowStock(5);
```

### Test Simple Order Placement
```sql
CALL PlaceOrderSimple(101, 1, 2);
```

### Test Stock Update
```sql
CALL UpdateStock(1, 10, 'Restocking from supplier');
```

## Expected Responses

### Products API Response
```json
{
  "success": true,
  "data": [
    {
      "product_id": 1,
      "product_name": "Laptop",
      "description": "High-performance laptop",
      "price": "50000.00",
      "stock_quantity": 10,
      "category_id": 1,
      "category_name": "Electronics"
    }
  ]
}
```

### Health Check Response
```json
{
  "status": "OK",
  "message": "Online Shopping API is running",
  "timestamp": "2025-07-27T...",
  "version": "1.0.0"
}
```

## Performance Testing

### Load Testing with curl
```bash
# Test 100 concurrent requests
for i in {1..100}; do
  curl http://localhost:3000/api/products &
done
wait
```

## Next Steps for Testing
1. Install Postman for GUI testing
2. Create automated test suite with Jest
3. Add integration tests
4. Set up monitoring and logging
