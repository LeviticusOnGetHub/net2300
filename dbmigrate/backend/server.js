const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors({
    origin: '*', // Allow all origins (for development/testing)
    methods: ['GET', 'POST', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// MariaDB connection pool
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'logdb',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Initialize database and table
async function initDatabase() {
    try {
        const connection = await pool.getConnection();
        
        // Create database if it doesn't exist
        await connection.query(`CREATE DATABASE IF NOT EXISTS ${process.env.DB_NAME || 'logdb'}`);
        await connection.query(`USE ${process.env.DB_NAME || 'logdb'}`);
        
        // Create logs table if it doesn't exist
        await connection.query(`
            CREATE TABLE IF NOT EXISTS logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                message TEXT NOT NULL,
                status ENUM('pending', 'processing', 'done', 'error') DEFAULT 'pending',
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_timestamp (timestamp),
                INDEX idx_status (status)
            )
        `);
        
        // Create execution_log table if it doesn't exist
        await connection.query(`
            CREATE TABLE IF NOT EXISTS execution_log (
                id INT AUTO_INCREMENT PRIMARY KEY,
                log_id INT,
                command TEXT NOT NULL,
                output TEXT,
                exit_code INT,
                executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_log_id (log_id),
                INDEX idx_executed_at (executed_at),
                FOREIGN KEY (log_id) REFERENCES logs(id) ON DELETE SET NULL
            )
        `);

        // Create the table used to list completed database dumps for import.
        await connection.query(`
            CREATE TABLE IF NOT EXISTS export_log (
                id INT AUTO_INCREMENT PRIMARY KEY,
                database_name VARCHAR(100) NOT NULL,
                filename VARCHAR(255) NOT NULL,
                status ENUM('pending', 'success', 'error') DEFAULT 'pending',
                output TEXT,
                file_size BIGINT,
                exported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_database_name (database_name),
                INDEX idx_status (status),
                INDEX idx_exported_at (exported_at)
            )
        `);
        
        connection.release();
        console.log('✓ Database and tables initialized');
    } catch (error) {
        console.error('Database initialization error:', error);
        throw error;
    }
}

// API Routes

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Get all logs
app.get('/api/logs', async (req, res) => {
    try {
        const [rows] = await pool.query(
            'SELECT * FROM logs ORDER BY timestamp DESC LIMIT 100'
        );
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error fetching logs:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Create a new log entry
app.post('/api/logs', async (req, res) => {
    try {
        const { message, status } = req.body;
        
        // Validation
        if (!message) {
            return res.status(400).json({ 
                success: false, 
                error: 'Message is required' 
            });
        }

        // Validate status if provided
        const validStatuses = ['pending', 'processing', 'done', 'error'];
        const logStatus = status && validStatuses.includes(status) ? status : 'pending';

        const [result] = await pool.query(
            'INSERT INTO logs (message, status) VALUES (?, ?)',
            [message, logStatus]
        );

        res.status(201).json({ 
            success: true, 
            data: { 
                id: result.insertId,
                message,
                status: logStatus
            }
        });
    } catch (error) {
        console.error('Error creating log:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Delete a log entry
app.delete('/api/logs/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const [result] = await pool.query('DELETE FROM logs WHERE id = ?', [id]);
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, error: 'Log not found' });
        }
        
        res.json({ success: true, message: 'Log deleted successfully' });
    } catch (error) {
        console.error('Error deleting log:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Update log status
app.patch('/api/logs/:id/status', async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        
        // Validate status
        const validStatuses = ['pending', 'processing', 'done', 'error'];
        if (!status || !validStatuses.includes(status)) {
            return res.status(400).json({ 
                success: false, 
                error: 'Invalid status. Must be: pending, processing, done, or error' 
            });
        }
        
        const [result] = await pool.query(
            'UPDATE logs SET status = ? WHERE id = ?',
            [status, id]
        );
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, error: 'Log not found' });
        }
        
        res.json({ success: true, message: 'Status updated successfully', status });
    } catch (error) {
        console.error('Error updating status:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Clear all logs
app.delete('/api/logs', async (req, res) => {
    try {
        await pool.query('TRUNCATE TABLE logs');
        res.json({ success: true, message: 'All logs cleared' });
    } catch (error) {
        console.error('Error clearing logs:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// ========== Execution Log Endpoints ==========

// Get all execution logs
app.get('/api/execution-logs', async (req, res) => {
    try {
        const [rows] = await pool.query(
            'SELECT * FROM execution_log ORDER BY executed_at DESC LIMIT 100'
        );
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error fetching execution logs:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get execution logs for a specific log_id
app.get('/api/execution-logs/log/:log_id', async (req, res) => {
    try {
        const { log_id } = req.params;
        const [rows] = await pool.query(
            'SELECT * FROM execution_log WHERE log_id = ? ORDER BY executed_at DESC',
            [log_id]
        );
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error fetching execution logs:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Create a new execution log entry
app.post('/api/execution-logs', async (req, res) => {
    try {
        const { log_id, command, output, exit_code } = req.body;
        
        // Validation
        if (!command) {
            return res.status(400).json({ 
                success: false, 
                error: 'Command is required' 
            });
        }

        const [result] = await pool.query(
            'INSERT INTO execution_log (log_id, command, output, exit_code) VALUES (?, ?, ?, ?)',
            [log_id || null, command, output || null, exit_code || null]
        );

        res.status(201).json({ 
            success: true, 
            data: { 
                id: result.insertId,
                log_id,
                command,
                output,
                exit_code
            }
        });
    } catch (error) {
        console.error('Error creating execution log:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Delete an execution log entry
app.delete('/api/execution-logs/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const [result] = await pool.query('DELETE FROM execution_log WHERE id = ?', [id]);
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, error: 'Execution log not found' });
        }
        
        res.json({ success: true, message: 'Execution log deleted successfully' });
    } catch (error) {
        console.error('Error deleting execution log:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Clear all execution logs
app.delete('/api/execution-logs', async (req, res) => {
    try {
        await pool.query('TRUNCATE TABLE execution_log');
        res.json({ success: true, message: 'All execution logs cleared' });
    } catch (error) {
        console.error('Error clearing execution logs:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// ========== Export Log Endpoints ==========

// Get all export logs
app.get('/api/export-logs', async (req, res) => {
    try {
        const [rows] = await pool.query(
            'SELECT * FROM export_log ORDER BY exported_at DESC LIMIT 100'
        );
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error fetching export logs:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Delete an export log entry
app.delete('/api/export-logs/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const [result] = await pool.query('DELETE FROM export_log WHERE id = ?', [id]);
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, error: 'Export log not found' });
        }
        
        res.json({ success: true, message: 'Export log deleted successfully' });
    } catch (error) {
        console.error('Error deleting export log:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Clear all export logs
app.delete('/api/export-logs', async (req, res) => {
    try {
        await pool.query('TRUNCATE TABLE export_log');
        res.json({ success: true, message: 'All export logs cleared' });
    } catch (error) {
        console.error('Error clearing export logs:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Start server
async function startServer() {
    try {
        await initDatabase();
        app.listen(PORT, '0.0.0.0', () => {
            console.log(`✓ Server running on http://0.0.0.0:${PORT}`);
            console.log(`✓ Health check: http://localhost:${PORT}/api/health`);
            console.log(`✓ API endpoint: http://localhost:${PORT}/api/logs`);
        });
    } catch (error) {
        console.error('Failed to start server:', error);
        process.exit(1);
    }
}

startServer();
