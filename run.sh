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

# Update .env file with current mode and environment
echo "📝 Updating SPA configuration in .env..."
sed -i "s/^SPA_MODE=.*/SPA_MODE=$MODE/" .env
sed -i "s/^SPA_ENV=.*/SPA_ENV=$ENV/" .env

echo "🚀 Starting Demo Microfrontends Application in $MODE mode ($ENV environment)..."
echo "🔍 DEBUG: Script execution started at $(date)"
echo "🔍 DEBUG: Working directory: $(pwd)"
echo "🔍 DEBUG: User: $(whoami)"
echo "🔍 DEBUG: Shell: $SHELL"
echo "🔍 DEBUG: Platform: $(uname -s 2>/dev/null || echo 'Windows')"

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
exec_npm npm install

# Clean all applications
echo "🧹 Cleaning all applications..."
#npm cache clean --force
#npm run clean

# Install all dependencies
echo "📦 Installing all dependencies..."
exec_npm npm run install:all

# Build applications based on environment
if [ "$ENV" = "prod" ]; then
    echo "🔨 Building all applications for production..."
    exec_npm npm run build:prod
#else
#    echo "🔨 Building all applications for development..."
#    exec_npm npm run build:dev
fi

# Define startup behavior based on mode and environment
start_local() {
    echo "🔍 DEBUG: Local mode - ENV=$ENV, NODE_VERSION=$(node --version), NPM_VERSION=$(npm --version)"
    echo "🔍 DEBUG: Available ports check:"
    for port in 8080 4201 4202 4203 4204 4205 4206 4207 4208 4209 4210 4211; do
        if lsof -i :$port >/dev/null 2>&1; then
            echo "🔍 DEBUG: Port $port is in use"
        else
            echo "🔍 DEBUG: Port $port is available"
        fi
    done
    
    if [ "$ENV" = "prod" ]; then
        echo "🌐 Local production: Static apps + root server only"
        echo "🔍 DEBUG: Production mode - serving built files from single-spa-root/dist"
        echo "Main application: http://localhost:8080"
        exec_npm npm run serve:local:prod
    else
        echo "🌐 Local development: Starting all 12 microfrontends"
        echo "🔍 DEBUG: Development mode - starting individual servers on ports 4201-4211"
        echo "Main application: http://localhost:8080"
        echo "Microfrontend ports: 4201-4211"
        exec_npm npm run serve:local:dev
    fi
}

start_github() {
    echo "🔍 DEBUG: GitHub mode - ENV=$ENV, GITHUB_TOKEN=${GITHUB_TOKEN:+SET}, GITHUB_USERNAME=${GITHUB_USERNAME:-NOT_SET}"
    
    if [ "$ENV" = "prod" ]; then
        echo "🔧 GitHub production: Deploying all microfrontends to GitHub Pages"
        
        # Check prerequisites
        if [ -z "$GITHUB_TOKEN" ]; then
            echo "❌ Error: GITHUB_TOKEN not set in .env"
            exit 1
        fi
        
        # Deploy each microfrontend using existing scripts
        APPS=("auth" "layout" "home" "angular" "vue" "react" "vanilla" "webcomponents" "typescript" "jquery" "svelte")
        
        for app in "${APPS[@]}"; do
            echo "📤 Deploying $app app to GitHub Pages..."
            echo "🔍 DEBUG: Running ./scripts/deploy-github.sh single-spa-${app}-app"
            if ./scripts/deploy-github.sh single-spa-${app}-app; then
                echo "✅ $app deployment successful"
            else
                echo "❌ $app deployment failed"
                exit 1
            fi
        done
        
        # Deploy root application
        echo "📤 Deploying root application to GitHub Pages..."
        echo "🔍 DEBUG: Running ./scripts/deploy-github.sh root"
        if ./scripts/deploy-github.sh root; then
            echo "✅ Root deployment successful"
        else
            echo "❌ Root deployment failed"
            exit 1
        fi
        
        echo "✅ All deployments complete!"
        echo "🌐 Main application: http://localhost:8080?mode=github"
        exec_npm npm run serve:root -- --env.mode=github
    else
        echo "📖 GitHub development: Reading from existing GitHub Pages"
        echo "🔍 DEBUG: GitHub username: ${GITHUB_USERNAME:-cesarchamal}"
        echo "🌐 Main application: http://localhost:8080?mode=github"
        exec_npm npm run serve:root -- --env.mode=github
    fi
}

