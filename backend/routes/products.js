const express = require('express');
const router = express.Router();
const ProductController = require('../controllers/productController');

// GET /api/products - Get all products
router.get('/', ProductController.getAllProducts);

// GET /api/products/low-stock - Get low stock products
router.get('/low-stock', ProductController.getLowStockProducts);

// GET /api/products/category/:categoryId - Get products by category
router.get('/category/:categoryId', ProductController.getProductsByCategory);

// GET /api/products/:id - Get product by ID
router.get('/:id', ProductController.getProductById);

// POST /api/products - Create new product
router.post('/', ProductController.createProduct);

// PUT /api/products/:id - Update product
router.put('/:id', ProductController.updateProduct);

// DELETE /api/products/:id - Delete product
router.delete('/:id', ProductController.deleteProduct);

module.exports = router;
