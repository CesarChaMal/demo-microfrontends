#!/bin/bash

# Demo Microfrontends Launcher Script
# This script bootstraps and runs the Single-SPA microfrontends application

set -e

echo "🚀 Starting Demo Microfrontends Application..."

# Navigate to root application directory
cd single-spa-login-example-with-npm-packages

# Check if node_modules exists, if not run bootstrap
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies for all applications..."
    npm run bootstrap
else
    echo "✅ Dependencies already installed"
fi

# Start the development server
echo "🌐 Starting development servers..."
echo "Root application will be available at: http://localhost:8080"
echo ""
echo "Individual microfrontends:"
echo "  - Auth App: http://localhost:4201"
echo "  - Layout App: http://localhost:4202" 
echo "  - Home App: http://localhost:4203"
echo "  - Angular App: http://localhost:4204"
echo "  - Vue App: http://localhost:4205"
echo "  - React App: http://localhost:4206"
echo ""
echo "Press Ctrl+C to stop all servers"
echo ""

npm run serve