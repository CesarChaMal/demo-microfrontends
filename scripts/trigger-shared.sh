#!/bin/bash

# Trigger GitHub Actions for shared dependencies only

set -e

APP_DIR="shared"
APP_NAME="shared"

echo "🚀 Triggering GitHub Actions for $APP_NAME dependencies..."

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Warning: You have uncommitted changes. Please commit or stash them first."
    exit 1
fi

if [ -d "$APP_DIR" ]; then
    echo "📦 Triggering action for $APP_NAME..."
    
    # Create trigger file
    echo "# Trigger file for GitHub Actions - $(date)" > "$APP_DIR/.github-trigger"
    
    # Add and commit
    git add "$APP_DIR/.github-trigger"
    git commit -m "trigger: Deploy $APP_NAME dependencies" --quiet
    
    echo "🎯 Pushing trigger commit..."
    git push origin main
    
    echo "✅ $APP_NAME dependencies GitHub Action triggered successfully!"
else
    echo "❌ Error: Directory $APP_DIR not found"
    exit 1
fi