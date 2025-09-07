#!/bin/bash

# GitHub Hot Sync Script
# Usage: ./github-hot-sync.sh

set -e

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' ".env" | xargs)
fi

GITHUB_USERNAME=${GITHUB_USERNAME}
GITHUB_API_TOKEN=${GITHUB_API_TOKEN}

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ Error: GITHUB_USERNAME not set"
    exit 1
fi

if [ -z "$GITHUB_API_TOKEN" ]; then
    echo "❌ Error: GITHUB_API_TOKEN not set"
    exit 1
fi

echo "🔥 Starting GitHub Hot Sync for microfrontends..."
echo "👤 GitHub User: $GITHUB_USERNAME"
echo "🔑 Token: ${GITHUB_API_TOKEN:0:8}..."
echo ""

# List of applications and their repositories
declare -A APPS
APPS["single-spa-root"]="single-spa-root"
APPS["single-spa-auth-app"]="single-spa-auth-app"
APPS["single-spa-layout-app"]="single-spa-layout-app"
APPS["single-spa-home-app"]="single-spa-home-app"
APPS["single-spa-angular-app"]="single-spa-angular-app"
APPS["single-spa-vue-app"]="single-spa-vue-app"
APPS["single-spa-react-app"]="single-spa-react-app"
APPS["single-spa-vanilla-app"]="single-spa-vanilla-app"
APPS["single-spa-webcomponents-app"]="single-spa-webcomponents-app"
APPS["single-spa-typescript-app"]="single-spa-typescript-app"
APPS["single-spa-jquery-app"]="single-spa-jquery-app"
APPS["single-spa-svelte-app"]="single-spa-svelte-app"

# Function to deploy a single app
deploy_app() {
    local app=$1
    local repo=$2
    
    if [ -d "$app/dist" ]; then
        echo "🔄 Deploying $app to $GITHUB_USERNAME/$repo"
        
        # Use the existing deploy script
        if bash ./scripts/deploy-github.sh "$app"; then
            echo "✅ Deployed $app"
        else
            echo "❌ Failed to deploy $app"
        fi
    else
        echo "⚠️  No dist directory found for $app"
    fi
}

# Function to install fswatch based on platform
install_fswatch() {
    echo "🔧 Installing fswatch for better performance..."
    
    # Detect platform
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew >/dev/null 2>&1; then
            echo "📦 Installing fswatch via Homebrew..."
            brew install fswatch
        else
            echo "⚠️  Homebrew not found. Please install Homebrew first or install fswatch manually."
            return 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ -n "$WSL_DISTRO_NAME" ]] || [[ -f "/proc/version" && $(grep -i microsoft /proc/version) ]]; then
        # Linux (including Pop OS, Ubuntu, WSL)
        if command -v apt-get >/dev/null 2>&1; then
            echo "📦 Installing fswatch via apt-get..."
            sudo apt-get update && sudo apt-get install -y fswatch
        elif command -v yum >/dev/null 2>&1; then
            echo "📦 Installing fswatch via yum..."
            sudo yum install -y fswatch
        elif command -v dnf >/dev/null 2>&1; then
            echo "📦 Installing fswatch via dnf..."
            sudo dnf install -y fswatch
        elif command -v pacman >/dev/null 2>&1; then
            echo "📦 Installing fswatch via pacman..."
            sudo pacman -S fswatch
        else
            echo "⚠️  No supported package manager found. Please install fswatch manually."
            return 1
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$MSYSTEM" ]]; then
        # Windows Git Bash / MSYS2
        echo "⚠️  Running in Windows Git Bash. fswatch not available."
        echo "💡 Consider using WSL for better file watching performance."
        return 1
    else
        echo "⚠️  Unknown platform: $OSTYPE"
        echo "💡 Please install fswatch manually for your system."
        return 1
    fi
    
    # Verify installation
    if command -v fswatch >/dev/null 2>&1; then
        echo "✅ fswatch installed successfully!"
        return 0
    else
        echo "❌ fswatch installation failed."
        return 1
    fi
}

# Function to watch and deploy all apps
watch_and_deploy() {
    echo "👀 Watching for file changes..."
    echo "Press Ctrl+C to stop"
    echo ""
    
    # Check if fswatch is available
    if ! command -v fswatch >/dev/null 2>&1; then
        echo "fswatch not found. Attempting to install..."
        if install_fswatch; then
            echo "🎉 fswatch installed! Restarting with file monitoring..."
            echo ""
        else
            echo "⚠️  Falling back to polling method..."
            echo ""
        fi
    fi
    
    # Use fswatch if available, otherwise fall back to basic loop
    if command -v fswatch >/dev/null 2>&1; then
        echo "Using fswatch for file monitoring..."
        
        # Build watch paths for all dist directories
        WATCH_PATHS=""
        for app in "${!APPS[@]}"; do
            if [ -d "$app/dist" ]; then
                WATCH_PATHS="$WATCH_PATHS $app/dist"
            fi
        done
        
        if [ -n "$WATCH_PATHS" ]; then
            fswatch -o $WATCH_PATHS | while read num; do
                echo "📁 File changes detected, deploying changed apps..."
                
                # Only deploy apps that have recent changes
                for app in "${!APPS[@]}"; do
                    if [ -d "$app/dist" ]; then
                        if find "$app/dist" -type f -newermt "5 seconds ago" 2>/dev/null | grep -q .; then
                            repo="${APPS[$app]}"
                            deploy_app "$app" "$repo"
                        fi
                    fi
                done
                echo "🎉 Deployment complete at $(date)"
                echo ""
            done
        else
            echo "❌ No dist directories found to watch"
        fi
    else
        echo "Using polling method (fswatch not available)..."
        echo "💡 Platform: $OSTYPE"
        echo ""
        
        # Polling method - check every 10 seconds (slower for GitHub API limits)
        while true; do
            sleep 10
            
            # Check if any dist directory has been modified in the last 15 seconds
            CHANGED=false
            for app in "${!APPS[@]}"; do
                if [ -d "$app/dist" ]; then
                    if find "$app/dist" -type f -newermt "15 seconds ago" 2>/dev/null | grep -q .; then
                        CHANGED=true
                        repo="${APPS[$app]}"
                        deploy_app "$app" "$repo"
                    fi
                fi
            done
            
            if [ "$CHANGED" = true ]; then
                echo "🎉 Deployment complete at $(date)"
                echo ""
            fi
        done
    fi
}

# Initial deployment of all apps
echo "🚀 Performing initial deployment of all apps..."
for app in "${!APPS[@]}"; do
    repo="${APPS[$app]}"
    deploy_app "$app" "$repo"
done

echo ""
echo "🎉 Initial deployment complete!"
echo ""

# Start watching for changes
watch_and_deploy