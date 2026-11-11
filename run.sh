#!/bin/bash

# Demo Microfrontends Launcher Script
# Usage: ./run.sh [mode] [environment] [--clean] [--fix-network] [--skip-build] [--offline]
# Mode: local (default), npm, nexus, github, aws
# Environment: dev (default), prod
# Options: 
#   --clean (cleanup node_modules and package-lock.json, default: off)
#   --fix-network (configure npm for problematic networks, default: off)
#   --skip-build (skip build for main package and microfrontends, default: off)
#   --offline (use local dependencies instead of CDN, works with local/nexus modes only, default: off)
# Dependencies are installed only where they changed since the last install
# (scripts/install-if-changed.js); --clean forces a full reinstall.
# Examples:
#   ./run.sh local dev    # Full development environment
#   ./run.sh local prod   # Production build locally
#   ./run.sh npm prod     # NPM packages with production build
#   ./run.sh github dev   # GitHub Pages with development build
#   ./run.sh aws prod --clean     # AWS S3 with production build and cleanup
#   ./run.sh local dev --fix-network  # Local dev with network fixes
#   ./run.sh local prod --skip-build  # Skip the build step
#   ./run.sh local prod --offline  # Local production with offline dependencies
#   ./run.sh nexus dev --offline   # Nexus development with offline dependencies
#
# Sequential Workflow Examples:
#   ./run.sh local prod                              # Run 1: Full setup
#   ./run.sh local prod --skip-build                # Run 2: Fast restart (same mode)
#   ./run.sh aws prod                               # Run 3: Mode change - auto-detects and rebuilds
#   ./run.sh local prod --offline                   # Run 4: Offline mode for no internet
set -e

# Parse arguments
MODE=${1:-local}
ENV=${2:-dev}
CLEANUP=false
FIX_NETWORK=false
# SKIP_INSTALL is only set inline, for the mode switches below. An inherited value must not
# reach the other npm scripts this launcher runs.
unset SKIP_INSTALL
SKIP_BUILD=false
OFFLINE=false
# true once this run has built every microfrontend; start_aws then lets the S3
# deploy reuse those builds instead of rebuilding all of them a second time
APPS_BUILT=false

# Check for flags in any position
for arg in "$@"; do
    if [ "$arg" = "--clean" ]; then
        CLEANUP=true
    elif [ "$arg" = "--fix-network" ]; then
        FIX_NETWORK=true
    elif [ "$arg" = "--skip-install" ]; then
        echo "ℹ️  --skip-install is no longer needed: installs run only where dependencies changed"
    elif [ "$arg" = "--skip-build" ]; then
        SKIP_BUILD=true
    elif [ "$arg" = "--offline" ]; then
        OFFLINE=true
    fi
done

# Check previous mode for build compatibility
PREV_MODE="unknown"
if [ -f ".env" ]; then
    PREV_MODE=$(grep "^SPA_MODE=" .env | cut -d'=' -f2 || echo "unknown")
fi

# Update .env file with current mode, environment, and offline setting
echo "📝 Updating SPA configuration in .env..."
sed -i "s/^SPA_MODE=.*/SPA_MODE=$MODE/" .env
sed -i "s/^SPA_ENV=.*/SPA_ENV=$ENV/" .env
if [ "$OFFLINE" = true ]; then
    if grep -q "^OFFLINE=" .env; then
        sed -i "s/^OFFLINE=.*/OFFLINE=true/" .env
    else
        echo "OFFLINE=true" >> .env
    fi
else
    if grep -q "^OFFLINE=" .env; then
        sed -i "s/^OFFLINE=.*/OFFLINE=false/" .env
    else
        echo "OFFLINE=false" >> .env
    fi
fi

# Validate offline mode compatibility
if [ "$OFFLINE" = true ]; then
    case "$MODE" in
        "local"|"nexus")
            echo "📱 Offline mode enabled for $MODE mode"
            ;;
        *)
            echo "❌ Error: Offline mode only supported for local and nexus modes"
            echo "💡 Supported: ./run.sh local [dev|prod] --offline"
            echo "💡 Supported: ./run.sh nexus [dev|prod] --offline"
            exit 1
            ;;
    esac
fi

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

