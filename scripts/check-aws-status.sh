#!/bin/bash

# AWS S3 Status Checker
# Usage: ./check-aws-status.sh

set -e

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' ".env" | xargs)
fi

S3_BUCKET=${S3_BUCKET}
AWS_REGION=${AWS_REGION:-us-east-1}
ORG_NAME=${ORG_NAME:-cesarchamal}

if [ -z "$S3_BUCKET" ]; then
    echo "❌ Error: S3_BUCKET not set"
    exit 1
fi

echo "🔍 Checking AWS S3 status for microfrontends..."
echo "🪣 Bucket: $S3_BUCKET"
echo "🌍 Region: $AWS_REGION"
echo "🏢 Organization: $ORG_NAME"
echo ""

# S3 website URL format
S3_WEBSITE_URL="http://${S3_BUCKET}.s3-website-${AWS_REGION}.amazonaws.com"
S3_API_URL="https://${S3_BUCKET}.s3.${AWS_REGION}.amazonaws.com"

echo "🌐 S3 Website URL: $S3_WEBSITE_URL"
echo "📡 S3 API URL: $S3_API_URL"
echo ""

# List of microfrontends and expected files
declare -A APPS
APPS["auth-app"]="single-spa-auth-app.umd.js"
APPS["layout-app"]="single-spa-layout-app.umd.js"
APPS["home-app"]="single-spa-home-app.js"
APPS["angular-app"]="single-spa-angular-app.js"
APPS["vue-app"]="single-spa-vue-app.umd.js"
APPS["react-app"]="single-spa-react-app.js"
APPS["vanilla-app"]="single-spa-vanilla-app.js"
APPS["webcomponents-app"]="single-spa-webcomponents-app.js"
APPS["typescript-app"]="single-spa-typescript-app.js"
APPS["jquery-app"]="single-spa-jquery-app.js"
APPS["svelte-app"]="single-spa-svelte-app.js"

# Check root application files
echo "🏠 Checking root application files..."

ROOT_FILES=("index.html" "root-application.js")
for file in "${ROOT_FILES[@]}"; do
    echo "📄 Testing root file: $file"
    
    # Test S3 website URL
    website_url="${S3_WEBSITE_URL}/${file}"
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$website_url")
    
    case $HTTP_STATUS in
        200)
            echo "   ✅ S3 Website accessible (HTTP $HTTP_STATUS): $website_url"
            ;;
        404)
            echo "   ❌ S3 Website file not found (HTTP $HTTP_STATUS): $website_url"
            ;;
        *)
            echo "   ⚠️  S3 Website unexpected status (HTTP $HTTP_STATUS): $website_url"
            ;;
    esac
    
    # Test S3 API URL
    api_url="${S3_API_URL}/${file}"
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$api_url")
    
    case $HTTP_STATUS in
        200)
            echo "   ✅ S3 API accessible (HTTP $HTTP_STATUS): $api_url"
            ;;
        403)
            echo "   ⚠️  S3 API forbidden (HTTP $HTTP_STATUS): $api_url"
            ;;
        404)
            echo "   ❌ S3 API file not found (HTTP $HTTP_STATUS): $api_url"
            ;;
        *)
            echo "   ⚠️  S3 API unexpected status (HTTP $HTTP_STATUS): $api_url"
            ;;
    esac
done

echo ""

# Check import map
echo "📋 Checking import map..."
importmap_path="@${ORG_NAME}/importmap.json"

# Test S3 website URL for import map
website_importmap_url="${S3_WEBSITE_URL}/${importmap_path}"
echo "📄 Testing import map: $importmap_path"

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$website_importmap_url")

case $HTTP_STATUS in
    200)
        echo "   ✅ Import map accessible (HTTP $HTTP_STATUS): $website_importmap_url"
        
        # Download and show import map content
        echo "   📋 Import map content:"
        curl -s "$website_importmap_url" | jq . 2>/dev/null || curl -s "$website_importmap_url"
        ;;
    404)
        echo "   ❌ Import map not found (HTTP $HTTP_STATUS): $website_importmap_url"
        ;;
    *)
        echo "   ⚠️  Import map unexpected status (HTTP $HTTP_STATUS): $website_importmap_url"
        ;;
esac

echo ""

# Check each microfrontend
echo "🧩 Checking microfrontend files..."

