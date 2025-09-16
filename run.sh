#!/bin/bash

# Demo Microfrontends Launcher Script
# Usage: ./run.sh [mode] [environment] [--clean] [--fix-network]
# Mode: local (default), npm, nexus, github, aws
# Environment: dev (default), prod
# Options: 
#   --clean (cleanup node_modules and package-lock.json, default: off)
#   --fix-network (configure npm for problematic networks, default: off)
# Examples:
#   ./run.sh local dev    # Full development environment
#   ./run.sh local prod   # Production build locally
#   ./run.sh npm prod     # NPM packages with production build
#   ./run.sh github dev   # GitHub Pages with development build
#   ./run.sh aws prod --clean     # AWS S3 with production build and cleanup
#   ./run.sh local dev --fix-network  # Local dev with network fixes
set -e

# Parse arguments
MODE=${1:-local}
ENV=${2:-dev}
CLEANUP=false
FIX_NETWORK=false

# Check for flags in any position
for arg in "$@"; do
    if [ "$arg" = "--clean" ]; then
        CLEANUP=true
    elif [ "$arg" = "--fix-network" ]; then
        FIX_NETWORK=true
    fi
done

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
    if [ -f ".nvmrc" ]; then
        REQUIRED_NODE=$(cat .nvmrc)
        echo "📋 .nvmrc specifies Node.js $REQUIRED_NODE"
        nvm use $REQUIRED_NODE || {
            echo "📥 Installing Node.js $REQUIRED_NODE..."
            nvm install $REQUIRED_NODE
            nvm use $REQUIRED_NODE
        }
    else
        nvm use 18.20.0 || {
            echo "📥 Installing Node.js 18.20.0..."
            nvm install 18.20.0
            nvm use 18.20.0
        }
    fi
elif command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node -v)
    echo "📋 Current Node.js version: $NODE_VERSION"
    if [ -f ".nvmrc" ]; then
        REQUIRED_NODE=$(cat .nvmrc)
        if [[ ! "$NODE_VERSION" =~ ^v$REQUIRED_NODE ]]; then
            echo "⚠️  Warning: .nvmrc requires Node.js $REQUIRED_NODE, current: $NODE_VERSION"
            echo "💡 Install nvm and run 'nvm use' for best compatibility"
        fi
    elif [[ ! "$NODE_VERSION" =~ ^v18\. ]]; then
        echo "⚠️  Warning: Node.js 18.x recommended, current: $NODE_VERSION"
        echo "💡 Install nvm and Node.js 18.20.0 for best compatibility"
    fi
else
    echo "❌ Node.js not found. Please install Node.js 18.20.0"
    exit 1
fi

# Load environment variables from .env file
load_env() {
    if [ -f ".env" ]; then
        export $(grep -v '^#' ".env" | xargs)
    fi
}

load_env

# Network fix function
fix_network_config() {
    echo "🔧 Applying network fixes for npm..."
    npm config set audit false
    npm config set fund false
    npm config set fetch-timeout 600000
    npm config set fetch-retries 5
    npm config set fetch-retry-mintimeout 20000
    npm config set fetch-retry-maxtimeout 120000
    echo "✅ Network configuration applied"
}

# Apply network fixes if requested
if [ "$FIX_NETWORK" = true ]; then
    fix_network_config
fi

# Cross-platform npm wrapper that handles Node.js 18+ + Webpack compatibility
# Windows Git Bash: NODE_OPTIONS restricted by security policy
# Linux/Pop!_OS/WSL: Sets NODE_OPTIONS=--openssl-legacy-provider for OpenSSL 3.0 compatibility
exec_npm() {
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        # Windows Git Bash - NODE_OPTIONS not allowed, run npm directly
        "$@"
    else
        # Linux/Pop!_OS/WSL/macOS - export NODE_OPTIONS to enable legacy OpenSSL provider
        # This allows older Webpack versions to work with Node.js 18+'s OpenSSL 3.0
        export NODE_OPTIONS="--openssl-legacy-provider"
        "$@"
    fi
}

