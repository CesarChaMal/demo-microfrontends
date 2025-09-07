#!/bin/bash

# NPM Publishing Script for All Microfrontends
# Usage: ./publish-npm.sh [version-type] [environment]
# version-type: patch (default), minor, major
# environment: dev (default), prod

echo "🔍 DEBUG: NPM publish script started"
echo "🔍 DEBUG: Arguments: $@"
echo "🔍 DEBUG: Current directory: $(pwd)"
echo "🔍 DEBUG: NPM version: $(npm --version)"
echo "🔍 DEBUG: Node version: $(node --version)"
echo "🔍 DEBUG: Called from run.sh: ${FROM_RUN_SCRIPT:-false}"

# Auto-switch to NPM registry if not called from run.sh
if [ "${FROM_RUN_SCRIPT}" != "true" ]; then
    echo "🔄 Auto-switching to NPM registry..."
    if [ -f ".npmrc" ]; then
        cp .npmrc .npmrc.backup
    fi
    if [ -f ".npmrc.npm" ]; then
        cp .npmrc.npm .npmrc
        echo "📝 Registry switched to: $(npm config get registry)"
    else
        echo "❌ Error: .npmrc.npm not found. Please create it first."
        exit 1
    fi
fi

# Load environment variables from .env file if not called from run.sh
if [ "${FROM_RUN_SCRIPT}" != "true" ] && [ -f "../.env" ]; then
    echo "📄 Loading .env file..."
    export $(grep -v '^#' "../.env" | xargs)
fi

echo "🔍 DEBUG: NPM registry: $(npm config get registry)"
echo "🔍 DEBUG: NPM user: $(npm whoami 2>/dev/null || echo 'Not logged in')"

VERSION_TYPE=${1:-patch}
ENVIRONMENT=${2:-dev}

echo "🚀 Publishing to NPM..."
echo "📦 Version bump type: $VERSION_TYPE"
echo "🌐 Environment: $ENVIRONMENT"
echo ""
echo "🔑 Authentication Options:"
echo "  - NPM_TOKEN: Use automation token (recommended for CI/CD)"
echo "  - NPM_OTP: Provide 2FA code for interactive login"
echo "  - Manual: Use 'npm login' without environment variables"
echo ""
echo "🔄 Publishing Workflow:"
echo "  1. 📈 Bump version for all packages"
echo "  2. 🔄 Sync cross-package dependencies"
echo "  3. 🔨 Build each microfrontend"
echo "  4. 📦 Publish microfrontends to NPM registry"
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "  5. 📦 Publish root app to NPM registry (prod only)"
    echo "  6. ✅ Verify successful publishing"
else
    echo "  5. ✅ Verify successful publishing"
fi
echo ""

# Centralized version management
echo "📈 Updating all package versions..."
node scripts/version-manager.js bump $VERSION_TYPE
if [ $? -ne 0 ]; then
  echo "❌ Version update failed"
  exit 1
fi

# Get the new version
NEW_VERSION=$(node -e "console.log(require('./package.json').version)")
echo "📋 New version: $NEW_VERSION"

# Array of microfrontend directories (excluding root app)
APPS=(
  "single-spa-auth-app"
  "single-spa-layout-app"
  "single-spa-home-app"
  "single-spa-angular-app"
  "single-spa-vue-app"
  "single-spa-react-app"
  "single-spa-vanilla-app"
  "single-spa-webcomponents-app"
  "single-spa-typescript-app"
  "single-spa-jquery-app"
  "single-spa-svelte-app"
)

# Main package (root app) - handled separately in prod mode
# MAIN_PACKAGE="single-spa-root"

# Function to publish a single app
publish_app() {
  local app_dir=$1
  echo ""
  echo "📦 Publishing $app_dir..."
  
  cd "$app_dir" || exit 1
  
  # Check if package.json exists
  if [ ! -f "package.json" ]; then
    echo "❌ No package.json found in $app_dir"
    cd ..
    return 1
  fi
  
  # Build the app
  echo "🔨 Building $app_dir..."
  npm run build:prod
  
  if [ $? -ne 0 ]; then
    echo "❌ Build failed for $app_dir"
    cd ..
    return 1
  fi
  
  # Version is already updated by version-manager.js
  echo "📋 Using centrally managed version: $NEW_VERSION"
  
  # Dry run first
  echo "🧪 Dry run for $app_dir..."
  npm publish --dry-run
  
  if [ $? -ne 0 ]; then
    echo "❌ Dry run failed for $app_dir"
    cd ..
    return 1
  fi
  
  # Actual publish with authentication
  echo "🚀 Publishing $app_dir to NPM..."
  if [ -n "$NPM_TOKEN" ]; then
    echo "🔑 Using NPM_TOKEN for $app_dir"
    export NPM_CONFIG_//registry.npmjs.org/:_authToken="$NPM_TOKEN"
    npm publish
  elif [ -n "$NPM_OTP" ]; then
    npm publish --otp="$NPM_OTP"
  else
    npm publish
  fi
  
  if [ $? -eq 0 ]; then
    echo "✅ Successfully published $app_dir"
  else
    echo "❌ Failed to publish $app_dir"
    cd ..
    return 1
  fi
  
  cd ..
}

