#!/bin/bash

# Load environment variables from .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' ".env" | xargs)
fi

# Use environment variables with defaults
NEXUS_CORS_PROXY_PORT=${NEXUS_CORS_PROXY_PORT:-8082}
NEXUS_URL=${NEXUS_URL:-http://localhost:8081}
NEXUS_CORS_PROXY_ENABLED=${NEXUS_CORS_PROXY_ENABLED:-true}

echo "🔧 Starting Node.js CORS proxy for Nexus..."
echo "📋 Configuration:"
echo "   - Proxy port: $NEXUS_CORS_PROXY_PORT"
echo "   - Nexus URL: $NEXUS_URL"
echo "   - Enabled: $NEXUS_CORS_PROXY_ENABLED"

# Check if CORS proxy is enabled
if [ "$NEXUS_CORS_PROXY_ENABLED" != "true" ]; then
    echo "⚠️ CORS proxy is disabled in configuration"
    exit 0
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js from https://nodejs.org"
    exit 1
fi

# Check if dependencies are installed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install express http-proxy-middleware dotenv
fi

# Test Nexus connectivity
echo "🔍 Testing Nexus connectivity..."
if ! curl -s "$NEXUS_URL" > /dev/null; then
    echo "❌ Nexus not accessible on $NEXUS_URL. Please start Nexus first."
    exit 1
fi

# Check if port is available
if netstat -an 2>/dev/null | grep -q ":$NEXUS_CORS_PROXY_PORT.*LISTEN" || ss -an 2>/dev/null | grep -q ":$NEXUS_CORS_PROXY_PORT.*LISTEN"; then
    echo "❌ Port $NEXUS_CORS_PROXY_PORT is already in use. Please stop the service using this port."
    exit 1
fi

echo "🚀 Starting CORS proxy on port $NEXUS_CORS_PROXY_PORT..."
cd scripts
node cors-proxy.js