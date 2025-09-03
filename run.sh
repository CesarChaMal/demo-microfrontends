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
    nvm use 18.20.8 || {
        echo "📥 Installing Node.js 18.20.8..."
        nvm install 18.20.8
        nvm use 18.20.8
    }
elif command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node -v)
    echo "📋 Current Node.js version: $NODE_VERSION"
    if [[ ! "$NODE_VERSION" =~ ^v18\. ]]; then
        echo "⚠️  Warning: Node.js 18.x recommended, current: $NODE_VERSION"
        echo "💡 Install nvm and Node.js 18.20.8 for best compatibility"
    fi
else
    echo "❌ Node.js not found. Please install Node.js 18.20.8"
    exit 1
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
#exec_npm npm install

# Clean all applications
echo "🧹 Cleaning all applications..."
#npm cache clean --force
#npm run clean

# Install all dependencies
echo "📦 Installing all dependencies..."
#exec_npm npm run install

# Build applications based on environment
if [ "$ENV" = "prod" ]; then
    echo "🔨 Building all applications for production..."
    exec_npm npm run build:prod
else
    echo "🔨 Building all applications for development..."
#    exec_npm npm run build:dev
fi

# Define startup behavior based on mode and environment
start_local() {
    if [ "$ENV" = "prod" ]; then
        echo "🌐 Local production: Static apps + root server only"
        echo "Main application: http://localhost:8080"
        exec_npm npm run serve:local:prod
    else
        echo "🌐 Local development: Starting all 12 microfrontends"
        echo "Main application: http://localhost:8080"
        echo "Microfrontend ports: 4201-4211"
        exec_npm npm run serve:local:dev
    fi
}

start_github() {
    if [ "$ENV" = "prod" ]; then
        echo "🔧 GitHub production: Creating repos + deploying to GitHub Pages"
        exec_npm npm run serve:github &
        echo "📡 GitHub API server: http://localhost:3001"
        sleep 2
        echo "🌐 Main application: http://localhost:8080?mode=github"
        exec_npm npm run serve:root -- --env.mode=github
    else
        echo "📖 GitHub development: Reading from existing GitHub Pages"
        echo "🌐 Main application: http://localhost:8080?mode=github"
        exec_npm npm run serve:root -- --env.mode=github
    fi
}

start_aws() {
    if [ "$ENV" = "prod" ]; then
        echo "🚀 AWS production: Deploying to S3 + starting server"
        ./deploy-s3.sh prod
        echo "🌐 Main application: http://localhost:8080?mode=aws"
        echo "🌍 Public S3 Website: ${S3_WEBSITE_URL:-http://single-spa-demo-774145483743.s3-website-eu-central-1.amazonaws.com}"
        exec_npm npm run serve:root -- --env.mode=aws
    else
        echo "☁️ AWS development: Reading from S3"
        echo "🌐 Main application: http://localhost:8080?mode=aws"
        [ -n "$S3_WEBSITE_URL" ] && echo "🌍 Public S3 Website: $S3_WEBSITE_URL"
        exec_npm npm run serve:root -- --env.mode=aws
    fi
}

start_other() {
    echo "📦 Using $MODE packages for microfrontends"
    echo "🌐 Main application: http://localhost:8080?mode=$MODE"
    exec_npm npm run serve:root -- --env.mode=$MODE
}

# Route to appropriate startup function
case "$MODE" in
    "local")
        start_local
        ;;
    "github")
        start_github
        ;;
    "aws")
        start_aws
        ;;
    *)
        start_other
        ;;
esac

echo ""
echo "Press Ctrl+C to stop"