start_aws() {
    echo "🔍 DEBUG: AWS mode - ENV=$ENV, S3_BUCKET=${S3_BUCKET:-NOT_SET}, AWS_REGION=${AWS_REGION:-NOT_SET}, ORG_NAME=${ORG_NAME:-NOT_SET}"
    
    if [ "$ENV" = "prod" ]; then
        echo "🚀 AWS production: Deploying all microfrontends to S3"
        
        # Check prerequisites
        if [ -z "$S3_BUCKET" ]; then
            echo "❌ Error: S3_BUCKET not set in .env"
            exit 1
        fi
        if [ -z "$AWS_REGION" ]; then
            echo "❌ Error: AWS_REGION not set in .env"
            exit 1
        fi
        
        # Deploy all microfrontends to S3 using existing script
        echo "🔍 DEBUG: Running ./scripts/deploy-s3.sh prod"
        if ./scripts/deploy-s3.sh prod; then
            echo "✅ S3 deployment successful"
        else
            echo "❌ S3 deployment failed"
            exit 1
        fi
        
        echo "✅ S3 deployment complete!"
        echo "🌐 Main application: http://localhost:8080?mode=aws"
        echo "🌍 Public S3 Website: ${S3_WEBSITE_URL:-http://single-spa-demo-774145483743.s3-website-eu-central-1.amazonaws.com}"
        exec_npm npm run serve:root -- --env.mode=aws
    else
        echo "☁️ AWS development: Reading from S3"
        echo "🔍 DEBUG: Import map URL: https://${S3_BUCKET:-single-spa-demo-774145483743}.s3.${AWS_REGION:-eu-central-1}.amazonaws.com/@${ORG_NAME:-cesarchamal}/importmap.json"
        echo "🌐 Main application: http://localhost:8080?mode=aws"
        [ -n "$S3_WEBSITE_URL" ] && echo "🌍 Public S3 Website: $S3_WEBSITE_URL"
        exec_npm npm run serve:root -- --env.mode=aws
    fi
}

start_npm() {
    echo "🔍 DEBUG: NPM mode - ENV=$ENV, NPM_TOKEN=${NPM_TOKEN:+SET}"
    
    if [ "$ENV" = "prod" ]; then
        echo "📦 NPM production: Publishing all packages to NPM"
        
        # Check if user is logged in to NPM
        if ! npm whoami >/dev/null 2>&1; then
            echo "❌ Error: Not logged in to NPM. Run 'npm login' first"
            exit 1
        fi
        
        echo "🔍 DEBUG: NPM user: $(npm whoami)"
        
        # Publish all packages using existing script
        echo "🔍 DEBUG: Running ./scripts/publish-all.sh patch"
        if ./scripts/publish-all.sh patch; then
            echo "✅ NPM publishing successful"
        else
            echo "❌ NPM publishing failed"
            exit 1
        fi
        
        echo "✅ NPM publishing complete!"
        echo "📦 Switching to NPM mode and starting server..."
        npm run mode:npm
        echo "🌐 Main application: http://localhost:8080?mode=npm"
        exec_npm npm run serve:npm
    else
        echo "📦 NPM development: Using existing NPM packages"
        echo "🔍 DEBUG: Switching to NPM mode"
        npm run mode:npm
        echo "🌐 Main application: http://localhost:8080?mode=npm"
        exec_npm npm run serve:npm
    fi
}

start_nexus() {
    echo "🔍 DEBUG: Nexus mode - ENV=$ENV, NEXUS_REGISTRY=${NEXUS_REGISTRY:-NOT_SET}"
    echo "🔍 DEBUG: NPM registry: $(npm config get registry)"
    echo "🔍 DEBUG: NPM user: $(npm whoami 2>/dev/null || echo 'Not logged in')"
    
    echo "📦 Using Nexus packages for microfrontends"
    echo "🔍 DEBUG: Loading @cesarchamal scoped packages from Nexus registry"
    echo "🌐 Main application: http://localhost:8080?mode=nexus"
    exec_npm npm run serve:root -- --env.mode=nexus
}

start_other() {
    echo "🔍 DEBUG: Other mode ($MODE) - ENV=$ENV"
    echo "🔍 DEBUG: Custom mode configuration may be required"
    echo "📦 Using $MODE packages for microfrontends"
    echo "🌐 Main application: http://localhost:8080?mode=$MODE"
    exec_npm npm run serve:root -- --env.mode=$MODE
}

# Route to appropriate startup function
case "$MODE" in
    "local")
        start_local
        ;;
    "npm")
        start_npm
        ;;
    "nexus")
        start_nexus
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