for app in "${!APPS[@]}"; do
    expected_file="${APPS[$app]}"
    app_path="@${ORG_NAME}/${app}/${expected_file}"
    
    echo "📦 Checking app: $app"
    echo "   🎯 Expected file: $expected_file"
    echo "   📁 S3 path: $app_path"
    
    # Test S3 website URL
    website_url="${S3_WEBSITE_URL}/${app_path}"
    echo "   🌐 Testing S3 Website: $website_url"
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$website_url")
    
    case $HTTP_STATUS in
        200)
            echo "   ✅ S3 Website file accessible (HTTP $HTTP_STATUS)"
            ;;
        404)
            echo "   ❌ S3 Website file not found (HTTP $HTTP_STATUS)"
            ;;
        *)
            echo "   ⚠️  S3 Website unexpected status (HTTP $HTTP_STATUS)"
            ;;
    esac
    
    # Test S3 API URL
    api_url="${S3_API_URL}/${app_path}"
    echo "   📡 Testing S3 API: $api_url"
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$api_url")
    
    case $HTTP_STATUS in
        200)
            echo "   ✅ S3 API file accessible (HTTP $HTTP_STATUS)"
            ;;
        403)
            echo "   ⚠️  S3 API forbidden (HTTP $HTTP_STATUS)"
            ;;
        404)
            echo "   ❌ S3 API file not found (HTTP $HTTP_STATUS)"
            ;;
        *)
            echo "   ⚠️  S3 API unexpected status (HTTP $HTTP_STATUS)"
            ;;
    esac
    
    echo ""
done

# Summary table
echo "📊 Summary of all microfrontend files:"
echo ""
printf "%-20s %-35s %-15s %-15s\n" "Application" "Expected File" "S3 Website" "S3 API"
printf "%-20s %-35s %-15s %-15s\n" "-----------" "-------------" "-----------" "-------"

# Root files summary
for file in "${ROOT_FILES[@]}"; do
    # Test S3 website
    website_url="${S3_WEBSITE_URL}/${file}"
    website_status=$(curl -s -o /dev/null -w "%{http_code}" "$website_url")
    website_result="❌ $website_status"
    if [ "$website_status" = "200" ]; then
        website_result="✅ $website_status"
    fi
    
    # Test S3 API
    api_url="${S3_API_URL}/${file}"
    api_status=$(curl -s -o /dev/null -w "%{http_code}" "$api_url")
    api_result="❌ $api_status"
    if [ "$api_status" = "200" ]; then
        api_result="✅ $api_status"
    elif [ "$api_status" = "403" ]; then
        api_result="⚠️ $api_status"
    fi
    
    printf "%-20s %-35s %-15s %-15s\n" "root" "$file" "$website_result" "$api_result"
done

# Import map summary
importmap_path="@${ORG_NAME}/importmap.json"
website_importmap_url="${S3_WEBSITE_URL}/${importmap_path}"
importmap_status=$(curl -s -o /dev/null -w "%{http_code}" "$website_importmap_url")
importmap_result="❌ $importmap_status"
if [ "$importmap_status" = "200" ]; then
    importmap_result="✅ $importmap_status"
fi

printf "%-20s %-35s %-15s %-15s\n" "importmap" "importmap.json" "$importmap_result" "N/A"

# Microfrontends summary
for app in "${!APPS[@]}"; do
    expected_file="${APPS[$app]}"
    app_path="@${ORG_NAME}/${app}/${expected_file}"
    
    # Test S3 website
    website_url="${S3_WEBSITE_URL}/${app_path}"
    website_status=$(curl -s -o /dev/null -w "%{http_code}" "$website_url")
    website_result="❌ $website_status"
    if [ "$website_status" = "200" ]; then
        website_result="✅ $website_status"
    fi
    
    # Test S3 API
    api_url="${S3_API_URL}/${app_path}"
    api_status=$(curl -s -o /dev/null -w "%{http_code}" "$api_url")
    api_result="❌ $api_status"
    if [ "$api_status" = "200" ]; then
        api_result="✅ $api_status"
    elif [ "$api_status" = "403" ]; then
        api_result="⚠️ $api_status"
    fi
    
    printf "%-20s %-35s %-15s %-15s\n" "$app" "$expected_file" "$website_result" "$api_result"
done

echo ""
echo "🔧 Recommendations:"
echo "1. If S3 Website returns 404, check if files are deployed to S3"
echo "2. If S3 API returns 403, this is normal for public website hosting"
echo "3. S3 Website URLs should be used for actual application access"
echo "4. Import map should be accessible for SystemJS to load microfrontends"
echo "5. Run deployment script if files are missing: ./scripts/deploy-s3.sh"
echo "6. Check S3 bucket policy and website configuration if needed"