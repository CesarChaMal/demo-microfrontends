#!/bin/bash

# Nexus Registry Status Checker
# Usage: ./check-nexus-status.sh

set -e

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' ".env" | xargs)
fi

ORG_NAME=${ORG_NAME:-cesarchamal}
NEXUS_URL=${NEXUS_URL:-http://localhost:8081}
NEXUS_REGISTRY=${NEXUS_REGISTRY:-${NEXUS_URL}/repository/npm-hosted-releases/}

echo "🔍 Checking Nexus registry status for microfrontends..."
echo "🏢 Organization: @$ORG_NAME"
echo "🏭 Nexus URL: $NEXUS_URL"
echo "📦 Nexus Registry: $NEXUS_REGISTRY"
echo ""

# Check current NPM registry
CURRENT_REGISTRY=$(npm config get registry)
echo "📦 Current NPM registry: $CURRENT_REGISTRY"

if [[ "$CURRENT_REGISTRY" == *"localhost:8081"* ]]; then
    echo "✅ Currently using Nexus registry"
else
    echo "⚠️  Not using Nexus registry - switch with: npm run registry:nexus"
fi
echo ""

# Test Nexus connectivity
echo "🔗 Testing Nexus connectivity..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$NEXUS_URL")

case $HTTP_STATUS in
    200)
        echo "✅ Nexus server accessible (HTTP $HTTP_STATUS)"
        ;;
    *)
        echo "❌ Nexus server not accessible (HTTP $HTTP_STATUS)"
        echo "   Make sure Nexus is running on $NEXUS_URL"
        ;;
esac
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

echo "📋 Checking package availability in Nexus..."

for package in "${!PACKAGES[@]}"; do
    expected_file="${PACKAGES[$package]}"
    echo "📦 Checking package: $package"
    echo "   🎯 Expected file: $expected_file"
    
    # Check if package exists in Nexus registry
    NPM_INFO=$(npm view "$package" --json 2>/dev/null || echo "{}")
    
    if echo "$NPM_INFO" | grep -q '"name"'; then
        VERSION=$(echo "$NPM_INFO" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
        
        echo "   ✅ Package exists in Nexus - Version: $VERSION"
        
        # Test direct Nexus URL for package tarball
        # Convert @org/package to org/package for URL
        package_path=$(echo "$package" | sed 's/@//')
        nexus_package_url="${NEXUS_REGISTRY}${package_path}/-/${package##*/}-${VERSION}.tgz"
        echo "   📦 Testing Nexus tarball: $nexus_package_url"
        
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$nexus_package_url")
        
        case $HTTP_STATUS in
            200)
                echo "   ✅ Nexus tarball accessible (HTTP $HTTP_STATUS)"
                ;;
            404)
                echo "   ❌ Nexus tarball not found (HTTP $HTTP_STATUS)"
                ;;
            401|403)
                echo "   ⚠️  Nexus tarball requires authentication (HTTP $HTTP_STATUS)"
                ;;
            *)
                echo "   ⚠️  Nexus tarball unexpected status (HTTP $HTTP_STATUS)"
                ;;
        esac
        
        # Test Nexus package metadata
        nexus_metadata_url="${NEXUS_REGISTRY}${package_path}"
        echo "   📋 Testing Nexus metadata: $nexus_metadata_url"
        
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$nexus_metadata_url")
        
        case $HTTP_STATUS in
            200)
                echo "   ✅ Nexus metadata accessible (HTTP $HTTP_STATUS)"
                ;;
            404)
                echo "   ❌ Nexus metadata not found (HTTP $HTTP_STATUS)"
                ;;
            401|403)
                echo "   ⚠️  Nexus metadata requires authentication (HTTP $HTTP_STATUS)"
                ;;
            *)
                echo "   ⚠️  Nexus metadata unexpected status (HTTP $HTTP_STATUS)"
                ;;
        esac
        
    else
        echo "   ❌ Package not found in Nexus registry"
        
        # Check if it might be available in NPM proxy
        echo "   🔍 Checking NPM proxy in Nexus..."
        NPM_PROXY_INFO=$(curl -s "${NEXUS_REGISTRY}${package}" 2>/dev/null || echo "{}")
        
        if echo "$NPM_PROXY_INFO" | grep -q '"name"'; then
            echo "   ✅ Package available via NPM proxy in Nexus"
        else
            echo "   ❌ Package not available via NPM proxy either"
        fi
    fi
    
    echo ""
done

# Summary table
echo "📊 Summary of all Nexus packages:"
echo ""
printf "%-35s %-10s %-15s %-15s\n" "Package" "Version" "Nexus Direct" "NPM Proxy"
printf "%-35s %-10s %-15s %-15s\n" "-------" "-------" "------------" "---------"

for package in "${!PACKAGES[@]}"; do
    expected_file="${PACKAGES[$package]}"
    
    # Get package info from current registry
    NPM_INFO=$(npm view "$package" --json 2>/dev/null || echo "{}")
    
    if echo "$NPM_INFO" | grep -q '"name"'; then
        VERSION=$(echo "$NPM_INFO" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
        
        # Test Nexus direct access
        package_path=$(echo "$package" | sed 's/@//')
        nexus_package_url="${NEXUS_REGISTRY}${package_path}/-/${package##*/}-${VERSION}.tgz"
        nexus_status=$(curl -s -o /dev/null -w "%{http_code}" "$nexus_package_url")
        nexus_result="❌ $nexus_status"
        if [ "$nexus_status" = "200" ]; then
            nexus_result="✅ $nexus_status"
        elif [ "$nexus_status" = "401" ] || [ "$nexus_status" = "403" ]; then
            nexus_result="⚠️ $nexus_status"
        fi
        
        # Test NPM proxy
        NPM_PROXY_INFO=$(curl -s "${NEXUS_REGISTRY}${package}" 2>/dev/null || echo "{}")
        if echo "$NPM_PROXY_INFO" | grep -q '"name"'; then
            proxy_result="✅ Available"
        else
            proxy_result="❌ N/A"
        fi
        
        printf "%-35s %-10s %-15s %-15s\n" "$package" "$VERSION" "$nexus_result" "$proxy_result"
    else
        printf "%-35s %-10s %-15s %-15s\n" "$package" "N/A" "❌ N/A" "❌ N/A"
    fi
done

echo ""
echo "🔧 Recommendations:"
echo "1. If packages don't exist in Nexus, run: npm run publish:nexus"
echo "2. If Nexus server not accessible, start Nexus: docker run -d -p 8081:8081 sonatype/nexus3"
echo "3. If authentication required, check Nexus credentials in .env file"
echo "4. Switch to Nexus registry with: npm run registry:nexus"
echo "5. Packages may be available via NPM proxy even if not published directly"
echo "6. Check Nexus repository configuration for npm-group, npm-hosted, npm-proxy"