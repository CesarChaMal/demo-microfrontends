#!/bin/bash

# Demo Microfrontends Launcher Script
# Usage: ./run.sh [mode] [environment]
# Mode: local (default), npm, nexus, github, aws
# Environment: dev (default), prod
# Examples:
#   ./run.sh local dev    # Full development environment
#   ./run.sh local prod   # Production build locally
#   ./run.sh npm prod     # NPM packages with production build
#   ./run.sh github dev   # GitHub Pages with development build
#   ./run.sh aws prod     # AWS S3 with production build
set -e

# Parse arguments
MODE=${1:-local}
ENV=${2:-dev}

echo "🚀 Starting Demo Microfrontends Application in $MODE mode ($ENV environment)..."

# Set Node.js version using nvm
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    echo "🔄 Setting Node.js version..."
    source "$HOME/.nvm/nvm.sh"
    nvm use 22.18.0
fi

# Load environment variables from .env file
load_env() {
    if [ -f ".env" ]; then
        export $(grep -v '^#' ".env" | xargs)
    fi
}

load_env

# Cross-platform npm wrapper that handles Node.js 22 + Webpack compatibility
# Windows: Runs npm directly (NODE_OPTIONS restricted by security policy)
# Linux/macOS: Sets NODE_OPTIONS=--openssl-legacy-provider for OpenSSL 3.0 compatibility
exec_npm() {
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        # Windows Git Bash - NODE_OPTIONS not allowed, run npm directly
        "$@"
    else
        # Linux/macOS/WSL - export NODE_OPTIONS to enable legacy OpenSSL provider
        # This allows older Webpack versions to work with Node.js 22's OpenSSL 3.0
        export NODE_OPTIONS="--openssl-legacy-provider"
        "$@"
    fi
}

# Set OpenSSL legacy provider for Node.js 22 compatibility with older Webpack
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "⚠️  Windows Git Bash detected - NODE_OPTIONS disabled (not supported)"
    echo "📝 Note: You may encounter OpenSSL errors on Windows with Node.js 22"
else
    echo "⚠️  Linux/macOS detected - using exported NODE_OPTIONS"
fi

# Install root dependencies first (needed for rimraf)
echo "📦 Installing root dependencies..."
exec_npm npm install

# Clean all applications
echo "🧹 Cleaning all applications..."
#npm cache clean --force
#npm run clean

# Install all dependencies
echo "📦 Installing all dependencies..."
#exec_npm npm run install:all

# Build applications based on environment
if [ "$ENV" = "prod" ]; then
    echo "🔨 Building all applications for production..."
    exec_npm npm run build:prod
else
    echo "🔨 Building all applications for development..."
#    exec_npm npm run build:dev
fi

if [ "$MODE" = "local" ]; then
    if [ "$ENV" = "prod" ]; then
        echo "🌐 Starting local production server..."
        echo "Main application: http://localhost:8080"
        echo ""
        echo "Press Ctrl+C to stop"
        exec_npm npm run serve:local:prod
    else
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
        exec_npm npm run serve:local:dev
    fi
else
    if [ "$ENV" = "prod" ]; then
        if [ "$MODE" = "aws" ]; then
            echo "🚀 Deploying to S3 first..."
            ./deploy-s3.sh prod
            echo ""
            echo "🌐 Starting production server..."
            echo "Main application: http://localhost:8080?mode=$MODE"
            echo ""
            echo "🌍 Public S3 Website (deployed):"
            echo "  ${S3_WEBSITE_URL:-http://single-spa-demo-774145483743.s3-website-eu-central-1.amazonaws.com}"
        elif [ "$MODE" = "github" ]; then
            echo "🔧 Production: Creating repos + deploying to GitHub Pages"
            exec_npm npm run serve:github &
            GITHUB_SERVER_PID=$!
            echo "📡 GitHub API server: http://localhost:3001"
            sleep 2
            echo "🌐 Starting production server..."
            echo "Main application: http://localhost:8080?mode=$MODE"
        else
            echo "🌐 Starting production server..."
            echo "Main application: http://localhost:8080?mode=$MODE"
        fi
        echo ""
        echo "Press Ctrl+C to stop"
        exec_npm npm start -- --env.mode=$MODE
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
            if [ "$ENV" = "prod" ]; then
                echo "🔧 Starting GitHub repository creation server for production..."
                exec_npm npm run serve:github &
                GITHUB_SERVER_PID=$!
                echo "📡 GitHub API server: http://localhost:3001"
                sleep 2
            else
                echo "📖 Development mode: Reading from existing GitHub Pages"
            fi
        elif [ "$MODE" = "aws" ]; then
            echo "Using AWS S3 for microfrontends"
            echo ""
            echo "🌍 Public S3 Website (if deployed):"
            echo "  ${S3_WEBSITE_URL:-http://single-spa-demo-774145483743.s3-website-eu-central-1.amazonaws.com}"
        fi
        echo ""
        echo "Press Ctrl+C to stop"
        exec_npm npm run serve:root -- --env.mode=$MODE
    fi
fi