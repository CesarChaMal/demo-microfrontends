#!/bin/bash

# AWS S3 Hot Sync Script
# Usage: ./aws-hot-sync.sh

set -e

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' ".env" | xargs)
fi

S3_BUCKET=${S3_BUCKET}
AWS_REGION=${AWS_REGION:-us-east-1}
ORG_NAME=${ORG_NAME:-cesarchamal}

if [ -z "$S3_BUCKET" ]; then
    echo "❌ Error: S3_BUCKET not set"
    exit 1
fi

echo "🔥 Starting AWS S3 Hot Sync for microfrontends..."
echo "🪣 Bucket: $S3_BUCKET"
echo "🌍 Region: $AWS_REGION"
echo "🏢 Organization: $ORG_NAME"
echo ""

# List of applications and their S3 paths
declare -A APPS
APPS["single-spa-root"]=""
APPS["single-spa-auth-app"]="@${ORG_NAME}/auth-app/"
APPS["single-spa-layout-app"]="@${ORG_NAME}/layout-app/"
APPS["single-spa-home-app"]="@${ORG_NAME}/home-app/"
APPS["single-spa-angular-app"]="@${ORG_NAME}/angular-app/"
APPS["single-spa-vue-app"]="@${ORG_NAME}/vue-app/"
APPS["single-spa-react-app"]="@${ORG_NAME}/react-app/"
APPS["single-spa-vanilla-app"]="@${ORG_NAME}/vanilla-app/"
APPS["single-spa-webcomponents-app"]="@${ORG_NAME}/webcomponents-app/"
APPS["single-spa-typescript-app"]="@${ORG_NAME}/typescript-app/"
APPS["single-spa-jquery-app"]="@${ORG_NAME}/jquery-app/"
APPS["single-spa-svelte-app"]="@${ORG_NAME}/svelte-app/"
APPS["single-spa-solid-app"]="@${ORG_NAME}/solid-app/"

# Function to sync a single app
sync_app() {
    local app=$1
    local s3_path=$2
    
    if [ -d "$app/dist" ]; then
        echo "🔄 Syncing $app to s3://$S3_BUCKET/$s3_path"
        aws s3 sync "$app/dist/" "s3://$S3_BUCKET/$s3_path" \
            --exclude "*.hot-update.*" \
            --exclude "*.map" \
            --delete \
            --cache-control "no-cache, no-store, must-revalidate"
        echo "✅ Synced $app"
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

# Function to watch and sync all apps
watch_and_sync() {
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
                echo "📁 File changes detected, syncing all apps..."
                for app in "${!APPS[@]}"; do
                    s3_path="${APPS[$app]}"
                    sync_app "$app" "$s3_path"
                done
                echo "🎉 All apps synced at $(date)"
                echo ""
            done
        else
            echo "❌ No dist directories found to watch"
        fi
    else
        echo "Using polling method (fswatch not available)..."
        echo "💡 Platform: $OSTYPE"
        echo ""
        
        # Polling method - check every 5 seconds
        while true; do
            sleep 5
            
            # Check if any dist directory has been modified in the last 10 seconds
            CHANGED=false
            for app in "${!APPS[@]}"; do
                if [ -d "$app/dist" ]; then
                    if find "$app/dist" -type f -newermt "10 seconds ago" 2>/dev/null | grep -q .; then
                        CHANGED=true
                        break
                    fi
                fi
            done
            
            if [ "$CHANGED" = true ]; then
                echo "📁 File changes detected, syncing all apps..."
                for app in "${!APPS[@]}"; do
                    s3_path="${APPS[$app]}"
                    sync_app "$app" "$s3_path"
                done
                echo "🎉 All apps synced at $(date)"
                echo ""
            fi
        done
    fi
}


# Initial sync of all apps
echo "🚀 Performing initial sync of all apps..."
for app in "${!APPS[@]}"; do
    s3_path="${APPS[$app]}"
    sync_app "$app" "$s3_path"
done

echo ""
echo "🎉 Initial sync complete!"
echo ""

# Start watching for changes
watch_and_sync