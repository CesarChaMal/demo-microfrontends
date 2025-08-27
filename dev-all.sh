#!/bin/bash

# Start all microfrontends in development mode
set -e

echo "🚀 Starting ALL microfrontends in development mode..."

# Set Node.js version using nvm
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    echo "🔄 Setting Node.js version..."
    source "$HOME/.nvm/nvm.sh"
    nvm use 22.18.0
fi

export NODE_OPTIONS="--openssl-legacy-provider"

echo "🌐 Starting all applications..."
echo "Root: http://localhost:8080"
echo "Auth: http://localhost:4201"
echo "Layout: http://localhost:4202" 
echo "Home: http://localhost:4203"
echo "Angular: http://localhost:4204"
echo "Vue: http://localhost:4205"
echo "React: http://localhost:4206"
echo ""
echo "Press Ctrl+C to stop all"

# Start all apps concurrently
# npx concurrently \
#   "cd single-spa-login-example-with-npm-packages && npm run serve" \
#   "cd single-spa-auth-app && npm run serve" \
#   "cd single-spa-layout-app && npm run serve" \
#   "cd single-spa-home-app && npm run serve" \
#   "cd single-spa-angular-app && npm run serve" \
#   "cd single-spa-vue-app && npm run serve" \
#   "cd single-spa-react-app && npm run serve"

npm run dev:all