# Handle conda environment conflicts
if [[ "$CONDA_DEFAULT_ENV" != "" ]] || command -v conda >/dev/null 2>&1; then
    echo "⚠️  Warning: Conda environment detected: ${CONDA_DEFAULT_ENV:-base}"
    echo "🔄 Attempting to deactivate conda to avoid NVM conflicts..."
    
    # Method 1: Try conda deactivate
    if command -v conda >/dev/null 2>&1 && conda deactivate 2>/dev/null; then
        echo "✅ Conda deactivated successfully"
        unset CONDA_DEFAULT_ENV
    # Method 2: Try source deactivate (legacy)
    elif source deactivate 2>/dev/null; then
        echo "✅ Conda deactivated using legacy method"
        unset CONDA_DEFAULT_ENV
    # Method 3: Manual PATH cleanup
    else
        echo "⚠️  Automatic conda deactivation failed"
        echo "🔧 Attempting manual conda PATH cleanup..."
        
        # Remove conda paths from PATH
        if [[ "$PATH" == *"conda"* ]]; then
            # Save original PATH without conda
            CLEAN_PATH=$(echo "$PATH" | tr ':' '\n' | grep -v conda | tr '\n' ':' | sed 's/:$//')
            export PATH="$CLEAN_PATH"
            echo "✅ Conda paths removed from PATH"
        fi
        
        # Unset conda environment variables
        unset CONDA_DEFAULT_ENV
        unset CONDA_PREFIX
        unset CONDA_PROMPT_MODIFIER
        unset CONDA_SHLVL
        
        echo "⚠️  Manual cleanup completed - some conda effects may persist"
        echo "💡 For complete cleanup, run: conda deactivate && ./run.sh local dev"
        echo "💡 Or start a new shell session without conda activation"
    fi
fi

