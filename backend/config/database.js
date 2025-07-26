const mysql = require('mysql2/promise');
require('dotenv').config();

// Database configuration
const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'online_shopping',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    acquireTimeout: 60000,
    timeout: 60000,
    enableKeepAlive: true,
    keepAliveInitialDelay: 0,
    timezone: '+00:00'
};

// Create connection pool
const pool = mysql.createPool(dbConfig);

// Test database connection
const testConnection = async () => {
    try {
        const connection = await pool.getConnection();
        console.log('✅ Database connected successfully');
        
        // Test query
        const [rows] = await connection.execute('SELECT 1 as test');
        console.log('✅ Database query test passed');
        
        connection.release();
        return true;
    } catch (error) {
        console.error('❌ Database connection failed:', error.message);
        return false;
    }
};

// Initialize database connection
const initDatabase = async () => {
    const isConnected = await testConnection();
    if (!isConnected) {
        console.error('Failed to connect to database. Please check your configuration.');
        if (process.env.NODE_ENV !== 'test') {
            process.exit(1);
        }
    }
};

// Call initialization if not in test environment
if (process.env.NODE_ENV !== 'test') {
    initDatabase();
}

// Helper function to execute queries with error handling
const executeQuery = async (query, params = []) => {
    try {
        const [rows, fields] = await pool.execute(query, params);
        return { success: true, data: rows, fields };
    } catch (error) {
        console.error('Database query error:', error);
        return { 
            success: false, 
            error: error.message, 
            code: error.code,
            sqlState: error.sqlState 
        };
    }
};

// Helper function to execute stored procedures
const callProcedure = async (procedureName, params = []) => {
    try {
        const placeholders = params.map(() => '?').join(', ');
        const query = `CALL ${procedureName}(${placeholders})`;
        const [rows] = await pool.execute(query, params);
        return { success: true, data: rows };
    } catch (error) {
        console.error('Stored procedure error:', error);
        return { 
            success: false, 
            error: error.message, 
            code: error.code,
            sqlState: error.sqlState 
        };
    }
};

// Helper function to execute transactions
const executeTransaction = async (queries) => {
    const connection = await pool.getConnection();
    
    try {
        await connection.beginTransaction();
        
        const results = [];
        for (const { query, params } of queries) {
            const [rows] = await connection.execute(query, params || []);
            results.push(rows);
        }
        
        await connection.commit();
        return { success: true, data: results };
    } catch (error) {
        await connection.rollback();
        console.error('Transaction error:', error);
        return { 
            success: false, 
            error: error.message, 
            code: error.code 
        };
    } finally {
        connection.release();
    }
};

// Helper function to get table statistics
const getTableStats = async () => {
    try {
        const query = `
            SELECT 
                TABLE_NAME as table_name,
                TABLE_ROWS as estimated_rows,
                ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) as size_mb
            FROM information_schema.TABLES 
            WHERE TABLE_SCHEMA = ? 
            ORDER BY size_mb DESC
        `;
        const [rows] = await pool.execute(query, [process.env.DB_NAME || 'online_shopping']);
        return { success: true, data: rows };
    } catch (error) {
        return { success: false, error: error.message };
    }
};

// Helper function to check database health
const healthCheck = async () => {
    try {
        const [rows] = await pool.execute('SELECT 1 as health, NOW() as timestamp');
        const stats = await getTableStats();
        
        return {
            status: 'healthy',
            timestamp: new Date().toISOString(),
            connection: 'active',
            tables: stats.success ? stats.data : [],
            config: {
                host: dbConfig.host,
                port: dbConfig.port,
                database: dbConfig.database,
                connectionLimit: dbConfig.connectionLimit
            }
        };
    } catch (error) {
        return {
            status: 'unhealthy',
            timestamp: new Date().toISOString(),
            error: error.message
        };
    }
};

// Graceful shutdown
const closePool = async () => {
    try {
        await pool.end();
        console.log('✅ Database connection pool closed');
    } catch (error) {
        console.error('❌ Error closing database pool:', error);
    }
};

module.exports = {
    pool,
    executeQuery,
    callProcedure,
    executeTransaction,
    getTableStats,
    healthCheck,
    closePool,
    // Export pool.execute for backward compatibility
    execute: pool.execute.bind(pool),
    getConnection: pool.getConnection.bind(pool)
};
