#!/bin/bash

# Trigger GitHub Actions for all microfrontend apps
# This script makes dummy commits to each app directory to trigger their workflows

set -e

echo "🚀 Triggering GitHub Actions for all microfrontend apps..."

# List of all microfrontend directories
APPS=(
    "single-spa-root"
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

# Function to trigger action for a specific app
trigger_app() {
    local app_dir=$1
    local app_name=$(echo $app_dir | sed 's/single-spa-//' | sed 's/-app//')
    
    echo "📦 Triggering action for $app_name..."
    
    # Create or update a trigger file in the app directory
    echo "# Trigger file for GitHub Actions - $(date)" > "$app_dir/.github-trigger"
    
    # Also update package.json version to ensure a real change
    if [ -f "$app_dir/package.json" ]; then
        # Add a comment to package.json to trigger the workflow
#        sed -i.bak 's/"version": "\([^"]*\)"/"version": "\1", "_trigger": "'$(date +%s)'"/' "$app_dir/package.json" 2>/dev/null || true
        rm -f "$app_dir/package.json.bak" 2>/dev/null || true
    fi
    
    # Add and commit the changes
    git add "$app_dir/.github-trigger" "$app_dir/package.json" 2>/dev/null || git add "$app_dir/.github-trigger"
    git commit -m "trigger: Deploy $app_name app" --quiet || echo "No changes to commit for $app_name"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Warning: You have uncommitted changes. Please commit or stash them first."
    echo "Uncommitted files:"
    git status --porcelain
    exit 1
fi

# Trigger actions for all apps
for app in "${APPS[@]}"; do
    if [ -d "$app" ]; then
        trigger_app "$app"
    else
        echo "⚠️  Warning: Directory $app not found, skipping..."
    fi
done

echo ""
echo "🎯 Pushing all trigger commits..."
git push origin main

echo ""
echo "✅ All GitHub Actions triggered successfully!"
echo "🔗 Check the Actions tab in your GitHub repository to see the workflows running."
echo ""
echo "Apps triggered:"
for app in "${APPS[@]}"; do
    if [ -d "$app" ]; then
        app_name=$(echo $app | sed 's/single-spa-//' | sed 's/-app//')
        echo "  - $app_name"
    fi
done