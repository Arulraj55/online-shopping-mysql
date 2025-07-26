const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Import database connection
const db = require('./config/database');

// Import routes
const productRoutes = require('./routes/products');

// =============================================
// Middleware Setup
// =============================================

// Security middleware
app.use(helmet());

// Compression middleware
app.use(compression());

// CORS configuration
app.use(cors({
    origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : '*',
    credentials: true
}));

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging middleware
if (process.env.NODE_ENV !== 'test') {
    app.use(morgan('combined'));
}

// =============================================
// API Routes
// =============================================

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'OK',
        message: 'Online Shopping API is running',
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// Database health check
app.get('/health/db', async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT 1 as health_check');
        res.status(200).json({
            status: 'OK',
            message: 'Database connection is healthy',
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        res.status(500).json({
            status: 'ERROR',
            message: 'Database connection failed',
            timestamp: new Date().toISOString(),
            error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
        });
    }
});

// API documentation endpoint
app.get('/api', (req, res) => {
    res.json({
        message: 'Online Shopping System API',
        version: '1.0.0',
        endpoints: {
            products: '/api/products',
            customers: '/api/customers',
            orders: '/api/orders',
            reports: '/api/reports'
        },
        documentation: 'See README.md for detailed API documentation'
    });
});

// Mount API routes
app.use('/api/products', productRoutes);

// =============================================
// Error Handling Middleware
// =============================================

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({
        status: 'ERROR',
        message: 'Endpoint not found',
        path: req.originalUrl,
        method: req.method,
        timestamp: new Date().toISOString()
    });
});

// Global error handler
app.use((error, req, res, next) => {
    console.error('Error:', error);

    // Database constraint errors
    if (error.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({
            status: 'ERROR',
            message: 'Duplicate entry found',
            timestamp: new Date().toISOString()
        });
    }

    // Foreign key constraint errors
    if (error.code === 'ER_NO_REFERENCED_ROW_2') {
        return res.status(400).json({
            status: 'ERROR',
            message: 'Referenced record not found',
            timestamp: new Date().toISOString()
        });
    }

    // MySQL syntax errors
    if (error.code && error.code.startsWith('ER_')) {
        return res.status(400).json({
            status: 'ERROR',
            message: 'Database operation failed',
            timestamp: new Date().toISOString(),
            error: process.env.NODE_ENV === 'development' ? error.message : 'Bad request'
        });
    }

    // Validation errors
    if (error.name === 'ValidationError') {
        return res.status(400).json({
            status: 'ERROR',
            message: 'Validation failed',
            details: error.details,
            timestamp: new Date().toISOString()
        });
    }

    // JWT errors
    if (error.name === 'JsonWebTokenError') {
        return res.status(401).json({
            status: 'ERROR',
            message: 'Invalid token',
            timestamp: new Date().toISOString()
        });
    }

    // Default error response
    res.status(error.status || 500).json({
        status: 'ERROR',
        message: error.message || 'Internal server error',
        timestamp: new Date().toISOString(),
        ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
    });
});

// =============================================
// Server Startup
// =============================================

if (process.env.NODE_ENV !== 'test') {
    app.listen(PORT, () => {
        console.log(`
╔════════════════════════════════════════════════════════════════════════════════╗
║                        Online Shopping System API                             ║
║                            Server Started Successfully                        ║
╠════════════════════════════════════════════════════════════════════════════════╣
║  🚀 Server running on port: ${PORT.toString().padEnd(49)} ║
║  🌐 Environment: ${(process.env.NODE_ENV || 'development').padEnd(59)} ║
║  📊 Health Check: http://localhost:${PORT}/health${' '.repeat(32)} ║
║  📚 API Documentation: http://localhost:${PORT}/api${' '.repeat(29)} ║
║  💾 Database: MySQL${' '.repeat(57)} ║
╠════════════════════════════════════════════════════════════════════════════════╣
║  📋 Available Endpoints:                                                       ║
║     • GET  /api/products - Product management                                 ║
║     • GET  /api/customers - Customer management                               ║
║     • GET  /api/orders - Order processing                                     ║
║     • GET  /api/reports - Sales & inventory reports                           ║
╚════════════════════════════════════════════════════════════════════════════════╝
        `);
    });
}

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully');
    if (db && db.end) {
        db.end(() => {
            console.log('Database connection closed');
            process.exit(0);
        });
    } else {
        process.exit(0);
    }
});

module.exports = app;
