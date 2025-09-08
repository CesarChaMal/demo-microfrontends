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

# 2. Check available versions in NPM
echo "🔍 Checking available versions in NPM..."
AVAILABLE_VERSION=$(npm view "@${ORG_NAME}/single-spa-auth-app" version 2>/dev/null)

if [ -z "$AVAILABLE_VERSION" ]; then
    echo "❌ No packages found in NPM. Run: npm run publish:npm:prod"
    exit 1
fi

echo "📦 Latest available version: $AVAILABLE_VERSION"

# 3. Update package.json dependencies
cd "$APP_DIR"
echo "📝 Updating dependencies to version $AVAILABLE_VERSION..."

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

echo "✅ Dependencies updated"

# 4. Clear npm cache and install dependencies
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