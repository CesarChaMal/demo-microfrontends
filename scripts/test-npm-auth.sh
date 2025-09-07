#!/bin/bash

# Test NPM Authentication Script
# Usage: ./test-npm-auth.sh

echo "🧪 Testing NPM Authentication..."
echo "🔍 Current directory: $(pwd)"

# Check if NPM_TOKEN is set
if [ -z "$NPM_TOKEN" ]; then
    echo "❌ NPM_TOKEN not set. Please set it first:"
    echo "   export NPM_TOKEN=npm_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    exit 1
fi

echo "✅ NPM_TOKEN is set"

# Test authentication setup
echo "🔑 Setting up NPM authentication..."
npm config set //registry.npmjs.org/:_authToken $NPM_TOKEN

# Test npm whoami
echo "🔍 Testing npm whoami..."
npm whoami
if [ $? -eq 0 ]; then
    echo "✅ NPM authentication successful!"
else
    echo "❌ NPM authentication failed"
    exit 1
fi

# Test dry run publish on auth app (smallest app)
echo "🧪 Testing dry run publish on single-spa-auth-app..."
cd single-spa-auth-app

# Check if built
if [ ! -f "dist/single-spa-auth-app.umd.js" ]; then
    echo "📦 Building auth app first..."
    npm run build:prod
fi

echo "🧪 Running npm publish --dry-run..."
npm publish --dry-run

if [ $? -eq 0 ]; then
    echo "✅ Dry run successful! NPM_TOKEN authentication is working."
else
    echo "❌ Dry run failed. Check authentication setup."
    exit 1
fi

cd ..
echo "🎉 NPM authentication test completed successfully!"