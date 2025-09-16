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
# Enhanced platform detection
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    PLATFORM="Windows Git Bash"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if grep -q Microsoft /proc/version 2>/dev/null; then
        PLATFORM="WSL Ubuntu"
    elif grep -q "Pop" /etc/os-release 2>/dev/null; then
        PLATFORM="Pop!_OS"
    else
        PLATFORM="Linux"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macOS"
else
    PLATFORM="Unknown"
fi
echo "🔍 DEBUG: Platform: $PLATFORM"

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
# Windows Git Bash: NODE_OPTIONS restricted by security policy
# Linux/Pop!_OS/WSL: Sets NODE_OPTIONS=--openssl-legacy-provider for OpenSSL 3.0 compatibility
exec_npm() {
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        # Windows Git Bash - NODE_OPTIONS not allowed, run npm directly
        "$@"
    else
        # Linux/Pop!_OS/WSL/macOS - export NODE_OPTIONS to enable legacy OpenSSL provider
        # This allows older Webpack versions to work with Node.js 22's OpenSSL 3.0
        export NODE_OPTIONS="--openssl-legacy-provider"
        "$@"
    fi
}

# Platform-specific setup messages
case "$PLATFORM" in
    "Windows Git Bash")
        echo "⚠️  $PLATFORM detected - NODE_OPTIONS disabled (security policy)"
        echo "📝 Note: You may encounter OpenSSL errors with Node.js 22"
        ;;
    "WSL Ubuntu")
        echo "⚠️  $PLATFORM detected - using NODE_OPTIONS for OpenSSL compatibility"
        echo "📝 Note: WSL provides Linux compatibility layer"
        ;;
    "Pop!_OS")
        echo "⚠️  $PLATFORM detected - using NODE_OPTIONS for OpenSSL compatibility"
        echo "📝 Note: Ubuntu-based distribution with enhanced compatibility"
        ;;
    "Linux")
        echo "⚠️  $PLATFORM detected - using NODE_OPTIONS for OpenSSL compatibility"
        ;;
    "macOS")
        echo "⚠️  $PLATFORM detected - using NODE_OPTIONS for OpenSSL compatibility"
        ;;
    *)
        echo "⚠️  Unknown platform - attempting Linux/Unix compatibility"
        ;;
esac

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
else
    echo "🔨 Building all applications for development..."
    exec_npm npm run build:dev
fi

# Define startup behavior based on mode and environment
start_local() {
    echo "🔍 DEBUG: Local mode - ENV=$ENV, NODE_VERSION=$(node --version), NPM_VERSION=$(npm --version)"
    echo "🔍 DEBUG: Available ports check:"
    for port in 8080 4201 4202 4203 4204 4205 4206 4207 4208 4209 4210 4211; do
        # Cross-platform port checking
        if command -v lsof >/dev/null 2>&1; then
            # Linux/macOS/WSL with lsof
            if lsof -i :$port >/dev/null 2>&1; then
                echo "🔍 DEBUG: Port $port is in use"
            else
                echo "🔍 DEBUG: Port $port is available"
            fi
        elif command -v netstat >/dev/null 2>&1; then
            # Windows Git Bash with netstat
            if netstat -an | grep ":$port " >/dev/null 2>&1; then
                echo "🔍 DEBUG: Port $port is in use"
            else
                echo "🔍 DEBUG: Port $port is available"
            fi
        else
            echo "🔍 DEBUG: Port $port - unable to check (no lsof/netstat)"
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

    # Check prerequisites for both dev and prod
    if [ -z "$GITHUB_TOKEN" ]; then
        echo "❌ Error: GITHUB_TOKEN not set in .env"
        exit 1
    fi

    # Deploy all microfrontends to GitHub Pages in both dev and prod
    echo "🚀 GitHub mode: Deploying all microfrontends to GitHub Pages"

    # Deploy each microfrontend using existing scripts
    APPS=("auth" "layout" "home" "angular" "vue" "react" "vanilla" "webcomponents" "typescript" "jquery" "svelte")

    for app in "${APPS[@]}"; do
        echo "📤 Deploying $app app to GitHub Pages..."
        echo "🔍 DEBUG: Running npm run deploy:github:$app"
        if npm run deploy:github:$app; then
            echo "✅ $app deployment successful"
        else
            echo "❌ $app deployment failed"
            exit 1
        fi
    done

    # Deploy root application
    echo "📤 Deploying root application to GitHub Pages..."
    echo "🔍 DEBUG: Running npm run deploy:github:root"
    if npm run deploy:github:root; then
        echo "✅ Root deployment successful"
    else
        echo "❌ Root deployment failed"
        exit 1
    fi

    echo "✅ All deployments complete!"
    echo "🌐 Main application: http://localhost:8080?mode=github"

    if [ "$ENV" = "prod" ]; then
        echo "🌍 Public GitHub Pages: https://${GITHUB_USERNAME:-cesarchamal}.github.io/single-spa-root/"
        echo "🌐 Production: Both local server AND public GitHub Pages available"
    else
        echo "📖 Development: Local server with GitHub Pages deployment"
    fi

    echo "🔍 DEBUG: GitHub username: ${GITHUB_USERNAME:-cesarchamal}"
    exec_npm npm run serve:root -- --env.mode=github
}