# Cross-platform build wrapper for individual app builds
exec_build() {
    # Always set NODE_OPTIONS for build commands to handle OpenSSL 3.0 compatibility
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        # Windows Git Bash - try to set NODE_OPTIONS, fallback if restricted
        NODE_OPTIONS="--openssl-legacy-provider" "$@" 2>/dev/null || "$@"
    else
        # Linux/Pop!_OS/WSL/macOS - export NODE_OPTIONS
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

# Fix dependencies for all modes
if [ "$MODE" != "local" ]; then
    echo "🔧 Fixing dependencies for $MODE mode..."
    case "$MODE" in
        "npm")
            echo "🔧 Running NPM dependency fix..."
            SKIP_INSTALL=true npm run fix:npm:deps || echo "⚠️  NPM dependency fix completed with warnings"
            ;;
        "nexus")
            echo "🔧 Running Nexus dependency fix..."
            SKIP_INSTALL=true npm run fix:nexus:deps || echo "⚠️  Nexus dependency fix completed with warnings"
            ;;
        *)
            echo "🔧 Running auto dependency fix for $MODE mode..."
            SKIP_INSTALL=true npm run fix:auto:$MODE || echo "⚠️  Auto dependency fix completed with warnings"
            ;;
    esac
fi

# Switch to appropriate mode
echo "🔄 Switching to $MODE mode..."
SKIP_INSTALL=true npm run mode:$MODE

# Clean npm cache and main package if cleanup enabled
if [ "$CLEANUP" = true ]; then
    echo "🧹 Cleanup enabled - cleaning npm cache..."
    npm cache clean --force
    
    echo "🧹 Cleaning main package..."
    rm -rf node_modules package-lock.json
else
    echo "🔍 Cleanup disabled - skipping cache and package cleanup"
fi

# Install main package dependencies first (needed for rimraf)
if [ "$ENV" = "prod" ]; then
    echo "📦 Installing main package dependencies for production (CI)..."
    if [ -f "package-lock.json" ]; then
        exec_npm npm ci || {
            echo "⚠️  npm ci failed, falling back to npm install..."
            exec_npm npm install
        }
    else
        echo "📝 No package-lock.json found, using npm install..."
        exec_npm npm install
    fi
else
    echo "📦 Installing main package dependencies for development..."
    exec_npm npm install
fi

# Clean other applications if cleanup enabled
if [ "$CLEANUP" = true ]; then
    echo "🧹 Cleaning root and microfrontend applications..."
    npm run clean:root && npm run clean:apps
else
    echo "🔍 Cleanup disabled - skipping application cleanup"
fi

# Install all dependencies based on environment (skip for NPM/Nexus prod which publish first)
# shellcheck disable=SC2235
if ([ "$MODE" = "npm" ] || [ "$MODE" = "nexus" ]) && [ "$ENV" = "prod" ]; then
    echo "📝 Skipping dependency installation for $MODE prod mode (will build in local mode first)"
else
    if [ "$ENV" = "prod" ]; then
        echo "📦 Installing all dependencies for production (CI)..."
        exec_npm npm run install:all:ci || {
            echo "⚠️  CI install failed, falling back to regular install..."
            exec_npm npm run install:all
        }
    else
        echo "📦 Installing all dependencies for development..."
        exec_npm npm run install:all
    fi
fi

# Build applications based on environment (skip for NPM/Nexus prod which build in local mode)
# shellcheck disable=SC2235
if ([ "$MODE" = "npm" ] || [ "$MODE" = "nexus" ]) && [ "$ENV" = "prod" ]; then
    echo "📝 Skipping build for $MODE prod mode (will build in local mode during publishing)"
else
    if [ "$ENV" = "prod" ]; then
        echo "🔨 Building all applications for production..."
        exec_build npm run build:prod
    else
        echo "🔨 Building all applications for development..."
        exec_build npm run build:dev
    fi
fi

