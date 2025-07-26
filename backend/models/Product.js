const db = require('../config/database');

class Product {
    static async findAll() {
        const [rows] = await db.execute(`
            SELECT p.*, c.category_name 
            FROM Products p 
            LEFT JOIN Categories c ON p.category_id = c.category_id 
            ORDER BY p.product_id
        `);
        return rows;
    }

    static async findById(id) {
        const [rows] = await db.execute(`
            SELECT p.*, c.category_name 
            FROM Products p 
            LEFT JOIN Categories c ON p.category_id = c.category_id 
            WHERE p.product_id = ?
        `, [id]);
        return rows[0];
    }

    static async create(productData) {
        const { product_name, description, price, stock_quantity, category_id } = productData;
        
        const [result] = await db.execute(`
            INSERT INTO Products (product_name, description, price, stock_quantity, category_id)
            VALUES (?, ?, ?, ?, ?)
        `, [product_name, description, price, stock_quantity, category_id]);
        
        return this.findById(result.insertId);
    }

    static async update(id, updateData) {
        const fields = [];
        const values = [];
        
        Object.keys(updateData).forEach(key => {
            if (updateData[key] !== undefined) {
                fields.push(`${key} = ?`);
                values.push(updateData[key]);
            }
        });
        
        if (fields.length === 0) return false;
        
        values.push(id);
        
        const [result] = await db.execute(`
            UPDATE Products SET ${fields.join(', ')} WHERE product_id = ?
        `, values);
        
        return result.affectedRows > 0;
    }

    static async delete(id) {
        const [result] = await db.execute(`
            DELETE FROM Products WHERE product_id = ?
        `, [id]);
        
        return result.affectedRows > 0;
    }

    static async findByCategory(categoryId) {
        const [rows] = await db.execute(`
            SELECT p.*, c.category_name 
            FROM Products p 
            LEFT JOIN Categories c ON p.category_id = c.category_id 
            WHERE p.category_id = ?
            ORDER BY p.product_name
        `, [categoryId]);
        return rows;
    }

    static async findLowStock(threshold = 5) {
        const [rows] = await db.execute(`
            SELECT p.*, c.category_name 
            FROM Products p 
            LEFT JOIN Categories c ON p.category_id = c.category_id 
            WHERE p.stock_quantity < ?
            ORDER BY p.stock_quantity ASC
        `, [threshold]);
        return rows;
    }

    static async updateStock(productId, quantity) {
        const [result] = await db.execute(`
            UPDATE Products 
            SET stock_quantity = stock_quantity + ? 
            WHERE product_id = ?
        `, [quantity, productId]);
        
        return result.affectedRows > 0;
    }

    static async checkStock(productId, requiredQuantity) {
        const [rows] = await db.execute(`
            SELECT stock_quantity 
            FROM Products 
            WHERE product_id = ?
        `, [productId]);
        
        if (rows.length === 0) return false;
        
        return rows[0].stock_quantity >= requiredQuantity;
    }
}

module.exports = Product;
