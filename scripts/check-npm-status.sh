#!/bin/bash

# NPM Registry Status Checker
# Usage: ./check-npm-status.sh

set -e

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' ".env" | xargs)
fi

ORG_NAME=${ORG_NAME:-cesarchamal}

echo "🔍 Checking NPM registry status for microfrontends..."
echo "🏢 Organization: @$ORG_NAME"
echo ""

# Check current NPM registry
CURRENT_REGISTRY=$(npm config get registry)
echo "📦 Current NPM registry: $CURRENT_REGISTRY"
echo ""

# List of packages and expected files
declare -A PACKAGES
PACKAGES["@${ORG_NAME}/single-spa-auth-app"]="single-spa-auth-app.umd.js"
PACKAGES["@${ORG_NAME}/single-spa-layout-app"]="single-spa-layout-app.umd.js"
PACKAGES["@${ORG_NAME}/single-spa-home-app"]="single-spa-home-app.js"
PACKAGES["@${ORG_NAME}/single-spa-angular-app"]="single-spa-angular-app.js"
PACKAGES["@${ORG_NAME}/single-spa-vue-app"]="single-spa-vue-app.umd.js"
PACKAGES["@${ORG_NAME}/single-spa-react-app"]="single-spa-react-app.js"
PACKAGES["@${ORG_NAME}/single-spa-vanilla-app"]="single-spa-vanilla-app.js"
PACKAGES["@${ORG_NAME}/single-spa-webcomponents-app"]="single-spa-webcomponents-app.js"
PACKAGES["@${ORG_NAME}/single-spa-typescript-app"]="single-spa-typescript-app.js"
PACKAGES["@${ORG_NAME}/single-spa-jquery-app"]="single-spa-jquery-app.js"
PACKAGES["@${ORG_NAME}/single-spa-svelte-app"]="single-spa-svelte-app.js"
PACKAGES["@${ORG_NAME}/single-spa-solid-app"]="single-spa-solid-app.js"
PACKAGES["@${ORG_NAME}/single-spa-root"]="root-application.js"

echo "📋 Checking package availability..."

for package in "${!PACKAGES[@]}"; do
    expected_file="${PACKAGES[$package]}"
    echo "📦 Checking package: $package"
    echo "   🎯 Expected file: $expected_file"
    
    # Check if package exists in registry
    NPM_INFO=$(npm view "$package" --json 2>/dev/null || echo "{}")
    
    if echo "$NPM_INFO" | grep -q '"name"'; then
        VERSION=$(echo "$NPM_INFO" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
        TARBALL=$(echo "$NPM_INFO" | grep -o '"tarball":"[^"]*"' | cut -d'"' -f4)
        
        echo "   ✅ Package exists - Version: $VERSION"
        echo "   📦 Tarball: $TARBALL"
        
        # Test unpkg CDN URL
        unpkg_url="https://unpkg.com/${package}@latest/dist/${expected_file}"
        echo "   🌐 Testing unpkg CDN: $unpkg_url"
        
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$unpkg_url")
        
        case $HTTP_STATUS in
            200)
                echo "   ✅ unpkg CDN file accessible (HTTP $HTTP_STATUS)"
                ;;
            404)
                echo "   ❌ unpkg CDN file not found (HTTP $HTTP_STATUS)"
                ;;
            *)
                echo "   ⚠️  unpkg CDN unexpected status (HTTP $HTTP_STATUS)"
                ;;
        esac
        
        # Test jsdelivr CDN URL
        jsdelivr_url="https://cdn.jsdelivr.net/npm/${package}@latest/dist/${expected_file}"
        echo "   🌐 Testing jsdelivr CDN: $jsdelivr_url"
        
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$jsdelivr_url")
        
        case $HTTP_STATUS in
            200)
                echo "   ✅ jsdelivr CDN file accessible (HTTP $HTTP_STATUS)"
                ;;
            404)
                echo "   ❌ jsdelivr CDN file not found (HTTP $HTTP_STATUS)"
                ;;
            *)
                echo "   ⚠️  jsdelivr CDN unexpected status (HTTP $HTTP_STATUS)"
                ;;
        esac
        
    else
        echo "   ❌ Package not found in registry"
    fi
    
    echo ""
done

# Summary table
echo "📊 Summary of all NPM packages:"
echo ""
printf "%-35s %-10s %-15s %-15s\n" "Package" "Version" "unpkg CDN" "jsdelivr CDN"
printf "%-35s %-10s %-15s %-15s\n" "-------" "-------" "---------" "-----------"

for package in "${!PACKAGES[@]}"; do
    expected_file="${PACKAGES[$package]}"
    
    # Get package info
    NPM_INFO=$(npm view "$package" --json 2>/dev/null || echo "{}")
    
    if echo "$NPM_INFO" | grep -q '"name"'; then
        VERSION=$(echo "$NPM_INFO" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
        
        # Test unpkg CDN
        unpkg_url="https://unpkg.com/${package}@latest/dist/${expected_file}"
        unpkg_status=$(curl -s -o /dev/null -w "%{http_code}" "$unpkg_url")
        unpkg_result="❌ $unpkg_status"
        if [ "$unpkg_status" = "200" ]; then
            unpkg_result="✅ $unpkg_status"
        fi
        
        # Test jsdelivr CDN
        jsdelivr_url="https://cdn.jsdelivr.net/npm/${package}@latest/dist/${expected_file}"
        jsdelivr_status=$(curl -s -o /dev/null -w "%{http_code}" "$jsdelivr_url")
        jsdelivr_result="❌ $jsdelivr_status"
        if [ "$jsdelivr_status" = "200" ]; then
            jsdelivr_result="✅ $jsdelivr_status"
        fi
        
        printf "%-35s %-10s %-15s %-15s\n" "$package" "$VERSION" "$unpkg_result" "$jsdelivr_result"
    else
        printf "%-35s %-10s %-15s %-15s\n" "$package" "N/A" "❌ N/A" "❌ N/A"
    fi
done

echo ""
echo "🔧 Recommendations:"
echo "1. If packages don't exist, run: npm run publish:npm"
echo "2. If CDN files return 404, check dist/ folder structure in packages"
echo "3. unpkg and jsdelivr CDNs may take time to sync after publishing"
echo "4. Verify package.json 'files' field includes dist/ directory"
echo "5. Check that build process creates expected bundle files"