# Define startup behavior based on mode and environment
start_local() {
    echo "🔍 DEBUG: Local mode - ENV=$ENV, NODE_VERSION=$(node --version), NPM_VERSION=$(npm --version)"
    
    # Restore original .npmrc for local mode
    if [ -f ".npmrc.backup" ]; then
        echo "🔄 Restoring original .npmrc configuration..."
        cp .npmrc.backup .npmrc
        rm .npmrc.backup
    fi
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
    echo "🔍 DEBUG: GitHub mode - ENV=$ENV, GITHUB_API_TOKEN=${GITHUB_API_TOKEN:+SET}, GITHUB_USERNAME=${GITHUB_USERNAME:-NOT_SET}"
    
    if [ "$ENV" = "prod" ]; then
        # Production mode: Create repositories and deploy
        echo "🚀 GitHub Production: Creating repositories and deploying to GitHub Pages"
        
        # Check prerequisites for production deployment
        if [ -z "$GITHUB_API_TOKEN" ]; then
            echo "❌ Error: GITHUB_API_TOKEN required for production deployment"
            exit 1
        fi
        
        # Build root application with GitHub mode configuration
        echo "🔨 Building root application for GitHub prod mode..."
        exec_npm npm run build:root:github:prod
        
        # Deploy each microfrontend using existing scripts
        APPS=("auth" "layout" "home" "angular" "vue" "react" "vanilla" "webcomponents" "typescript" "jquery" "svelte")
        
        for app in "${APPS[@]}"; do
            echo "📤 Deploying $app app to GitHub Pages..."
            if npm run deploy:github:$app; then
                echo "✅ $app deployment successful"
            else
                echo "❌ $app deployment failed"
                exit 1
            fi
        done
        
        # Deploy root application
        echo "📤 Deploying root application to GitHub Pages..."
        if npm run deploy:github:root; then
            echo "✅ Root deployment successful"
        else
            echo "❌ Root deployment failed"
            exit 1
        fi
        
        # Deploy main package documentation
        echo "📤 Deploying main package to GitHub Pages..."
        if npm run deploy:github:main; then
            echo "✅ Main package deployment successful"
        else
            echo "❌ Main package deployment failed"
            exit 1
        fi
        
        echo "✅ All deployments complete!"
        echo "🌍 Public GitHub Pages:"
        echo "   Root App: https://${GITHUB_USERNAME:-cesarchamal}.github.io/single-spa-root/"
        echo "   Documentation: https://${GITHUB_USERNAME:-cesarchamal}.github.io/demo-microfrontends/"
        echo "🌐 Production: Both local server AND public GitHub Pages available"
    else
        # Development mode: Read from existing GitHub Pages
        echo "📖 GitHub Development: Reading from existing GitHub Pages (no deployment)"
        echo "🔍 Assumes repositories already exist and are deployed"
        
        # Build root application with GitHub mode configuration
        echo "🔨 Building root application for GitHub dev mode..."
        exec_npm npm run build:root:github:dev
    fi
    
    echo "🌐 Main application: http://localhost:8080?mode=github"
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
#    cd single-spa-root
#    if [ "$ENV" = "dev" ]; then
#        exec_npm npm run build:dev -- --env.mode=aws
#    else
#        exec_npm npm run build:prod -- --env.mode=aws
#        exec_npm npm run build:aws:prod
#    fi
    if [ "$ENV" = "dev" ]; then
        echo "🔨 Building root application for AWS dev mode..."
        exec_npm npm run build:root:aws:dev
    else
        echo "🔨 Building root application for AWS prod mode..."
#        exec_npm npm run build:root:aws:prod
#        exec_npm npm run build:root:aws:s3:prod
        exec_npm npm run deploy:aws:prod
    fi

    # Deploy all microfrontends to S3 in both dev and prod
    echo "🚀 AWS mode: Deploying all microfrontends to S3"
    echo "🔍 DEBUG: Running npm run deploy:aws:$ENV"
    if npm run deploy:aws:$ENV; then
        echo "✅ S3 deployment successful"
    else
        echo "❌ S3 deployment failed"
        exit 1
    fi

    # Set S3 website URL for display
    S3_WEBSITE_URL_DISPLAY="${S3_WEBSITE_URL:-http://$S3_BUCKET.s3-website-$AWS_REGION.amazonaws.com}"

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
    
    # Switch to NPM .npmrc configuration
    echo "🔄 Switching to NPM .npmrc configuration..."
    if [ -f ".npmrc" ]; then
        cp .npmrc .npmrc.backup
    fi
    cp .npmrc.npm .npmrc
    echo "📝 Registry switched to: $(npm config get registry)"
    
    if [ "$ENV" = "prod" ]; then
        # Production mode: Publish packages first, then switch to NPM mode
        echo "🚀 NPM Production: Publishing packages to NPM registry first"
        
        # Check if user is logged in to NPM for publishing
        if ! npm whoami >/dev/null 2>&1; then
            echo "❌ Error: Not logged in to NPM. Run 'npm login' first or set NPM_TOKEN"
            exit 1
        fi
        
        echo "🔍 DEBUG: NPM user: $(npm whoami)"
        
        # Switch back to local mode temporarily for building and publishing (skip install)
        echo "🔄 Switching back to local mode for building and publishing..."
        SKIP_INSTALL=true npm run mode:local
        
        # Build all applications in local mode first
        echo "🔨 Building all applications for publishing..."
        exec_npm npm run build:prod
        
        # Publish packages (microfrontends + root app)
        echo "📦 Publishing all packages to NPM..."
        echo "🔍 DEBUG: Running npm run publish:npm:prod"
        if FROM_RUN_SCRIPT=true npm run publish:npm:prod; then
            echo "✅ NPM publishing successful"
            echo "🌍 Public NPM Package: https://www.npmjs.com/package/@cesarchamal/single-spa-root"
        else
            echo "❌ NPM publishing failed"
            exit 1
        fi
        
        # Now switch to NPM mode after packages are published
        echo "🔄 Switching to NPM mode after publishing..."
        npm run mode:npm
        
        # Build root application with NPM mode configuration
        echo "🔨 Building root application for NPM prod mode..."
        exec_npm npm run build:root:npm:prod
        
        echo "🌐 Production: Local server + root app available on NPM registry"
    else
        # Development mode: Only read existing packages (no publishing)
        echo "📖 NPM Development: Reading existing packages from NPM registry (no publishing)"
        echo "🔍 Assumes packages already exist on NPM registry"
        
        # Build root application with NPM mode configuration
        echo "🔨 Building root application for NPM dev mode..."
        exec_npm npm run build:root:npm:dev
        
        echo "📝 Note: Skipping publishing in development mode"
    fi
    
    echo "📦 Starting NPM mode server..."
    echo "🔍 DEBUG: NPM mode active"
    
    echo "✅ NPM mode setup complete!"
    echo "🌐 Main application: http://localhost:8080?mode=npm"
    echo "🔍 DEBUG: Loading microfrontends from NPM: @cesarchamal/single-spa-*"
    exec_npm npm run serve:npm
}

