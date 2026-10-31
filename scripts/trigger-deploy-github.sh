#!/bin/bash

# Trigger both GitHub deployment workflows
# Usage: ./trigger-deploy-github.sh [commit-message]

set -e

COMMIT_MSG=${1:-"Deploy all microfrontends to GitHub Pages"}

TIMESTAMP=$(date +%s)

echo "🚀 Triggering GitHub Pages deployments..."

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
    "single-spa-solid-app"
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

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) is not installed"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Error: Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

echo "📝 Commit message: $COMMIT_MSG"

# Add all changes
echo "📦 Adding changes..."
git add .

# Commit changes
echo "💾 Committing changes..."
git commit -m "$COMMIT_MSG" || echo "No changes to commit"

# Push to main (triggers automatic workflow)
echo "📤 Pushing to main branch (triggers automatic deployment)..."
git push origin main

# Wait a moment for the push to register
sleep 2

# Trigger manual workflow
echo "🔧 Triggering manual deployment workflow..."
gh workflow run "Deploy to GitHub Pages (Manual)"

echo ""
echo "✅ Both GitHub deployments triggered!"
echo "📊 Check progress at: https://github.com/$(gh repo view --json owner,name -q '.owner.login + "/" + .name')/actions"
echo ""
echo "🌐 Automatic deployment: Simple workflow (uses deploy-github.sh)"
echo "🔧 Manual deployment: Complex workflow (matrix + import map)"
echo ""
echo "🌍 After deployment, your apps will be live at:"
echo "https://$(gh api user --jq .login).github.io/demo-microfrontends/"