#!/bin/bash

# Fix NPM Dependencies Script
# Usage: ./fix-npm-deps.sh [app-directory]

APP_DIR=${1:-single-spa-root}
ORG_NAME=${ORG_NAME:-cesarchamal}

echo "🔧 Fixing NPM dependencies for $APP_DIR..."

# 1. Switch to NPM registry
if [ -f ".npmrc.npm" ]; then
    cp .npmrc.npm "$APP_DIR/.npmrc"
    echo "✅ Copied NPM registry config"
elif [ -f ".npmrc.backup" ]; then
    cp .npmrc.backup "$APP_DIR/.npmrc"
    echo "✅ Restored original NPM registry config"
else
    # Remove any custom registry config
    rm -f "$APP_DIR/.npmrc"
    echo "✅ Using default NPM registry"
fi

# 2. Check available versions in NPM (force NPM registry)
echo "🔍 Checking available versions in NPM..."
AVAILABLE_VERSION=$(npm view "@${ORG_NAME}/single-spa-auth-app" version --registry https://registry.npmjs.org/ 2>/dev/null)

if [ -z "$AVAILABLE_VERSION" ]; then
    echo "❌ No packages found in NPM. Run: npm run publish:npm:prod"
    exit 1
fi

echo "📦 Latest available version: $AVAILABLE_VERSION"

# 3. Update package.json dependencies and version
cd "$APP_DIR"
echo "📝 Updating dependencies to version $AVAILABLE_VERSION..."

# Update main package version to match NPM registry
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

echo "✅ Dependencies and version updated"

# 4. Update all app package versions to match
if [ "${FROM_RUN_SCRIPT}" = "true" ] || [ "${SKIP_INSTALL}" = "true" ]; then
    echo "🔄 Updating all app versions to match NPM registry ($AVAILABLE_VERSION)..."
    cd ..
    
    # Update all app package.json versions
    for app in single-spa-auth-app single-spa-layout-app single-spa-home-app single-spa-angular-app single-spa-vue-app single-spa-react-app single-spa-vanilla-app single-spa-webcomponents-app single-spa-typescript-app single-spa-jquery-app single-spa-svelte-app; do
        if [ -d "$app" ]; then
            sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$AVAILABLE_VERSION\"/g" "$app/package.json"
            echo "📝 Updated $app version to $AVAILABLE_VERSION"
        fi
    done
    
    echo "⏭️ Skipping dependency installation (called from publishing workflow)"
    echo "✅ All versions synchronized to $AVAILABLE_VERSION"
else
    echo "🧹 Clearing NPM cache..."
    npm cache clean --force
    
    echo "📦 Installing dependencies..."
    npm install
    
    if [ $? -eq 0 ]; then
        echo "🎉 Dependencies installed successfully!"
    else
        echo "❌ Installation failed"
        exit 1
    fi
fi