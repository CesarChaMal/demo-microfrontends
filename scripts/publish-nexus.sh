#!/bin/bash

# Nexus Publishing Script for All Microfrontends
# Usage: ./publish-nexus.sh [version-type] [environment]
# version-type: patch (default), minor, major
# environment: dev (default), prod

echo "🔍 DEBUG: Nexus publish script started"
echo "🔍 DEBUG: Arguments: $@"
echo "🔍 DEBUG: Current directory: $(pwd)"
echo "🔍 DEBUG: NPM version: $(npm --version)"
echo "🔍 DEBUG: Node version: $(node --version)"
echo "🔍 DEBUG: Called from run.sh: ${FROM_RUN_SCRIPT:-false}"

# Auto-switch to Nexus registry if not called from run.sh
if [ "${FROM_RUN_SCRIPT}" != "true" ]; then
    echo "🔄 Auto-switching to Nexus registry..."
    if [ -f ".npmrc" ]; then
        cp .npmrc .npmrc.backup
    fi
    if [ -f ".npmrc.nexus" ]; then
        cp .npmrc.nexus .npmrc
        echo "📝 Registry switched to: $(npm config get registry)"
    else
        echo "❌ Error: .npmrc.nexus not found. Please create it first."
        exit 1
    fi
fi

echo "🔍 DEBUG: NPM registry: $(npm config get registry)"
echo "🔍 DEBUG: NPM user: $(npm whoami 2>/dev/null || echo 'Not logged in')"

VERSION_TYPE=${1:-patch}
ENVIRONMENT=${2:-dev}

echo "🚀 Publishing to Nexus..."
echo "📦 Version bump type: $VERSION_TYPE"
echo "🌐 Environment: $ENVIRONMENT"
echo ""
echo "🔄 Publishing Workflow:"
echo "  1. 📈 Bump version for all packages"
echo "  2. 🔄 Sync cross-package dependencies"
echo "  3. 🔨 Build each microfrontend"
echo "  4. 📦 Publish microfrontends to Nexus registry"
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "  5. 📦 Publish root app to Nexus registry (prod only)"
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

# Define packages based on environment
if [ "$ENVIRONMENT" = "prod" ]; then
    # Production: publish all 12 packages including root
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
      "single-spa-root"
    )
else
    # Development: publish nothing
    APPS=()
fi

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
  
  # Copy Nexus .npmrc to app directory
  cp ../.npmrc .npmrc
  
  # Actual publish to Nexus
  echo "🚀 Publishing $app_dir to Nexus..."
  npm publish
  
  # Clean up .npmrc from app directory
  rm -f .npmrc
  
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
echo "🔍 Checking Nexus authentication..."
echo "📝 Using .npmrc.nexus configuration for authentication"
npm whoami
if [ $? -ne 0 ]; then
  echo "❌ Nexus authentication failed. Please check .npmrc.nexus configuration."
  echo "💡 Current registry: $(npm config get registry)"
  echo "💡 Make sure .npmrc.nexus contains proper authentication:"
  echo "   - registry=http://localhost:8081/repository/npm-group/"
  echo "   - //localhost:8081/repository/npm-group/:_auth=<base64-user:pass>"
  echo "   - //localhost:8081/repository/npm-group/:always-auth=true"
  exit 1
fi

echo ""
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "📋 All packages to publish (12 packages):"
    for app in "${APPS[@]}"; do
        echo "  - @cesarchamal/$app"
    done
else
    echo "📋 Development mode: No packages will be published"
    echo "  📝 Note: Use prod mode to publish all packages"
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

if [ "$ENVIRONMENT" = "dev" ]; then
    echo ""
    echo "📝 Development mode: Skipping publishing"
    echo "✅ Version updated to $NEW_VERSION for all packages"
    echo "💡 Use 'npm run publish:nexus:prod' to publish all packages"
else
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
fi

echo ""
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "🎉 All packages published successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "1. Switch to Nexus mode to test loading from Nexus packages"
    echo "2. Use 'npm run mode:nexus' to load microfrontends from registry"
    echo "3. All packages including root app are now available on Nexus registry"
else
    echo "✅ Version management completed!"
    echo ""
    echo "📝 Next steps:"
    echo "1. Use 'npm run publish:nexus:prod' to publish all packages"
    echo "2. Or continue with local development"
fi