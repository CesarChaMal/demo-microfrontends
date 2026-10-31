#!/bin/bash

# Fix Nexus Dependencies Script
# Usage: ./fix-nexus-deps.sh [app-directory]

APP_DIR=${1:-single-spa-root}
ORG_NAME=${ORG_NAME:-cesarchamal}

echo "🔧 Fixing Nexus dependencies for $APP_DIR..."

# 1. Copy Nexus registry config
if [ -f ".npmrc.nexus" ]; then
    cp .npmrc.nexus "$APP_DIR/.npmrc"
    echo "✅ Copied Nexus registry config"
else
    echo "❌ .npmrc.nexus not found"
    exit 1
fi

# 2. Check available versions in Nexus (force Nexus registry)
echo "🔍 Checking available versions in Nexus..."
# Get Nexus registry URL from .npmrc.nexus
NEXUS_REGISTRY=$(grep '^registry=' .npmrc.nexus | cut -d'=' -f2)
if [ -z "$NEXUS_REGISTRY" ]; then
    echo "❌ No registry found in .npmrc.nexus"
    exit 1
fi
AVAILABLE_VERSION=$(npm view "@${ORG_NAME}/single-spa-auth-app" version --registry "$NEXUS_REGISTRY" 2>/dev/null)

if [ -z "$AVAILABLE_VERSION" ]; then
    echo "❌ No packages found in Nexus. Run: npm run publish:nexus:prod"
    exit 1
fi

echo "📦 Latest available version: $AVAILABLE_VERSION"

# 3. Update package.json dependencies and version
cd "$APP_DIR"
echo "📝 Updating dependencies to version $AVAILABLE_VERSION..."

# Update main package version to match Nexus registry
if [ "$APP_DIR" = "single-spa-root" ] || [ "$APP_DIR" = "." ]; then
    # Update main package version
    sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$AVAILABLE_VERSION\"/g" package.json
    echo "📝 Updated main package version to $AVAILABLE_VERSION"
    
    # Also update root directory package.json if we're in a subdirectory
    if [ "$APP_DIR" != "." ]; then
        cd ..
        sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$AVAILABLE_VERSION\"/g" package.json
        echo "📝 Updated root package version to $AVAILABLE_VERSION"
        cd "$APP_DIR"
    fi
fi

# Update all microfrontend dependencies to exact version
sed -i "s/\"@${ORG_NAME}\/single-spa-auth-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-auth-app\": \"$AVAILABLE_VERSION\"/g" package.json
sed -i "s/\"@${ORG_NAME}\/single-spa-layout-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-layout-app\": \"$AVAILABLE_VERSION\"/g" package.json
sed -i "s/\"@${ORG_NAME}\/single-spa-home-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-home-app\": \"$AVAILABLE_VERSION\"/g" package.json
sed -i "s/\"@${ORG_NAME}\/single-spa-angular-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-angular-app\": \"$AVAILABLE_VERSION\"/g" package.json
sed -i "s/\"@${ORG_NAME}\/single-spa-vue-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-vue-app\": \"$AVAILABLE_VERSION\"/g" package.json
sed -i "s/\"@${ORG_NAME}\/single-spa-react-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-react-app\": \"$AVAILABLE_VERSION\"/g" package.json
sed -i "s/\"@${ORG_NAME}\/single-spa-vanilla-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-vanilla-app\": \"$AVAILABLE_VERSION\"/g" package.json
sed -i "s/\"@${ORG_NAME}\/single-spa-webcomponents-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-webcomponents-app\": \"$AVAILABLE_VERSION\"/g" package.json
sed -i "s/\"@${ORG_NAME}\/single-spa-typescript-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-typescript-app\": \"$AVAILABLE_VERSION\"/g" package.json
sed -i "s/\"@${ORG_NAME}\/single-spa-jquery-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-jquery-app\": \"$AVAILABLE_VERSION\"/g" package.json
sed -i "s/\"@${ORG_NAME}\/single-spa-svelte-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-svelte-app\": \"$AVAILABLE_VERSION\"/g" package.json
sed -i "s/\"@${ORG_NAME}\/single-spa-solid-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-solid-app\": \"$AVAILABLE_VERSION\"/g" package.json

echo "✅ Dependencies and version updated"

