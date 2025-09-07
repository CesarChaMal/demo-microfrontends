#!/bin/bash

# Local Development Status Checker
# Usage: ./check-local-status.sh

set -e

echo "🔍 Checking local development status for microfrontends..."
echo ""

# List of applications and their ports
declare -A APPS
APPS["single-spa-root"]="8080"
APPS["single-spa-auth-app"]="4201"
APPS["single-spa-layout-app"]="4202"
APPS["single-spa-home-app"]="4203"
APPS["single-spa-angular-app"]="4204"
APPS["single-spa-vue-app"]="4205"
APPS["single-spa-react-app"]="4206"
APPS["single-spa-vanilla-app"]="4207"
APPS["single-spa-webcomponents-app"]="4208"
APPS["single-spa-typescript-app"]="4209"
APPS["single-spa-jquery-app"]="4210"
APPS["single-spa-svelte-app"]="4211"

# Expected bundle files for each app
declare -A BUNDLE_FILES
BUNDLE_FILES["single-spa-root"]="root-application.js"
BUNDLE_FILES["single-spa-auth-app"]="single-spa-auth-app.umd.js"
BUNDLE_FILES["single-spa-layout-app"]="single-spa-layout-app.umd.js"
BUNDLE_FILES["single-spa-home-app"]="single-spa-home-app.js"
BUNDLE_FILES["single-spa-angular-app"]="single-spa-angular-app.js"
BUNDLE_FILES["single-spa-vue-app"]="single-spa-vue-app.umd.js"
BUNDLE_FILES["single-spa-react-app"]="single-spa-react-app.js"
BUNDLE_FILES["single-spa-vanilla-app"]="single-spa-vanilla-app.js"
BUNDLE_FILES["single-spa-webcomponents-app"]="single-spa-webcomponents-app.js"
BUNDLE_FILES["single-spa-typescript-app"]="single-spa-typescript-app.js"
BUNDLE_FILES["single-spa-jquery-app"]="single-spa-jquery-app.js"
BUNDLE_FILES["single-spa-svelte-app"]="single-spa-svelte-app.js"

echo "🏠 Checking local development servers..."

for app in "${!APPS[@]}"; do
    port="${APPS[$app]}"
    bundle_file="${BUNDLE_FILES[$app]}"
    
    echo "📦 Checking app: $app"
    echo "   🎯 Port: $port"
    echo "   📄 Bundle file: $bundle_file"
    
    # Check if port is in use
    if command -v lsof >/dev/null 2>&1; then
        PORT_CHECK=$(lsof -ti:$port 2>/dev/null || echo "")
        if [ -n "$PORT_CHECK" ]; then
            echo "   ✅ Port $port is in use (PID: $PORT_CHECK)"
        else
            echo "   ❌ Port $port is not in use"
        fi
    elif command -v netstat >/dev/null 2>&1; then
        PORT_CHECK=$(netstat -an | grep ":$port " | grep LISTEN || echo "")
        if [ -n "$PORT_CHECK" ]; then
            echo "   ✅ Port $port is listening"
        else
            echo "   ❌ Port $port is not listening"
        fi
    else
        echo "   ⚠️  Cannot check port status (lsof/netstat not available)"
    fi
    
    # Test HTTP endpoint
    local_url="http://localhost:$port"
    echo "   🌐 Testing local server: $local_url"
    
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$local_url" --connect-timeout 5 || echo "000")
    
    case $HTTP_STATUS in
        200)
            echo "   ✅ Local server accessible (HTTP $HTTP_STATUS)"
            ;;
        000)
            echo "   ❌ Local server not reachable (connection failed)"
            ;;
        *)
            echo "   ⚠️  Local server unexpected status (HTTP $HTTP_STATUS)"
            ;;
    esac
    
    # Test bundle file endpoint
    bundle_url="http://localhost:$port/$bundle_file"
    echo "   📄 Testing bundle file: $bundle_url"
    
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$bundle_url" --connect-timeout 5 || echo "000")
    
    case $HTTP_STATUS in
        200)
            echo "   ✅ Bundle file accessible (HTTP $HTTP_STATUS)"
            ;;
        404)
            echo "   ❌ Bundle file not found (HTTP $HTTP_STATUS)"
            ;;
        000)
            echo "   ❌ Bundle file not reachable (connection failed)"
            ;;
        *)
            echo "   ⚠️  Bundle file unexpected status (HTTP $HTTP_STATUS)"
            ;;
    esac
    
    echo ""