start_nexus() {
    echo "🔍 DEBUG: Nexus mode - ENV=$ENV, NEXUS_REGISTRY=${NEXUS_REGISTRY:-NOT_SET}"
    # Nexus mode uses local file serving, no CORS proxy needed
    echo "📝 Nexus mode: Using local file serving + Nexus registry"
    
    # Switch to Nexus .npmrc configuration
    echo "🔄 Switching to Nexus .npmrc configuration..."
    if [ -f ".npmrc" ]; then
        cp .npmrc .npmrc.backup
    fi
    cp .npmrc.nexus .npmrc
    echo "📝 Registry switched to: $(npm config get registry)"
    
    if [ "$ENV" = "prod" ]; then
        # Production mode: Publish packages first, then switch to Nexus mode
        echo "🚀 Nexus Production: Publishing packages to Nexus registry first"
        
        echo "🔍 DEBUG: NPM user: $(npm whoami 2>/dev/null || echo 'Not logged in')"
        
        # Switch back to local mode temporarily for building and publishing (skip install)
        echo "🔄 Switching back to local mode for building and publishing..."
        SKIP_INSTALL=true npm run mode:local
        
        # Build all applications in local mode first
        echo "🔨 Building all applications for publishing..."
        exec_npm npm run build:prod
        
        # Publish packages (microfrontends + root app)
        echo "📦 Publishing all packages to Nexus..."
        echo "🔍 DEBUG: Running npm run publish:nexus:prod"
        if FROM_RUN_SCRIPT=true npm run publish:nexus:prod; then
            echo "✅ Nexus publishing successful"
            echo "🌍 Public Nexus Package: Available on Nexus registry"
        else
            echo "❌ Nexus publishing failed"
            exit 1
        fi
        
        # Now switch to Nexus mode after packages are published
        echo "🔄 Switching to Nexus mode after publishing..."
        npm run mode:nexus
        
        # Build root application with Nexus mode configuration
        echo "🔨 Building root application for Nexus prod mode..."
        exec_npm npm run build:root:nexus:prod
        
        echo "🌐 Production: Local server + root app available on Nexus registry"
    else
        # Development mode: Only read existing packages (no publishing)
        echo "📖 Nexus Development: Reading existing packages from Nexus registry (no publishing)"
        echo "🔍 Assumes packages already exist on Nexus registry"
        
        # Build root application with Nexus mode configuration
        echo "🔨 Building root application for Nexus dev mode..."
        exec_npm npm run build:root:nexus:dev
        
        echo "📝 Note: Skipping publishing in development mode"
    fi
    
    echo "📦 Starting Nexus mode server..."
    echo "🔍 DEBUG: Nexus mode active"
    
    echo "✅ Nexus mode setup complete!"
    echo "🌐 Main application: http://localhost:8080?mode=nexus"
    if [ "$ENV" = "prod" ]; then
        echo "🔍 DEBUG: Nexus prod mode - static files + Nexus registry"
        exec_npm npm run serve:nexus:prod
    else
        echo "🔍 DEBUG: Nexus dev mode - individual servers + Nexus registry"
        exec_npm npm run serve:nexus:dev
    fi
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