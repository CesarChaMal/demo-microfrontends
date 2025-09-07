#!/bin/bash

# GitHub Pages Status Checker
# Usage: ./check-github-status.sh

set -e

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' ".env" | xargs)
fi

GITHUB_USERNAME=${GITHUB_USERNAME:-cesarchamal}
GITHUB_TOKEN=${GITHUB_API_TOKEN:-${GITHUB_TOKEN}}

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_API_TOKEN not set"
    exit 1
fi

echo "🔍 Checking GitHub Pages status for microfrontends..."
echo "👤 Username: $GITHUB_USERNAME"
echo ""

# List of repositories to check with expected files
declare -A REPOS
REPOS["single-spa-auth-app"]="single-spa-auth-app.umd.js"
REPOS["single-spa-layout-app"]="single-spa-layout-app.umd.js"
REPOS["single-spa-home-app"]="single-spa-home-app.js"
REPOS["single-spa-angular-app"]="single-spa-angular-app.js"
REPOS["single-spa-vue-app"]="single-spa-vue-app.umd.js"
REPOS["single-spa-react-app"]="single-spa-react-app.js"
REPOS["single-spa-vanilla-app"]="single-spa-vanilla-app.js"
REPOS["single-spa-webcomponents-app"]="single-spa-webcomponents-app.js"
REPOS["single-spa-typescript-app"]="single-spa-typescript-app.js"
REPOS["single-spa-jquery-app"]="single-spa-jquery-app.js"
REPOS["single-spa-svelte-app"]="single-spa-svelte-app.js"
REPOS["single-spa-root"]="root-application.js"

for repo in "${!REPOS[@]}"; do
    expected_file="${REPOS[$repo]}"
    echo "📦 Checking repository: $repo"
    echo "   🎯 Expected file: $expected_file"
    
    # 1. Check if repository exists
    REPO_CHECK=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${GITHUB_USERNAME}/${repo}")
    
    if echo "$REPO_CHECK" | grep -q '"message".*"Not Found"'; then
        echo "   ❌ Repository does not exist"
        continue
    else
        echo "   ✅ Repository exists"
    fi
    
    # 2. Check GitHub Pages status
    PAGES_CHECK=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${GITHUB_USERNAME}/${repo}/pages")
    
    if echo "$PAGES_CHECK" | grep -q '"message".*"Not Found"'; then
        echo "   ❌ GitHub Pages not enabled"
    else
        STATUS=$(echo "$PAGES_CHECK" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        URL=$(echo "$PAGES_CHECK" | grep -o '"html_url":"[^"]*"' | cut -d'"' -f4)
        echo "   ✅ GitHub Pages enabled - Status: $STATUS"
        echo "   🌐 URL: $URL"
    fi
    
    # 3. Check repository contents (main branch)
    CONTENTS_CHECK=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${GITHUB_USERNAME}/${repo}/contents")
    
    if echo "$CONTENTS_CHECK" | grep -q '"message".*"Not Found"'; then
        echo "   ❌ No files in repository"
    else
        echo "   📁 Repository files:"
        echo "$CONTENTS_CHECK" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | sed 's/^/      - /'
        
        # Check for specific expected file
        if echo "$CONTENTS_CHECK" | grep -q "$expected_file"; then
            echo "   ✅ Expected bundle file found: $expected_file"
        else
            echo "   ⚠️  Expected bundle file not found: $expected_file"
        fi
    fi
    
    # 4. Test GitHub Pages URL
    pages_url="https://${GITHUB_USERNAME}.github.io/${repo}/${expected_file}"
    echo "   🌐 Testing GitHub Pages: $pages_url"
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$pages_url")
    
    case $HTTP_STATUS in
        200)
            echo "   ✅ GitHub Pages file accessible (HTTP $HTTP_STATUS)"
            ;;
        404)
            echo "   ❌ GitHub Pages file not found (HTTP $HTTP_STATUS)"
            ;;
        *)
            echo "   ⚠️  GitHub Pages unexpected status (HTTP $HTTP_STATUS)"
            ;;
    esac
    
    # 5. Test raw GitHub URL (for dev mode)
    raw_url="https://raw.githubusercontent.com/${GITHUB_USERNAME}/${repo}/main/${expected_file}"
    echo "   📄 Testing raw GitHub: $raw_url"
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$raw_url")
    
    case $HTTP_STATUS in
        200)
            echo "   ✅ Raw GitHub file accessible (HTTP $HTTP_STATUS)"
            ;;
        404)
            echo "   ❌ Raw GitHub file not found (HTTP $HTTP_STATUS)"
            ;;
        *)
            echo "   ⚠️  Raw GitHub unexpected status (HTTP $HTTP_STATUS)"
            ;;
    esac
    
    echo ""
done

echo "📊 Summary of all microfrontend files:"
echo ""

# Summary table
printf "%-25s %-30s %-15s %-15s\n" "Repository" "Expected File" "GitHub Pages" "Raw GitHub"
printf "%-25s %-30s %-15s %-15s\n" "----------" "-------------" "------------" "-----------"

for repo in "${!REPOS[@]}"; do
    expected_file="${REPOS[$repo]}"
    
    # Test GitHub Pages
    pages_url="https://${GITHUB_USERNAME}.github.io/${repo}/${expected_file}"
    pages_status=$(curl -s -o /dev/null -w "%{http_code}" "$pages_url")
    pages_result="❌ $pages_status"
    if [ "$pages_status" = "200" ]; then
        pages_result="✅ $pages_status"
    fi
    
    # Test raw GitHub
    raw_url="https://raw.githubusercontent.com/${GITHUB_USERNAME}/${repo}/main/${expected_file}"
    raw_status=$(curl -s -o /dev/null -w "%{http_code}" "$raw_url")
    raw_result="❌ $raw_status"
    if [ "$raw_status" = "200" ]; then
        raw_result="✅ $raw_status"
    fi
    
    printf "%-25s %-30s %-15s %-15s\n" "$repo" "$expected_file" "$pages_result" "$raw_result"
done

echo ""
echo "🔧 Recommendations:"
echo "1. If repositories exist but GitHub Pages not enabled, run the deployment script again"
echo "2. If files are missing, check the build process in each repository"
echo "3. If GitHub Pages shows 'building', wait 5-10 minutes and try again"
echo "4. Check repository visibility - must be public for GitHub Pages"