# 4. Update all app package versions and mode-specific files
if [ "${FROM_RUN_SCRIPT}" = "true" ] || [ "${SKIP_INSTALL}" = "true" ]; then
    echo "🔄 Updating all app versions to match Nexus registry ($AVAILABLE_VERSION)..."
    cd ..
    
    # Update all app package.json versions
    for app in single-spa-auth-app single-spa-layout-app single-spa-home-app single-spa-angular-app single-spa-vue-app single-spa-react-app single-spa-vanilla-app single-spa-webcomponents-app single-spa-typescript-app single-spa-jquery-app single-spa-svelte-app single-spa-solid-app; do
        if [ -d "$app" ]; then
            sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$AVAILABLE_VERSION\"/g" "$app/package.json"
            echo "📝 Updated $app version to $AVAILABLE_VERSION"
        fi
    done
    
    # Update package-nexus.json dependencies to match Nexus registry
    if [ -f "package-nexus.json" ]; then
        echo "📝 Updating package-nexus.json dependencies to $AVAILABLE_VERSION..."
        sed -i "s/\"@${ORG_NAME}\/single-spa-auth-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-auth-app\": \"$AVAILABLE_VERSION\"/g" package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-layout-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-layout-app\": \"$AVAILABLE_VERSION\"/g" package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-home-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-home-app\": \"$AVAILABLE_VERSION\"/g" package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-angular-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-angular-app\": \"$AVAILABLE_VERSION\"/g" package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-vue-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-vue-app\": \"$AVAILABLE_VERSION\"/g" package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-react-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-react-app\": \"$AVAILABLE_VERSION\"/g" package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-vanilla-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-vanilla-app\": \"$AVAILABLE_VERSION\"/g" package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-webcomponents-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-webcomponents-app\": \"$AVAILABLE_VERSION\"/g" package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-typescript-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-typescript-app\": \"$AVAILABLE_VERSION\"/g" package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-jquery-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-jquery-app\": \"$AVAILABLE_VERSION\"/g" package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-svelte-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-svelte-app\": \"$AVAILABLE_VERSION\"/g" package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-solid-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-solid-app\": \"$AVAILABLE_VERSION\"/g" package-nexus.json
        echo "✅ Updated package-nexus.json dependencies"
    fi
    
    # Update single-spa-root/package-nexus.json dependencies
    if [ -f "single-spa-root/package-nexus.json" ]; then
        echo "📝 Updating single-spa-root/package-nexus.json dependencies to $AVAILABLE_VERSION..."
        sed -i "s/\"@${ORG_NAME}\/single-spa-auth-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-auth-app\": \"$AVAILABLE_VERSION\"/g" single-spa-root/package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-layout-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-layout-app\": \"$AVAILABLE_VERSION\"/g" single-spa-root/package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-home-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-home-app\": \"$AVAILABLE_VERSION\"/g" single-spa-root/package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-angular-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-angular-app\": \"$AVAILABLE_VERSION\"/g" single-spa-root/package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-vue-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-vue-app\": \"$AVAILABLE_VERSION\"/g" single-spa-root/package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-react-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-react-app\": \"$AVAILABLE_VERSION\"/g" single-spa-root/package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-vanilla-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-vanilla-app\": \"$AVAILABLE_VERSION\"/g" single-spa-root/package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-webcomponents-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-webcomponents-app\": \"$AVAILABLE_VERSION\"/g" single-spa-root/package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-typescript-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-typescript-app\": \"$AVAILABLE_VERSION\"/g" single-spa-root/package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-jquery-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-jquery-app\": \"$AVAILABLE_VERSION\"/g" single-spa-root/package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-svelte-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-svelte-app\": \"$AVAILABLE_VERSION\"/g" single-spa-root/package-nexus.json
        sed -i "s/\"@${ORG_NAME}\/single-spa-solid-app\": \"[^\"]*\"/\"@${ORG_NAME}\/single-spa-solid-app\": \"$AVAILABLE_VERSION\"/g" single-spa-root/package-nexus.json
        echo "✅ Updated single-spa-root/package-nexus.json dependencies"
    fi
    
    echo "⏭️ Skipping dependency installation (called from publishing workflow)"
    echo "✅ All versions synchronized to $AVAILABLE_VERSION"
else
    echo "📦 Installing dependencies..."
    npm install
    
    if [ $? -eq 0 ]; then
        echo "🎉 Dependencies installed successfully!"
    else
        echo "❌ Installation failed"
        exit 1
    fi
fi