# Main execution
echo "🔍 Checking NPM authentication..."
if [ -n "$NPM_TOKEN" ]; then
  echo "🔑 Using NPM_TOKEN for authentication"
  echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" > ~/.npmrc
else
  npm whoami
  if [ $? -ne 0 ]; then
    echo "❌ Not logged in to NPM. Please run 'npm login' first or set NPM_TOKEN environment variable."
    exit 1
  fi
fi

echo ""
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "📋 Packages to publish (12 packages):"
    echo "  📦 Microfrontend Applications (11):"
    for app in "${APPS[@]}"; do
        echo "    - @cesarchamal/$app"
    done
    echo "  📦 Root Application (1) - Main Package:"
    echo "    - @cesarchamal/single-spa-root"
else
    echo "📋 Microfrontends to publish (11 packages):"
    echo "  📦 Microfrontend Applications:"
    for app in "${APPS[@]}"; do
        echo "    - @cesarchamal/$app"
    done
    echo "  📝 Note: Main package (root app) not published in dev mode"
fi
echo ""
echo "🔄 Version Synchronization:"
echo "  - All packages will use the same version: $NEW_VERSION"
echo "  - Cross-package dependencies will be updated"
echo "  - _trigger fields will be removed if present"

echo ""
# Interactive prompt (commented out for automation)
# read -p "Continue with publishing? (y/N): " -n 1 -r
# echo
# if [[ ! $REPLY =~ ^[Yy]$ ]]; then
#   echo "❌ Publishing cancelled."
#   exit 1
# fi
echo "🚀 Proceeding with publishing automatically..."

# Build all apps first
echo ""
echo "🔨 Building all apps..."
npm run build

# Publish each app
FAILED_APPS=()
SUCCESSFUL_APPS=()

for app in "${APPS[@]}"; do
  if publish_app "$app"; then
    SUCCESSFUL_APPS+=("$app")
  else
    FAILED_APPS+=("$app")
  fi
done

# Summary
echo ""
echo "📊 Publishing Summary:"
echo "✅ Successful (${#SUCCESSFUL_APPS[@]}):"
for app in "${SUCCESSFUL_APPS[@]}"; do
  echo "  - @cesarchamal/$app"
done

if [ ${#FAILED_APPS[@]} -gt 0 ]; then
  echo "❌ Failed (${#FAILED_APPS[@]}):"
  for app in "${FAILED_APPS[@]}"; do
    echo "  - @cesarchamal/$app"
  done
  exit 1
fi

# Publish root app in production mode
if [ "$ENVIRONMENT" = "prod" ]; then
    echo ""
    echo "📦 Production mode: Publishing root app to NPM for public access"
    cd single-spa-root
    echo "🔍 DEBUG: Publishing root app from $(pwd)"
    
    # Dry run first
    echo "🧪 Dry run for root app..."
    npm publish --dry-run
    
    if [ $? -ne 0 ]; then
        echo "❌ Root app dry run failed"
        cd ..
        exit 1
    fi
    
    # Actual publish with authentication
    echo "🚀 Publishing root app to NPM..."
    if [ -n "$NPM_TOKEN" ]; then
      echo "🔑 Using NPM_TOKEN for root app"
      export NPM_CONFIG_//registry.npmjs.org/:_authToken="$NPM_TOKEN"
      npm publish
    elif [ -n "$NPM_OTP" ]; then
      npm publish --otp="$NPM_OTP"
    else
      npm publish
    fi
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully published root app"
        echo "🌍 Public NPM Package: https://www.npmjs.com/package/@cesarchamal/single-spa-root"
    else
        echo "❌ Failed to publish root app"
        cd ..
        exit 1
    fi
    
    cd ..
fi

echo ""
echo "🎉 All packages published successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Switch to NPM mode to test loading from NPM packages"
echo "2. Use 'npm run mode:npm' to load microfrontends from registry"
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "3. Root app is now publicly available on NPM registry"
fi