# Set Node.js version using nvm
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    echo "🔄 Setting Node.js version..."
    echo "🔍 DEBUG: Loading NVM from $HOME/.nvm/nvm.sh"
    
    # Force clean environment for NVM loading
    if [[ "$CONDA_DEFAULT_ENV" != "" ]] || command -v conda >/dev/null 2>&1; then
        echo "🔧 Forcing clean environment for NVM..."
        # Temporarily disable conda functions that might interfere
        unset -f conda 2>/dev/null || true
        unset -f __conda_activate 2>/dev/null || true
        unset -f __conda_reactivate 2>/dev/null || true
    fi
    
    # Load NVM with error handling
    if source "$HOME/.nvm/nvm.sh" 2>/dev/null; then
        echo "✅ NVM loaded successfully"
    else
        echo "❌ NVM loading failed, trying alternative method..."
        # Try loading with explicit bash
        if bash -c "source $HOME/.nvm/nvm.sh && echo 'NVM loaded'" >/dev/null 2>&1; then
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            echo "✅ NVM loaded with alternative method"
        else
            echo "⚠️ NVM loading failed - continuing with system Node.js"
        fi
    fi
    
    # Check if NVM is actually available after loading
    if command -v nvm >/dev/null 2>&1; then
        echo "✅ NVM command available"
    else
        echo "⚠️ NVM command not available after loading - using system Node.js"
        # Skip NVM operations and continue with system Node.js
        if command -v node >/dev/null 2>&1; then
            echo "📋 Using system Node.js: $(node --version)"
        else
            echo "❌ No Node.js available"
            exit 1
        fi
        # Skip to the next section
        echo "🔍 DEBUG: Skipping NVM operations, continuing with system Node.js"
    fi
    
    if [ -f ".nvmrc" ] && command -v nvm >/dev/null 2>&1; then
        REQUIRED_NODE=$(cat .nvmrc)
        echo "📋 .nvmrc specifies Node.js $REQUIRED_NODE"
        echo "🔍 DEBUG: Checking if Node.js $REQUIRED_NODE is available..."
        
        if nvm list | grep -q "v$REQUIRED_NODE"; then
            echo "✅ Node.js $REQUIRED_NODE already installed"
            echo "🔍 DEBUG: Using existing Node.js $REQUIRED_NODE"
            nvm use $REQUIRED_NODE || echo "⚠️ Failed to switch to Node.js $REQUIRED_NODE"
        else
            echo "📥 Installing Node.js $REQUIRED_NODE..."
            echo "🔍 DEBUG: Running nvm install $REQUIRED_NODE"
            if nvm install $REQUIRED_NODE; then
                echo "✅ Node.js $REQUIRED_NODE installed successfully"
                nvm use $REQUIRED_NODE || echo "⚠️ Failed to switch to Node.js $REQUIRED_NODE"
            else
                echo "❌ Failed to install Node.js $REQUIRED_NODE"
                echo "💡 Trying to use any available Node.js version..."
                nvm use node || nvm use default || {
                    echo "❌ No Node.js version available via NVM"
                    if command -v node >/dev/null 2>&1; then
                        echo "📋 Falling back to system Node.js: $(node --version)"
                    else
                        echo "❌ No Node.js available at all"
                        exit 1
                    fi
                }
            fi
        fi
    elif command -v nvm >/dev/null 2>&1; then
        echo "🔍 DEBUG: No .nvmrc found, using Node.js 18.20.0"
        if nvm list | grep -q "v18.20.0"; then
            echo "✅ Node.js 18.20.0 already installed"
            nvm use 18.20.0 || echo "⚠️ Failed to switch to Node.js 18.20.0"
        else
            echo "📥 Installing Node.js 18.20.0..."
            if nvm install 18.20.0; then
                echo "✅ Node.js 18.20.0 installed successfully"
                nvm use 18.20.0 || echo "⚠️ Failed to switch to Node.js 18.20.0"
            else
                echo "❌ Failed to install Node.js 18.20.0"
                echo "💡 Trying to use any available Node.js version..."
                nvm use node || nvm use default || {
                    echo "❌ No Node.js version available via NVM"
                    if command -v node >/dev/null 2>&1; then
                        echo "📋 Falling back to system Node.js: $(node --version)"
                    else
                        echo "❌ No Node.js available at all"
                        exit 1
                    fi
                }
            fi
        fi
    fi
    
    echo "🔍 DEBUG: Current Node.js version: $(node --version 2>/dev/null || echo 'Not available')"
    echo "🔍 DEBUG: Current NPM version: $(npm --version 2>/dev/null || echo 'Not available')"
    if command -v nvm >/dev/null 2>&1; then
        echo "✅ NVM setup complete"
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
    echo "❌ Node.js not found. Installing NVM and Node.js..."
    
    case "$PLATFORM" in
        "Pop!_OS"|"WSL Ubuntu"|"Linux")
            echo "📦 Installing NVM for $PLATFORM..."
            echo "🔄 Running: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
            
            echo "🔄 Reloading shell configuration..."
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
            
            if [ -s "$HOME/.nvm/nvm.sh" ]; then
                source "$HOME/.nvm/nvm.sh"
                echo "📥 Installing Node.js 18.20.0..."
                nvm install 18.20.0
                nvm use 18.20.0
                echo "✅ NVM and Node.js 18.20.0 installed successfully"
            else
                echo "❌ NVM installation failed. Please install manually:"
                echo "   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
                echo "   source ~/.bashrc"
                echo "   nvm install 18.20.0"
                exit 1
            fi
            ;;
        *)
            echo "❌ Please install Node.js 18.20.0 manually for $PLATFORM"
            echo "💡 Recommended: Install NVM first, then Node.js 18.20.0"
            echo "   Visit: https://github.com/nvm-sh/nvm#installation-and-update"
            exit 1
            ;;
    esac
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

# Install main package dependencies first (needed for rimraf). install-if-changed.js runs
# the install only when the root's package-lock.json, or the dependencies in package.json
# or shared/package.json (the root's postinstall installs shared), changed since the last
# successful install. prod uses npm ci and falls back to npm install if it fails.
if [ "$ENV" = "prod" ]; then
    echo "📦 Installing main package dependencies for production (CI) if they changed..."
    exec_npm node scripts/install-if-changed.js --ci --with shared .
else
    echo "📦 Installing main package dependencies for development if they changed..."
    exec_npm node scripts/install-if-changed.js --with shared .
fi

# Clean other applications if cleanup enabled
if [ "$CLEANUP" = true ]; then
    echo "🧹 Cleaning root and microfrontend applications..."
    npm run clean:root && npm run clean:apps
else
    echo "🔍 Cleanup disabled - skipping application cleanup"
fi

