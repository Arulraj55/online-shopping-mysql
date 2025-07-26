const Product = require('../models/Product');

class ProductController {
    // Get all products
    static async getAllProducts(req, res) {
        try {
            const products = await Product.findAll();
            res.json({
                success: true,
                data: products
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error fetching products',
                error: error.message
            });
        }
    }

    // Get product by ID
    static async getProductById(req, res) {
        try {
            const { id } = req.params;
            const product = await Product.findById(id);
            
            if (!product) {
                return res.status(404).json({
                    success: false,
                    message: 'Product not found'
                });
            }

            res.json({
                success: true,
                data: product
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error fetching product',
                error: error.message
            });
        }
    }

    // Create new product
    static async createProduct(req, res) {
        try {
            const productData = req.body;
            const newProduct = await Product.create(productData);
            
            res.status(201).json({
                success: true,
                message: 'Product created successfully',
                data: newProduct
            });
        } catch (error) {
            res.status(400).json({
                success: false,
                message: 'Error creating product',
                error: error.message
            });
        }
    }

    // Update product
    static async updateProduct(req, res) {
        try {
            const { id } = req.params;
            const updateData = req.body;
            
            const updated = await Product.update(id, updateData);
            
            if (!updated) {
                return res.status(404).json({
                    success: false,
                    message: 'Product not found'
                });
            }

            res.json({
                success: true,
                message: 'Product updated successfully'
            });
        } catch (error) {
            res.status(400).json({
                success: false,
                message: 'Error updating product',
                error: error.message
            });
        }
    }

    // Delete product
    static async deleteProduct(req, res) {
        try {
            const { id } = req.params;
            const deleted = await Product.delete(id);
            
            if (!deleted) {
                return res.status(404).json({
                    success: false,
                    message: 'Product not found'
                });
            }

            res.json({
                success: true,
                message: 'Product deleted successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error deleting product',
                error: error.message
            });
        }
    }

    // Get products by category
    static async getProductsByCategory(req, res) {
        try {
            const { categoryId } = req.params;
            const products = await Product.findByCategory(categoryId);
            
            res.json({
                success: true,
                data: products
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error fetching products by category',
                error: error.message
            });
        }
    }

    // Get low stock products
    static async getLowStockProducts(req, res) {
        try {
            const threshold = req.query.threshold || 5;
            const products = await Product.findLowStock(threshold);
            
            res.json({
                success: true,
                data: products,
                message: `Products with stock below ${threshold}`
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error fetching low stock products',
                error: error.message
            });
        }
    }
}

module.exports = ProductController;
