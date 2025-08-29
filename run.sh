#!/bin/bash

# Demo Microfrontends Launcher Script
set -e

# Parse mode argument (default: local)
MODE=${1:-local}

echo "🚀 Starting Demo Microfrontends Application in $MODE mode..."

# Set Node.js version using nvm
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    echo "🔄 Setting Node.js version..."
    source "$HOME/.nvm/nvm.sh"
    nvm use 22.18.0
fi

# Set OpenSSL legacy provider for Node.js 22 compatibility with older Webpack
export NODE_OPTIONS="--openssl-legacy-provider"

# Install root dependencies first (needed for rimraf)
echo "📦 Installing root dependencies..."
npm install

# Clean all applications
echo "🧹 Cleaning all applications..."
#npm cache clean --force
#npm run clean

# Install all dependencies
echo "📦 Installing all dependencies..."
npm run install:all

# Build all applications (needed for all modes)
echo "🔨 Building all applications..."
npm run build:all

if [ "$MODE" = "local" ]; then
    echo "🌐 Starting all microfrontends..."
    echo "Main application: http://localhost:8080"
    echo ""
    echo "Microfrontend ports:"
    echo "  - Auth App: http://localhost:4201"
    echo "  - Layout App: http://localhost:4202"
    echo "  - Home App: http://localhost:4203"
    echo "  - Angular App: http://localhost:4204"
    echo "  - Vue App: http://localhost:4205"
    echo "  - React App: http://localhost:4206"
    echo "  - Vanilla App: http://localhost:4207"
    echo "  - Web Components App: http://localhost:4208"
    echo "  - TypeScript App: http://localhost:4209"
    echo "  - jQuery App: http://localhost:4210"
    echo "  - Svelte App: http://localhost:4211"
    echo ""
    echo "Press Ctrl+C to stop all services"
    
    # Start all microfrontends and root app
    npm run dev:all
#    npm run serve:root -- --env.mode=$MODE
else
    echo "🌐 Starting development server..."
    echo "Main application: http://localhost:8080?mode=$MODE"
    echo ""

    if [ "$MODE" = "npm" ]; then
        echo "Using NPM packages for microfrontends"
    elif [ "$MODE" = "nexus" ]; then
        echo "Using Nexus private registry for microfrontends"
    elif [ "$MODE" = "github" ]; then
        echo "Using GitHub Pages for microfrontends"
    fi

    echo ""
    echo "Press Ctrl+C to stop"

    # Start with mode parameter
    npm run serve:root -- --env.mode=$MODE
fi