#!/bin/bash

# Version Manager for Demo Microfrontends (Linux/Mac)
# Usage: ./version-manager.sh [command] [args]

COMMAND=$1
ARG1=$2
ARG2=$3

if [ -z "$COMMAND" ]; then
    echo ""
    echo "📦 Version Manager for Demo Microfrontends"
    echo ""
    echo "🔄 Integration with Publishing:"
    echo "  ./publish-all.sh patch                         - Auto-bump patch + publish all"
    echo "  ./publish-all.sh minor                         - Auto-bump minor + publish all"
    echo "  ./publish-all.sh major                         - Auto-bump major + publish all"
    echo ""
    echo "📋 Manual Version Management:"
    echo "  ./version-manager.sh bump [patch|minor|major]  - Increment version for all packages"
    echo "  ./version-manager.sh set <version>             - Set specific version for all packages"
    echo "  ./version-manager.sh reset [version]           - Reset all packages to base version (default: 0.1.0)"
    echo "  ./version-manager.sh current                   - Show current versions"
    echo "  ./version-manager.sh clean                     - Remove _trigger fields"
    echo ""
    echo "💡 Version Bump Examples:"
    echo "  ./version-manager.sh bump patch                - 0.1.0 → 0.1.1 (bug fixes)"
    echo "  ./version-manager.sh bump minor                - 0.1.0 → 0.2.0 (new features)"
    echo "  ./version-manager.sh bump major                - 0.1.0 → 1.0.0 (breaking changes)"
    echo "  ./version-manager.sh set 1.2.3                 - Set all to 1.2.3 (specific version)"
    echo "  ./version-manager.sh reset                     - Reset all to 0.1.0 (base version)"
    echo "  ./version-manager.sh reset 1.0.0               - Reset all to 1.0.0 (custom base)"
    echo ""
    echo "🔍 Information Commands:"
    echo "  ./version-manager.sh current                   - Show all package versions"
    echo "  ./version-manager.sh reset                     - Reset all to base version"
    echo "  ./version-manager.sh clean                     - Clean _trigger fields"
    echo ""
    echo "🎯 Complete Workflow Examples:"
    echo "  # Quick patch release:"
    echo "  ./publish-all.sh patch"
    echo ""
    echo "  # Manual version then publish:"
    echo "  ./version-manager.sh bump minor"
    echo "  ./publish-all.sh"
    echo ""
    echo "  # Check versions before publishing:"
    echo "  ./version-manager.sh current"
    echo "  ./publish-all.sh patch"
    echo ""
    echo "📦 What Gets Updated (13 packages total):"
    echo "  - demo-microfrontends (main package)"
    echo "  - @cesarchamal/single-spa-root"
    echo "  - @cesarchamal/single-spa-auth-app"
    echo "  - @cesarchamal/single-spa-layout-app"
    echo "  - @cesarchamal/single-spa-home-app"
    echo "  - @cesarchamal/single-spa-angular-app"
    echo "  - @cesarchamal/single-spa-vue-app"
    echo "  - @cesarchamal/single-spa-react-app"
    echo "  - @cesarchamal/single-spa-vanilla-app"
    echo "  - @cesarchamal/single-spa-webcomponents-app"
    echo "  - @cesarchamal/single-spa-typescript-app"
    echo "  - @cesarchamal/single-spa-jquery-app"
    echo "  - @cesarchamal/single-spa-svelte-app"
    echo ""
    exit 1
fi

# Call the Node.js version manager
node version-manager.js "$COMMAND" "$ARG1" "$ARG2"
exit $?