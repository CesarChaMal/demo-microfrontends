#!/bin/bash

# Test build script with OpenSSL legacy provider
echo "🧪 Testing build with Node.js 18.20.8 and OpenSSL legacy provider..."

# Set Node.js version using nvm
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    echo "🔄 Setting Node.js version..."
    source "$HOME/.nvm/nvm.sh"
    nvm use 18.20.8
fi

# Set OpenSSL legacy provider for Node.js 18+ compatibility
export NODE_OPTIONS="--openssl-legacy-provider"

echo "📦 Node.js version: $(node --version)"
echo "🔧 NODE_OPTIONS: $NODE_OPTIONS"

# Test build auth app
echo "🔨 Testing auth app build..."
cd single-spa-auth-app
npm install --legacy-peer-deps
npm run build:prod
cd ..

echo "✅ Build test completed!"