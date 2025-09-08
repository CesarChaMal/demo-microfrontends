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

# 2. Check available versions in Nexus
echo "🔍 Checking available versions in Nexus..."
AVAILABLE_VERSION=$(npm view "@${ORG_NAME}/single-spa-auth-app" versions --json | grep -o '"[0-9]\+\.[0-9]\+\.[0-9]\+"' | tail -1 | tr -d '"')

if [ -z "$AVAILABLE_VERSION" ]; then
    echo "❌ No packages found in Nexus. Run: npm run publish:nexus:prod"
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

# 4. Install dependencies
echo "📦 Installing dependencies..."
npm install

if [ $? -eq 0 ]; then
    echo "🎉 Dependencies installed successfully!"
else
    echo "❌ Installation failed"
    exit 1
fi