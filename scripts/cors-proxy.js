const http = require('http');
const httpProxy = require('http-proxy-middleware');
const express = require('express');
const path = require('path');

// Load environment variables from .env file
try {
  require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
} catch (error) {
  console.warn('dotenv not found, using system environment variables only');
}

const PORT = process.env.NEXUS_CORS_PROXY_PORT || 8082;
const NEXUS_URL = process.env.NEXUS_URL || 'http://localhost:8081';
const ALLOWED_ORIGINS = process.env.NEXUS_CORS_ALLOWED_ORIGINS || '*';
const ALLOWED_METHODS = process.env.NEXUS_CORS_ALLOWED_METHODS || 'GET, POST, PUT, DELETE, HEAD, OPTIONS';
const ALLOWED_HEADERS = process.env.NEXUS_CORS_ALLOWED_HEADERS || '*';
const EXPOSED_HEADERS = process.env.NEXUS_CORS_EXPOSED_HEADERS || '*';
const ALLOW_CREDENTIALS = process.env.NEXUS_CORS_ALLOW_CREDENTIALS === 'true';
const PROXY_ENABLED = process.env.NEXUS_CORS_PROXY_ENABLED !== 'false';

// Check if CORS proxy is enabled
if (!PROXY_ENABLED) {
  console.log('⚠️ CORS proxy is disabled in configuration');
  process.exit(0);
}

console.log('🔧 Starting Node.js CORS proxy for Nexus...');
console.log('📋 Configuration:');
console.log(`   - Proxy port: ${PORT}`);
console.log(`   - Nexus URL: ${NEXUS_URL}`);
console.log(`   - Enabled: ${PROXY_ENABLED}`);

const app = express();

// CORS middleware
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', ALLOWED_ORIGINS);
    res.header('Access-Control-Allow-Methods', ALLOWED_METHODS);
    res.header('Access-Control-Allow-Headers', ALLOWED_HEADERS);
    res.header('Access-Control-Expose-Headers', EXPOSED_HEADERS);
    if (ALLOW_CREDENTIALS) {
        res.header('Access-Control-Allow-Credentials', 'true');
    }
    
    if (req.method === 'OPTIONS') {
        res.header('Access-Control-Max-Age', '86400');
        return res.status(204).end();
    }
    next();
});

// Proxy middleware
const proxy = httpProxy.createProxyMiddleware({
    target: NEXUS_URL,
    changeOrigin: true,
    logLevel: 'info'
});

app.use('/', proxy);

const server = app.listen(PORT, () => {
    console.log(`🚀 CORS proxy running on http://localhost:${PORT}`);
    console.log(`📦 Proxying to Nexus: ${NEXUS_URL}`);
    console.log(`🌐 NPM registry: http://localhost:${PORT}/repository/npm-group/`);
    console.log(`🔧 CORS configuration:`);
    console.log(`   - Origins: ${ALLOWED_ORIGINS}`);
    console.log(`   - Methods: ${ALLOWED_METHODS}`);
    console.log(`   - Credentials: ${ALLOW_CREDENTIALS}`);
});

server.on('error', (error) => {
    if (error.code === 'EADDRINUSE') {
        console.error(`❌ Port ${PORT} is already in use. Please stop the service using this port.`);
        process.exit(1);
    } else {
        console.error(`❌ Server error:`, error);
        process.exit(1);
    }
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down CORS proxy...');
    server.close(() => {
        console.log('✅ CORS proxy stopped');
        process.exit(0);
    });
});

process.on('SIGTERM', () => {
    console.log('\n🛑 Shutting down CORS proxy...');
    server.close(() => {
        console.log('✅ CORS proxy stopped');
        process.exit(0);
    });
});