done

echo "📁 Checking built files in dist directories..."

for app in "${!APPS[@]}"; do
    bundle_file="${BUNDLE_FILES[$app]}"
    
    echo "📦 Checking built files for: $app"
    
    # Check if app directory exists
    if [ -d "$app" ]; then
        echo "   ✅ Directory exists: $app/"
        
        # Check for dist directory
        if [ -d "$app/dist" ]; then
            echo "   ✅ Dist directory exists: $app/dist/"
            
            # Check for bundle file
            if [ -f "$app/dist/$bundle_file" ]; then
                echo "   ✅ Bundle file exists: $app/dist/$bundle_file"
                
                # Get file size
                file_size=$(stat -c%s "$app/dist/$bundle_file" 2>/dev/null || stat -f%z "$app/dist/$bundle_file" 2>/dev/null || echo "unknown")
                echo "   📊 File size: $file_size bytes"
            else
                echo "   ❌ Bundle file missing: $app/dist/$bundle_file"
            fi
            
            # List other files in dist
            echo "   📁 Other files in dist:"
            ls -la "$app/dist/" 2>/dev/null | grep -v "^total" | grep -v "^d" | sed 's/^/      /' || echo "      (none)"
        else
            echo "   ❌ Dist directory missing: $app/dist/"
        fi
    else
        echo "   ❌ Directory missing: $app/"
    fi
    
    echo ""
done

# Summary table
echo "📊 Summary of local development status:"
echo ""
printf "%-25s %-6s %-15s %-15s %-15s\n" "Application" "Port" "Server" "Bundle URL" "Built File"
printf "%-25s %-6s %-15s %-15s %-15s\n" "-----------" "----" "------" "----------" "----------"

for app in "${!APPS[@]}"; do
    port="${APPS[$app]}"
    bundle_file="${BUNDLE_FILES[$app]}"
    
    # Test server
    local_url="http://localhost:$port"
    server_status=$(curl -s -o /dev/null -w "%{http_code}" "$local_url" --connect-timeout 5 || echo "000")
    server_result="❌ $server_status"
    if [ "$server_status" = "200" ]; then
        server_result="✅ $server_status"
    fi
    
    # Test bundle URL
    bundle_url="http://localhost:$port/$bundle_file"
    bundle_status=$(curl -s -o /dev/null -w "%{http_code}" "$bundle_url" --connect-timeout 5 || echo "000")
    bundle_result="❌ $bundle_status"
    if [ "$bundle_status" = "200" ]; then
        bundle_result="✅ $bundle_status"
    fi
    
    # Check built file
    if [ -f "$app/dist/$bundle_file" ]; then
        built_result="✅ Exists"
    else
        built_result="❌ Missing"
    fi
    
    printf "%-25s %-6s %-15s %-15s %-15s\n" "$app" "$port" "$server_result" "$bundle_result" "$built_result"
done

echo ""
echo "🔧 Recommendations:"
echo "1. If servers are not running, start them with: ./run.sh local dev"
echo "2. If bundle files are missing, build them with: npm run build:dev"
echo "3. If ports are in use by other processes, stop them or change ports"
echo "4. For production builds, use: npm run build:prod"
echo "5. Check individual app logs if servers fail to start"
echo "6. Ensure all dependencies are installed: npm run install:all"