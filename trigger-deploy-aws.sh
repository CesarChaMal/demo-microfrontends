#!/bin/bash

# Trigger AWS S3 deployment by adding timestamps to package.json files
# Usage: ./trigger-deploy-aws.sh [commit-message]

set -e

COMMIT_MSG=${1:-"Deploy all microfrontends to S3"}
TIMESTAMP=$(date +%s)

echo "🚀 Triggering AWS S3 deployment..."

# List of all microfrontend apps
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

# Clean up previous triggers and add new one to each app
for app in "${APPS[@]}"; do
    if [ -f "$app/package.json" ]; then
        echo "📝 Cleaning and adding trigger to $app..."
        # Remove all existing _trigger entries (handles multiple occurrences)
        sed -i 's/ "_trigger": "[0-9]*",//g' "$app/package.json"
        sed -i 's/, "_trigger": "[0-9]*"//g' "$app/package.json"
        # Add new trigger after version
        sed -i "s/\"version\": \"\\([^\"]*\\)\",/\"version\": \"\\1\", \"_trigger\": \"$TIMESTAMP\",/g" "$app/package.json"
    fi
done

# Also trigger root app
if [ -f "single-spa-root/package.json" ]; then
    echo "📝 Cleaning and adding trigger to single-spa-root..."
    # Remove all existing _trigger entries (handles multiple occurrences)
    sed -i 's/ "_trigger": "[0-9]*",//g' "single-spa-root/package.json"
    sed -i 's/, "_trigger": "[0-9]*"//g' "single-spa-root/package.json"
    # Add new trigger after version
    sed -i "s/\"version\": \"\\([^\"]*\\)\",/\"version\": \"\\1\", \"_trigger\": \"$TIMESTAMP\",/g" "single-spa-root/package.json"
fi

echo ""
echo "✅ Triggers added to all applications"
echo "📤 Committing and pushing to trigger GitHub Actions deployment..."

# Commit and push
git add .
git commit -m "$COMMIT_MSG"
git push origin main

echo ""
echo "🌍 After deployment, your app will be live at:"
echo "${S3_WEBSITE_URL:-http://single-spa-demo-774145483743.s3-website-eu-central-1.amazonaws.com}"