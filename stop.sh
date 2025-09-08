#!/bin/bash

# Load environment variables from .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' ".env" | xargs)
fi

echo "🛑 Stopping Demo Microfrontends Applications..."

# Ports used by the microfrontends and CORS proxy
CORS_PROXY_PORT=${NEXUS_CORS_PROXY_PORT:-8082}
PORTS=(8080 4201 4202 4203 4204 4205 4206 4207 4208 4209 4210 4211 $CORS_PROXY_PORT)

for port in "${PORTS[@]}"; do
    echo "Checking port $port..."
    
    # Find and kill processes on the port
    if command -v lsof > /dev/null; then
        # macOS/Linux with lsof
        pids=$(lsof -ti:$port 2>/dev/null)
    else
        # Linux with netstat
        pids=$(netstat -tlnp 2>/dev/null | grep ":$port " | awk '{print $7}' | cut -d'/' -f1)
    fi
    
    if [ ! -z "$pids" ]; then
        echo "Killing processes on port $port: $pids"
        echo $pids | xargs kill -9 2>/dev/null
    fi
done

# Stop CORS proxy specifically
echo "Stopping CORS proxy..."
pkill -f cors-proxy.js 2>/dev/null || true
pkill -f "node.*cors-proxy" 2>/dev/null || true

# Clean up CORS proxy files
if [ -f "cors-proxy.pid" ]; then
    rm cors-proxy.pid
fi
if [ -f "scripts/cors-proxy.pid" ]; then
    rm scripts/cors-proxy.pid
fi

echo "✅ All microfrontend applications and CORS proxy stopped"