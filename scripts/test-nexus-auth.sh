#!/bin/bash

# Test Nexus Authentication Script
# Usage: ./test-nexus-auth.sh

echo "🧪 Testing Nexus Authentication..."
echo "🔍 Current directory: $(pwd)"

# Load environment variables from .env file
echo "🔍 DEBUG: Looking for .env file in current directory: $(pwd)"
if [ -f ".env" ]; then
    echo "📄 Loading environment variables from .env..."
    export $(grep -v '^#' ".env" | xargs)
    echo "🔍 DEBUG: Environment variables loaded from .env"
elif [ -f "../.env" ]; then
    echo "📄 Loading environment variables from ../.env..."
    export $(grep -v '^#' "../.env" | xargs)
    echo "🔍 DEBUG: Environment variables loaded from ../.env"
else
    echo "⚠️ Warning: No .env file found, using environment variables only"
fi

# Set Nexus configuration with fallback to environment variables
NEXUS_USER=${NEXUS_USER:-admin}
NEXUS_PASS=${NEXUS_PASS:-}
NEXUS_URL=${NEXUS_URL:-http://localhost:8081}
NEXUS_REGISTRY=${NEXUS_REGISTRY:-http://localhost:8081/repository/npm-group/}
NEXUS_PUBLISH_REGISTRY=${NEXUS_PUBLISH_REGISTRY:-http://localhost:8081/repository/npm-hosted-releases/}

echo "🔍 DEBUG: Nexus configuration - USER=$NEXUS_USER, URL=$NEXUS_URL"
echo "🔍 DEBUG: Registry: $NEXUS_REGISTRY"
echo "🔍 DEBUG: Publish Registry: $NEXUS_PUBLISH_REGISTRY"

if [ -z "$NEXUS_PASS" ]; then
    echo "❌ Error: NEXUS_PASS not set in .env file or environment variables"
    echo "💡 Please set NEXUS_PASS in .env file or export NEXUS_PASS=your-password"
    exit 1
fi

# Check if .npmrc.nexus exists or create from environment variables
if [ -f ".npmrc.nexus" ]; then
    echo "✅ .npmrc.nexus found"
    # Switch to Nexus registry
    echo "🔄 Switching to Nexus registry..."
    if [ -f ".npmrc" ]; then
        cp .npmrc .npmrc.backup
    fi
    cp .npmrc.nexus .npmrc
else
    echo "📋 .npmrc.nexus not found, generating from environment variables..."
    # Backup existing .npmrc
    if [ -f ".npmrc" ]; then
        cp .npmrc .npmrc.backup
    fi
    # Generate .npmrc from environment variables
    AUTH_TOKEN=$(echo -n "$NEXUS_USER:$NEXUS_PASS" | base64)
    cat > .npmrc << EOF
registry=$NEXUS_REGISTRY
//localhost:8081/repository/npm-group/:_auth=$AUTH_TOKEN
//localhost:8081/repository/npm-hosted-releases/:_auth=$AUTH_TOKEN
//localhost:8081/repository/npm-group/:always-auth=true
//localhost:8081/repository/npm-hosted-releases/:always-auth=true
EOF
    echo "✅ Generated .npmrc from NEXUS_USER and NEXUS_PASS"
fi

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