# Check if mode change requires rebuild (override --skip-build)
MODE_CHANGED=false
if [ "$PREV_MODE" != "$MODE" ] && [ "$PREV_MODE" != "unknown" ]; then
    MODE_CHANGED=true
    echo "🔄 Mode changed from $PREV_MODE to $MODE"
    
    # Check if mode change requires different build outputs
    NEEDS_REBUILD=false
    case "$PREV_MODE-$MODE" in
        "local-aws"|"local-github"|"local-npm"|"local-nexus")
            NEEDS_REBUILD=true
            echo "⚠️  Mode change from local to external requires rebuild"
            ;;
        "aws-local"|"github-local"|"npm-local"|"nexus-local")
            NEEDS_REBUILD=true
            echo "⚠️  Mode change from external to local requires rebuild"
            ;;
        "aws-github"|"github-aws"|"npm-nexus"|"nexus-npm")
            NEEDS_REBUILD=true
            echo "⚠️  Mode change between different external sources requires rebuild"
            ;;
    esac
    
    if [ "$NEEDS_REBUILD" = true ] && [ "$SKIP_BUILD" = true ]; then
        echo "🔧 Automatically enabling build due to mode compatibility requirements"
        echo "💡 Use same mode to benefit from --skip-build optimization"
        SKIP_BUILD=false
    fi
fi

# Install all dependencies - root app needs them regardless of mode. install-if-changed.js
# installs only the microfrontends whose dependencies changed since their last successful
# install, INSTALL_CONCURRENCY (default 3) at a time. prod uses npm ci and falls back to
# npm install if it fails. Every single-spa-*-app folder is a microfrontend, so a new app
# is picked up without changes here (folders without a package.json are left out).
APP_DIRS=()
for app_dir in single-spa-*-app; do
    if [ -f "$app_dir/package.json" ]; then
        APP_DIRS+=("$app_dir")
    fi
