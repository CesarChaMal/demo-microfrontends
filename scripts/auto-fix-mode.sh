#!/bin/bash

# Auto-Fix Mode Dependencies Script
# Usage: ./auto-fix-mode.sh [mode]
# Automatically detects and fixes dependency issues for any mode

MODE=${1:-auto}
ORG_NAME=${ORG_NAME:-cesarchamal}

echo "🔧 Auto-fixing dependencies for mode: $MODE"

# Auto-detect mode if not specified
if [ "$MODE" = "auto" ]; then
    # Check current registry to determine mode
    CURRENT_REGISTRY=$(npm config get registry)
    
    if [[ "$CURRENT_REGISTRY" == *"localhost:8081"* ]]; then
        MODE="nexus"
        echo "🔍 Auto-detected mode: nexus (from registry)"
    elif [[ "$CURRENT_REGISTRY" == *"npmjs.org"* ]]; then
        MODE="npm"
        echo "🔍 Auto-detected mode: npm (from registry)"
    else
        # Check if .npmrc exists in root app
        if [ -f "single-spa-root/.npmrc" ]; then
            if grep -q "localhost:8081" "single-spa-root/.npmrc"; then
                MODE="nexus"
                echo "🔍 Auto-detected mode: nexus (from root .npmrc)"
            else
                MODE="npm"
                echo "🔍 Auto-detected mode: npm (from root .npmrc)"
            fi
        else
            MODE="npm"
            echo "🔍 Defaulting to mode: npm"
        fi
    fi
fi

echo "🎯 Target mode: $MODE"

# Function to check if packages exist and get version
check_packages() {
    local registry_mode=$1
    
    if [ "$registry_mode" = "nexus" ]; then
        # Temporarily switch to nexus to check
        if [ -f ".npmrc.nexus" ]; then
            cp .npmrc.nexus .npmrc.temp
            AVAILABLE_VERSION=$(npm view "@${ORG_NAME}/single-spa-auth-app" version 2>/dev/null)
            rm -f .npmrc.temp
        else
            echo "❌ .npmrc.nexus not found"
            return 1
        fi
    else
        # Check NPM registry
        AVAILABLE_VERSION=$(npm view "@${ORG_NAME}/single-spa-auth-app" version 2>/dev/null)
    fi
    
    if [ -n "$AVAILABLE_VERSION" ]; then
        echo "📦 Found packages in $registry_mode registry: $AVAILABLE_VERSION"
        return 0
    else
        echo "❌ No packages found in $registry_mode registry"
        return 1
    fi
}

# Function to publish packages if needed
publish_packages() {
    local target_mode=$1
    
    echo "📤 Publishing packages to $target_mode registry..."
    
    if [ "$target_mode" = "nexus" ]; then
        npm run publish:nexus:nobump
    else
        npm run publish:npm:nobump
    fi
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully published to $target_mode"
        return 0
    else
        echo "❌ Failed to publish to $target_mode"
        return 1
    fi
}

# Function to fix dependencies
fix_dependencies() {
    local target_mode=$1
    
    echo "🔧 Fixing dependencies for $target_mode mode..."
    
    if [ "$target_mode" = "nexus" ]; then
        bash ./scripts/fix-nexus-deps.sh single-spa-root
    else
        bash ./scripts/fix-npm-deps.sh single-spa-root
    fi
    
    if [ $? -eq 0 ]; then
        echo "✅ Dependencies fixed for $target_mode mode"
        return 0
    else
        echo "❌ Failed to fix dependencies for $target_mode mode"
        return 1
    fi
}

# Main logic
echo ""
echo "🔍 Step 1: Checking if packages exist in $MODE registry..."

if check_packages "$MODE"; then
    echo "✅ Packages found, proceeding with dependency fix..."
    fix_dependencies "$MODE"
else
    echo "⚠️  Packages not found in $MODE registry"
    echo ""
    echo "🔍 Step 2: Checking current local version..."
    CURRENT_VERSION=$(node -e "console.log(require('./package.json').version)" 2>/dev/null)
    echo "📋 Current local version: $CURRENT_VERSION"
    
    echo ""
    echo "📤 Step 3: Publishing current version to $MODE registry..."
    if publish_packages "$MODE"; then
        echo ""
        echo "🔧 Step 4: Fixing dependencies..."
        fix_dependencies "$MODE"
    else
        echo "❌ Auto-fix failed. Manual intervention required."
        echo ""
        echo "💡 Manual steps:"
        echo "1. Check registry authentication: npm run test:${MODE}:auth"
        echo "2. Manually publish: npm run publish:${MODE}:nobump"
        echo "3. Fix dependencies: npm run fix:${MODE}:deps:root"
        exit 1
    fi
fi

echo ""
echo "🎉 Auto-fix completed for $MODE mode!"
echo ""
echo "📝 Next steps:"
echo "1. Run your desired mode: ./run.sh $MODE dev"
echo "2. Or check status: npm run check:$MODE"