start_aws() {
    echo "🔍 DEBUG: AWS mode - ENV=$ENV, S3_BUCKET=${S3_BUCKET:-NOT_SET}, AWS_REGION=${AWS_REGION:-NOT_SET}, ORG_NAME=${ORG_NAME:-NOT_SET}"

    # Check prerequisites for both dev and prod
    if [ -z "$S3_BUCKET" ]; then
        echo "❌ Error: S3_BUCKET not set in .env"
        exit 1
    fi
    if [ -z "$AWS_REGION" ]; then
        echo "❌ Error: AWS_REGION not set in .env"
        exit 1
    fi
    if [ -z "$ORG_NAME" ]; then
        echo "❌ Error: ORG_NAME not set in .env"
        exit 1
    fi

    # Build root application with AWS mode configuration
    echo "🔨 Building root application for AWS S3 deployment..."
    exec_npm npm run build:prod -- --env.mode=aws

    # Deploy all microfrontends to S3 in both dev and prod
    echo "🚀 AWS mode: Deploying all microfrontends to S3"
    echo "🔍 DEBUG: Running npm run deploy:s3:$ENV"
    if SKIP_BUILD=true npm run deploy:s3:$ENV; then
        echo "✅ S3 deployment successful"
    else
        echo "❌ S3 deployment failed"
        exit 1
    fi

    # Set S3 website URL for display
    S3_WEBSITE_URL_DISPLAY="${S3_WEBSITE_URL:-http://$S3_BUCKET.s3-website,$AWS_REGION.amazonaws.com}"

    echo "✅ S3 deployment complete!"
    if [ "$ENV" = "prod" ]; then
        echo "🌍 Production S3 Website: $S3_WEBSITE_URL_DISPLAY"
        echo "🌍 Production: Both local server AND public website available"
        echo "🔗 Direct S3 Link: $S3_WEBSITE_URL_DISPLAY/index.html?mode=aws"
        echo "🌍 Main application: http://localhost:8080?mode=aws"
    else
        echo "📖 Development: Local server with S3 deployment"
        echo "🔗 S3 Development Site: $S3_WEBSITE_URL_DISPLAY/index.html?mode=aws"
        echo "🌍 Main application: http://localhost:8080?mode=aws"
    fi

    echo "🔍 DEBUG: Import map URL: https://$S3_BUCKET.s3.$AWS_REGION.amazonaws.com/@$ORG_NAME/importmap.json"

    # Start local server for development/testing
    exec_npm npm run serve:root -- --env.mode=aws
}

start_npm() {
    echo "🔍 DEBUG: NPM mode - ENV=$ENV, NPM_TOKEN=${NPM_TOKEN:+SET}"

    # Check if user is logged in to NPM for both dev and prod
    if ! npm whoami >/dev/null 2>&1; then
        echo "❌ Error: Not logged in to NPM. Run 'npm login' first"
        exit 1
    fi

    echo "🔍 DEBUG: NPM user: $(npm whoami)"

    # Publish packages (microfrontends + root app in prod)
    echo "📦 NPM mode: Publishing packages to NPM"
    if [ "$ENV" = "prod" ]; then
        echo "🔍 DEBUG: Running npm run publish:npm:prod"
        if npm run publish:npm:prod; then
            echo "✅ NPM publishing successful"
            echo "🌍 Public NPM Package: https://www.npmjs.com/package/@cesarchamal/single-spa-root"
            echo "🌐 Production: Local server + root app available on NPM registry"
        else
            echo "❌ NPM publishing failed"
            exit 1
        fi
    else
        echo "🔍 DEBUG: Running npm run publish:npm:dev"
        if npm run publish:npm:dev; then
            echo "✅ NPM publishing successful"
            echo "📖 Development: Local server loading microfrontends from NPM registry"
        else
            echo "❌ NPM publishing failed"
            exit 1
        fi
    fi

    # Switch to NPM mode and start server for both dev and prod
    echo "📦 Switching to NPM mode and starting server..."
    echo "🔍 DEBUG: Switching to NPM mode"
    npm run mode:npm

    echo "✅ NPM mode setup complete!"
    echo "🌐 Main application: http://localhost:8080?mode=npm"
    echo "🔍 DEBUG: Loading microfrontends from NPM: @cesarchamal/single-spa-*"
    exec_npm npm run serve:npm
}

start_nexus() {
    echo "🔍 DEBUG: Nexus mode - ENV=$ENV, NEXUS_REGISTRY=${NEXUS_REGISTRY:-NOT_SET}"
    echo "🔍 DEBUG: NPM registry: $(npm config get registry)"
    echo "🔍 DEBUG: NPM user: $(npm whoami 2>/dev/null || echo 'Not logged in')"

    # Publish packages (microfrontends + root app in prod)
    echo "📦 Nexus mode: Publishing packages to Nexus registry"
    if [ "$ENV" = "prod" ]; then
        echo "🔍 DEBUG: Running npm run publish:nexus:prod"
        if npm run publish:nexus:prod; then
            echo "✅ Nexus publishing successful"
            echo "🌍 Public Nexus Package: Available on Nexus registry"
            echo "🌐 Production: Local server + root app available on Nexus registry"
        else
            echo "❌ Nexus publishing failed"
            exit 1
        fi
    else
        echo "🔍 DEBUG: Running npm run publish:nexus:dev"
        if npm run publish:nexus:dev; then
            echo "✅ Nexus publishing successful"
            echo "📖 Development: Local server loading microfrontends from Nexus registry"
        else
            echo "❌ Nexus publishing failed"
            exit 1
        fi
    fi

    # Switch to Nexus mode and start server for both dev and prod
    echo "📦 Switching to Nexus mode and starting server..."
    echo "🔍 DEBUG: Switching to Nexus mode"
    npm run mode:nexus

    echo "✅ Nexus mode setup complete!"
    echo "🌐 Main application: http://localhost:8080?mode=nexus"
    echo "🔍 DEBUG: Loading microfrontends from Nexus: @cesarchamal/single-spa-*"
    exec_npm npm run serve:nexus
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