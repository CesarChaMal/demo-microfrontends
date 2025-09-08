#!/bin/bash

echo "🛑 Stopping Demo Microfrontends Applications..."

# Ports used by the microfrontends
PORTS=(8080 4201 4202 4203 4204 4205 4206 4207 4208 4209 4210 4211)

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

echo "✅ All microfrontend applications stopped"