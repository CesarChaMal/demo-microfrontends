#!/bin/bash

# Test Nexus Authentication Script
# Usage: ./test-nexus-auth.sh

echo "🧪 Testing Nexus Authentication..."
echo "🔍 Current directory: $(pwd)"

# Check if .npmrc.nexus exists
if [ ! -f ".npmrc.nexus" ]; then
    echo "❌ .npmrc.nexus not found. Please create it first."
    exit 1
fi

echo "✅ .npmrc.nexus found"

# Switch to Nexus registry
echo "🔄 Switching to Nexus registry..."
if [ -f ".npmrc" ]; then
    cp .npmrc .npmrc.backup
fi
cp .npmrc.nexus .npmrc

echo "📝 Registry switched to: $(npm config get registry)"

# Test npm whoami
echo "🔍 Testing npm whoami..."
npm whoami
if [ $? -eq 0 ]; then
    echo "✅ Nexus authentication successful!"
else
    echo "❌ Nexus authentication failed"
    echo "💡 Check .npmrc.nexus configuration:"
    echo "   - registry=http://localhost:8081/repository/npm-group/"
    echo "   - //localhost:8081/repository/npm-group/:_auth=<base64-user:pass>"
    echo "   - //localhost:8081/repository/npm-group/:always-auth=true"
    exit 1
fi

# Test dry run publish on auth app
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
    echo "✅ Dry run successful! Nexus authentication is working."
else
    echo "❌ Dry run failed. Check Nexus configuration."
    exit 1
fi

cd ..

# Restore original .npmrc
if [ -f ".npmrc.backup" ]; then
    echo "🔄 Restoring original .npmrc..."
    cp .npmrc.backup .npmrc
    rm .npmrc.backup
fi

echo "🎉 Nexus authentication test completed successfully!"