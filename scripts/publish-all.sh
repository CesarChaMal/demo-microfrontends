#!/bin/bash

# NPM Publishing Script for All Microfrontends
# Usage: ./publish-all.sh [version-type]
# version-type: patch (default), minor, major

VERSION_TYPE=${1:-patch}

echo "🚀 Publishing all microfrontends to NPM..."
echo "📦 Version bump type: $VERSION_TYPE"
echo ""
echo "🔄 Publishing Workflow:"
echo "  1. 📈 Bump version for all 13 packages"
echo "  2. 🔄 Sync cross-package dependencies"
echo "  3. 🔨 Build each microfrontend"
echo "  4. 📦 Publish to NPM registry"
echo "  5. ✅ Verify successful publishing"
echo ""

# Centralized version management
echo "📈 Updating all package versions..."
node version-manager.js bump $VERSION_TYPE
if [ $? -ne 0 ]; then
  echo "❌ Version update failed"
  exit 1
fi

# Get the new version
NEW_VERSION=$(node -e "console.log(require('./package.json').version)")
echo "📋 New version: $NEW_VERSION"

# Array of all microfrontend directories
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

# Main package (commented out for now)
# MAIN_PACKAGE="."

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
  
  # Actual publish
  echo "🚀 Publishing $app_dir to NPM..."
  npm publish
  
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
npm whoami
if [ $? -ne 0 ]; then
  echo "❌ Not logged in to NPM. Please run 'npm login' first."
  exit 1
fi

echo ""
echo "📋 Apps to publish (13 packages):"
echo "  📦 Main Package:"
echo "    - demo-microfrontends (main package - commented out)"
echo "  🏠 Root Application:"
echo "    - @cesarchamal/single-spa-root"
echo "  📦 Microfrontend Applications:"
for app in "${APPS[@]}"; do
  if [ "$app" != "single-spa-root" ]; then
    echo "    - @cesarchamal/$app"
  fi
done
echo ""
echo "🔄 Version Synchronization:"
echo "  - All packages will use the same version: $NEW_VERSION"
echo "  - Cross-package dependencies will be updated"
echo "  - _trigger fields will be removed if present"

echo ""
read -p "Continue with publishing? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ Publishing cancelled."
  exit 1
fi

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
else
  echo ""
  echo "🎉 All packages published successfully!"
  echo ""
  echo "📝 Next steps:"
  echo "1. Update root application to use NPM mode"
  echo "2. Test loading from NPM packages"
  echo "3. Update documentation"
fi