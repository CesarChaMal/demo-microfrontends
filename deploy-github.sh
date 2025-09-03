#!/bin/bash

# Deploy individual microfrontend to GitHub Pages
# Usage: ./deploy-github.sh [app-name]

set -e

APP_NAME=${1}

if [ -z "$APP_NAME" ]; then
    echo "❌ Error: App name is required"
    echo "Usage: ./deploy-github.sh [app-name|root]"
    exit 1
fi

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' ".env" | xargs)
fi

GITHUB_USERNAME=${GITHUB_USERNAME:-cesarchamal}
GITHUB_TOKEN=${GITHUB_API_TOKEN:-${GITHUB_TOKEN}}

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_API_TOKEN or GITHUB_TOKEN not set"
    echo "📝 Note: Use GH_API_TOKEN secret in GitHub Actions"
    exit 1
fi

# Configure git user globally first
git config --global user.name "Cesar Francisco Chavez Maldonado - GitHub Actions"
git config --global user.email "cesarchamal@gmail.com"

echo "🚀 Deploying $APP_NAME to GitHub Pages..."

# Handle root app deployment
if [ "$APP_NAME" = "root" ]; then
    APP_DIR="single-spa-root"
    REPO_NAME="single-spa-root"
else
    APP_DIR="$APP_NAME"
    REPO_NAME="$APP_NAME"
fi

# Check if app directory exists
if [ ! -d "$APP_DIR" ]; then
    echo "❌ Error: Directory $APP_DIR not found"
    exit 1
fi

cd "$APP_DIR"

# Build the application
echo "🔨 Building $APP_NAME..."
if [ -f "package.json" ]; then
    npm install
    npm run build
else
    echo "❌ Error: package.json not found in $APP_NAME"
    exit 1
fi

# Check if dist directory exists
if [ ! -d "dist" ]; then
    echo "❌ Error: dist directory not found after build"
    exit 1
fi

# Create GitHub repository if it doesn't exist
echo "🔧 Creating GitHub repository if needed..."
REPO_RESPONSE=$(curl -s -X POST \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/user/repos" \
  -d "{\"name\":\"${REPO_NAME}\",\"description\":\"${REPO_NAME}\",\"private\":false}")

if echo "$REPO_RESPONSE" | grep -q '"message".*"Resource not accessible"'; then
    echo "⚠️  Warning: GitHub token lacks repository creation permissions"
    echo "📝 Please create repository manually: https://github.com/new"
    echo "   Repository name: ${REPO_NAME}"
    echo "   Make it public and continue..."
    read -p "Press Enter after creating the repository..."
elif echo "$REPO_RESPONSE" | grep -q '"name".*already exists'; then
    echo "✅ Repository ${REPO_NAME} already exists"
else
    echo "✅ Repository ${REPO_NAME} created successfully"
    echo "⏳ Waiting for repository to be ready..."
    sleep 5
fi

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
    echo "📦 Initializing git repository..."
    git init
    git branch -M main
fi

# Configure git with token authentication
git remote remove origin 2>/dev/null || true
git remote add origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

# Verify repository exists before proceeding
echo "🔍 Verifying repository exists..."
REPO_CHECK=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${GITHUB_USERNAME}/${REPO_NAME}")
if echo "$REPO_CHECK" | grep -q '"message".*"Not Found"'; then
    echo "❌ Error: Repository ${REPO_NAME} not found after creation"
    echo "📝 Please create repository manually: https://github.com/new"
    echo "   Repository name: ${REPO_NAME}"
    exit 1
else
    echo "✅ Repository verified: ${REPO_NAME}"
fi

# Copy dist contents to root for GitHub Pages
echo "📁 Preparing files for GitHub Pages..."
cp -r dist/* .

# Only commit if there are changes
if [ -n "$(git status --porcelain)" ]; then
    git add .
    git commit -m "Deploy to GitHub Pages"
    
    # Push to main branch
    echo "📤 Pushing to GitHub..."
    if ! git push -u origin main --force; then
        echo "❌ Error: Failed to push to GitHub"
        echo "📝 Make sure the repository exists: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
        echo "🔑 Check that your GitHub token has push permissions"
        exit 1
    fi
else
    echo "📝 No changes to deploy"
fi

# Enable GitHub Pages via API
echo "🌐 Enabling GitHub Pages..."
curl -X POST \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/${GITHUB_USERNAME}/${REPO_NAME}/pages" \
  -d '{"source":{"branch":"main","path":"/"}}' \
  2>/dev/null || echo "GitHub Pages may already be enabled"

cd ..

echo "✅ $APP_NAME deployed to https://${GITHUB_USERNAME}.github.io/${REPO_NAME}/"
echo "⏳ GitHub Pages may take a few minutes to become available"