done
if [ ${#APP_DIRS[@]} -eq 0 ]; then
    echo "⚠️  No single-spa-*-app folder with a package.json found, nothing to install"
elif [ "$ENV" = "prod" ]; then
    echo "📦 Installing microfrontend dependencies for production (CI) where they changed..."
    exec_npm node scripts/install-if-changed.js --ci "${APP_DIRS[@]}"
else
    echo "📦 Installing microfrontend dependencies for development where they changed..."
    exec_npm node scripts/install-if-changed.js "${APP_DIRS[@]}"
fi

# Build all applications - root app needs them regardless of mode
if [ "$SKIP_BUILD" = true ]; then
    echo "⏭️  Skipping build for all applications (--skip-build flag)"
else
    if [ "$ENV" = "prod" ]; then
        echo "🔨 Building all applications for production..."
#        exec_build npm run build:prod
        exec_build npm run build:concurrent:prod
    else
        echo "🔨 Building all applications for development..."
#        exec_build npm run build:dev
        exec_build npm run build:concurrent:dev
    fi
    # Reached only on success: set -e (line 29) aborts the run on a failed build
    APPS_BUILT=true
fi

# Define startup behavior based on mode and environment
start_local() {
    echo "🔍 DEBUG: Local mode - ENV=$ENV, OFFLINE=$OFFLINE, NODE_VERSION=$(node --version), NPM_VERSION=$(npm --version)"
    
    # Check offline mode compatibility and setup
    if [ "$OFFLINE" = true ]; then
        echo "📱 Offline mode enabled - checking local dependencies..."
        if [ ! -d "single-spa-root/dist/lib" ]; then
            echo "📦 Local dependencies not found. Downloading..."
            bash ./scripts/download-offline-deps.sh
        else
            echo "✅ Local dependencies found"
        fi
        export OFFLINE=true
    fi
    
    echo "🔍 DEBUG: Available ports check:"
    for port in 8080 4201 4202 4203 4204 4205 4206 4207 4208 4209 4210 4211 4212; do
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
        if [ "$OFFLINE" = true ]; then
            echo "📱 Offline mode: Using local dependencies"
        fi
        echo "Main application: http://localhost:8080"
        if [ "$SKIP_BUILD" = true ]; then
            if [ "$OFFLINE" = true ]; then
                OFFLINE=true exec_npm npm run serve:local:prod:skip-build
            else
                exec_npm npm run serve:local:prod:skip-build
            fi
        else
            if [ "$OFFLINE" = true ]; then
                OFFLINE=true exec_npm npm run serve:local:prod
            else
                exec_npm npm run serve:local:prod
            fi
        fi
     else
        echo "🌐 Local development: Starting all 12 microfrontends"
        echo "🔍 DEBUG: Development mode - starting individual servers on ports 4201-4212"
        if [ "$OFFLINE" = true ]; then
            echo "📱 Offline mode: Using local dependencies"
        fi
        echo "Main application: http://localhost:8080"
        echo "Microfrontend ports: 4201-4212"
        if [ "$OFFLINE" = true ]; then
            OFFLINE=true exec_npm npm run serve:local:dev
        else
            exec_npm npm run serve:local:dev
        fi
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
        APPS=("auth" "layout" "home" "angular" "vue" "react" "vanilla" "webcomponents" "typescript" "jquery" "svelte" "solid")
        
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
#    exec_npm npm run serve:github
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
    # deploy:aws:$ENV = mode:aws (installs single-spa-root + shared deps)
    #   -> build:root:aws:$ENV -> scripts/deploy-s3.sh $ENV (uploads the root,
    #   import map, employees.json and all 12 microfrontends). It builds the root
    #   itself, so it runs exactly once. When this run has just built every
    #   microfrontend, deploy-s3.sh reuses those builds instead of rebuilding all
    #   12 one by one:
    #   - prod: SKIP_BUILD=true also skips deploy-s3.sh's own root rebuild; the
    #           build:root:aws:prod output is the same production aws-mode root
    #   - dev:  SKIP_APPS_BUILD=true skips only the app rebuild; deploy-s3.sh
    #           still builds the root bundle it has always uploaded in dev
    DEPLOY_ENV=()
    if [ "$APPS_BUILT" = true ]; then
        if [ "$ENV" = "prod" ]; then
            DEPLOY_ENV=(SKIP_BUILD=true)
        else
            DEPLOY_ENV=(SKIP_APPS_BUILD=true)
        fi
    fi
    echo "🚀 AWS mode: Building root application and deploying all microfrontends to S3"
    echo "🔍 DEBUG: Running ${DEPLOY_ENV[*]} npm run deploy:aws:$ENV"
    # -u SKIP_INSTALL: an inherited value must not skip the install inside deploy:aws:*
    if exec_npm env -u SKIP_INSTALL "${DEPLOY_ENV[@]}" npm run deploy:aws:$ENV; then
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
#    exec_npm npm run serve:aws
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
        SKIP_INSTALL=true npm run mode:npm
        
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
#    exec_npm npm run serve:npm
    exec_npm npm run serve:root -- --env.mode=npm
}

start_nexus() {
    echo "🔍 DEBUG: Nexus mode - ENV=$ENV, OFFLINE=$OFFLINE, NEXUS_REGISTRY=${NEXUS_REGISTRY:-NOT_SET}"
    
    # Check offline mode compatibility and setup
    if [ "$OFFLINE" = true ]; then
        echo "📱 Offline mode enabled - checking local dependencies..."
        if [ ! -d "single-spa-root/dist/lib" ]; then
            echo "📦 Local dependencies not found. Downloading..."
            bash ./scripts/download-offline-deps.sh
        else
            echo "✅ Local dependencies found"
        fi
        export OFFLINE=true
    fi
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
        SKIP_INSTALL=true npm run mode:nexus
        
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
        if [ "$OFFLINE" = true ]; then
            echo "📱 Offline mode: Using local dependencies"
            OFFLINE=true exec_npm npm run serve:nexus:prod
        else
            exec_npm npm run serve:nexus:prod
        fi
    else
        echo "🔍 DEBUG: Nexus dev mode - individual servers + Nexus registry"
        if [ "$OFFLINE" = true ]; then
            echo "📱 Offline mode: Using local dependencies"
            OFFLINE=true exec_npm npm run serve:nexus:dev
        else
            exec_npm npm run serve:nexus:dev
        fi
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

# Cleanup function to restore local mode (commented out to preserve mode detection)
# cleanup() {
#     echo ""
#     echo "🔄 Cleaning up and switching back to local mode..."
#     SKIP_INSTALL=true npm run mode:local 2>/dev/null || true
#     echo "✅ Switched back to local mode"
#     exit 0
# }

# Set trap to run cleanup on script exit (commented out)
# trap cleanup EXIT INT TERM

echo ""
echo "Press Ctrl+C to stop"