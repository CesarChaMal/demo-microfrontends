# Dependency Fixes Guide

This guide helps resolve dependency version mismatches, module loading issues, and registry conflicts when switching between deployment modes (Local, NPM, Nexus, GitHub, AWS).

## Overview

The microfrontend architecture uses synchronized versioning across all 12 applications. When switching between deployment modes, you may encounter:

### Common Issues
- **Version Mismatches**: Local version differs from registry versions
- **Registry Conflicts**: Different registries have different versions
- **Module Loading Errors**: Runtime failures due to missing or wrong versions
- **Authentication Issues**: Registry access problems
- **Dependency Resolution**: npm install failures

### Example Problem
```
Local version: 1.0.0
NPM registry: 0.1.4  
Nexus registry: 1.0.0
GitHub Pages: 0.9.0
AWS S3: 1.0.0
```

This causes `npm install` to fail with "No matching version found" errors.

## Quick Fixes

### Universal Auto-Fix (Recommended)
```bash
# Auto-detect mode and fix everything
npm run fix:auto

# Then run your desired mode
./run.sh [mode] dev
```

### Mode-Specific Quick Fixes
```bash
# NPM mode issues
npm run fix:auto:npm
./run.sh npm dev

# Nexus mode issues
npm run fix:auto:nexus
./run.sh nexus dev

# GitHub mode issues
npm run fix:auto:github
./run.sh github dev

# AWS mode issues
npm run fix:auto:aws
./run.sh aws dev
```

## Detailed Solutions by Mode

### NPM Registry Issues

**Problem:** Your local version is 1.0.0 but NPM only has 0.1.4

**Solutions:**

#### Option 1: Auto-fix Dependencies (Recommended)
```bash
# Automatically detect and fix version mismatches
npm run fix:npm:deps:root

# Then run NPM mode
./run.sh npm dev
```

#### Option 2: Match NPM Version
```bash
# Set local version to match NPM
npm run version:set 0.1.4

# Run NPM mode
./run.sh npm dev
```

#### Option 3: Publish Current Version
```bash
# Publish current version (1.0.0) to NPM without bumping
npm run publish:npm:nobump

# Then run NPM mode
./run.sh npm dev
```

### Nexus Registry Issues

**Problem:** Version mismatch between local and Nexus registry

**Solutions:**

#### Option 1: Auto-fix Dependencies (Recommended)
```bash
# Automatically detect and fix version mismatches
npm run fix:nexus:deps:root

# Then run Nexus mode
./run.sh nexus dev
```

#### Option 2: Match Nexus Version
```bash
# Check what's available in Nexus
npm run check:nexus

# Set local version to match
npm run version:set 1.0.0

# Run Nexus mode
./run.sh nexus dev
```

#### Option 3: Publish Current Version
```bash
# Publish current version to Nexus without bumping
npm run publish:nexus:nobump

# Then run Nexus mode
./run.sh nexus dev
```

### GitHub Pages Issues

**Problem:** Deployed version doesn't match local version

**Solutions:**

#### Option 1: Auto-fix and Redeploy
```bash
# Fix and redeploy automatically
npm run fix:auto:github
./run.sh github prod
```

#### Option 2: Manual Redeploy
```bash
# Redeploy current version
./run.sh github prod

# Or use development mode with existing deployment
./run.sh github dev
```

### AWS S3 Issues

**Problem:** S3 deployment version mismatch

**Solutions:**

#### Option 1: Auto-fix and Redeploy
```bash
# Fix and redeploy automatically
npm run fix:auto:aws
./run.sh aws prod
```

#### Option 2: Manual Redeploy
```bash
# Redeploy current version
./run.sh aws prod

# Or use development mode with existing deployment
./run.sh aws dev
```

## Available Fix Scripts

### Auto-Fix Scripts (Recommended)
```bash
# Universal auto-fix - detects mode and fixes automatically
npm run fix:auto

# Mode-specific auto-fixes
npm run fix:auto:npm      # Auto-fix for NPM mode
npm run fix:auto:nexus    # Auto-fix for Nexus mode
npm run fix:auto:github   # Auto-fix for GitHub mode
npm run fix:auto:aws      # Auto-fix for AWS mode
```

### Registry-Specific Fixes
```bash
# NPM Registry Fixes
npm run fix:npm:deps           # Fix any app's NPM dependencies
npm run fix:npm:deps:root      # Fix root app NPM dependencies
npm run fix:npm:deps:all       # Fix all apps' NPM dependencies

# Nexus Registry Fixes
npm run fix:nexus:deps         # Fix any app's Nexus dependencies
npm run fix:nexus:deps:root    # Fix root app Nexus dependencies
npm run fix:nexus:deps:all     # Fix all apps' Nexus dependencies
```

### Manual Fix Scripts
```bash
# Linux/Mac
bash ./scripts/fix-npm-deps.sh [app-directory]
bash ./scripts/fix-nexus-deps.sh [app-directory]

# Windows
scripts\fix-npm-deps.bat [app-directory]
scripts\fix-nexus-deps.bat [app-directory]
```

### Registry Management
```bash
# Registry switching
npm run registry:npm          # Switch to NPM registry
npm run registry:nexus        # Switch to Nexus registry
npm run registry:status       # Check current registry
npm run registry:restore      # Restore original registry
```

### Authentication Testing
```bash
# Test registry authentication
npm run test:npm:auth         # Test NPM authentication
npm run test:nexus:auth       # Test Nexus authentication
```

## How Fix Scripts Work

### Auto-Fix Script Workflow
```bash
npm run fix:auto
```

**Process:**
1. **Mode Detection**: Auto-detects current deployment mode
2. **Registry Check**: Verifies current NPM registry configuration
3. **Package Existence**: Checks if packages exist in target registry
4. **Version Comparison**: Compares local vs registry versions
5. **Missing Package Handling**: Publishes missing packages automatically
6. **Dependency Resolution**: Updates package.json with correct versions
7. **Installation**: Installs dependencies with proper authentication
8. **Verification**: Confirms all packages are properly installed

### NPM Fix Script Workflow
```bash
npm run fix:npm:deps:root
```

**Process:**
1. **Registry Switch**: Switches to NPM registry (removes custom .npmrc)
2. **Authentication**: Uses NPM_TOKEN or npm login credentials
3. **Version Check**: Checks latest available version in NPM registry using `--registry` flag
4. **Package Update**: Updates package.json dependencies to exact version
5. **Cache Clear**: Clears NPM cache to prevent stale data
6. **Installation**: Installs dependencies from NPM registry
7. **Verification**: Confirms successful installation

### Nexus Fix Script Workflow
```bash
npm run fix:nexus:deps:root
```

**Process:**
1. **Registry Config**: Copies Nexus registry config (.npmrc.nexus → .npmrc)
2. **Authentication**: Uses Nexus credentials from .npmrc.nexus
3. **Version Check**: Checks latest available version in Nexus registry
4. **Package Update**: Updates package.json dependencies to exact version
5. **Installation**: Installs dependencies using Nexus authentication
6. **Verification**: Confirms successful installation from Nexus

### GitHub/AWS Fix Scripts
```bash
npm run fix:auto:github
npm run fix:auto:aws
```

**Process:**
1. **Deployment Check**: Verifies deployed versions on GitHub Pages/AWS S3
2. **Local Comparison**: Compares local versions with deployed versions
3. **Rebuild**: Rebuilds applications if version mismatches found
4. **Redeploy**: Redeploys to external services if needed
5. **Import Map Update**: Updates import maps with correct versions

## Prevention Tips

### Before Switching Modes
1. **Check current versions:** `npm run version:current`
2. **Check registry status:** `npm run check:npm` or `npm run check:nexus`
3. **Publish if needed:** `npm run publish:npm:nobump` or `npm run publish:nexus:nobump`

### Version Management Best Practices
```bash
# Set specific version for controlled releases
npm run version:set 1.0.0
npm run publish:nexus:nobump

# Or use auto-bumping for development
npm run publish:nexus:patch  # 1.0.0 → 1.0.1
```

### Registry Switching Best Practices
```bash
# Always use fix scripts when switching registries
npm run fix:npm:deps:root     # Before NPM mode
npm run fix:nexus:deps:root   # Before Nexus mode

# Or use auto-fix for any mode
npm run fix:auto
```

### Deployment Best Practices
```bash
# Test locally before deploying
./run.sh local prod

# Use production mode for deployments
./run.sh github prod
./run.sh aws prod

# Verify deployments
npm run check:github
npm run check:aws
```

## Troubleshooting

### "Cannot find module" Error (Runtime)
```bash
# Auto-fix for runtime module loading errors
npm run fix:auto

# Or target specific mode
npm run fix:auto:nexus    # For Nexus mode
npm run fix:auto:npm      # For NPM mode
npm run fix:auto:github   # For GitHub mode
npm run fix:auto:aws      # For AWS mode
```

### "No matching version found" Error (Install)
```bash
# Quick fix - let script handle it
npm run fix:npm:deps:root
# or
npm run fix:nexus:deps:root
# or
npm run fix:auto
```

### "Package not found" Error
```bash
# Publish packages first
npm run publish:npm:prod      # For NPM
npm run publish:nexus:prod    # For Nexus

# Or use auto-fix to publish automatically
npm run fix:auto:npm
npm run fix:auto:nexus
```

### Authentication Errors
```bash
# Test authentication
npm run test:npm:auth         # For NPM
npm run test:nexus:auth       # For Nexus

# Fix NPM authentication
export NPM_TOKEN=npm_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
npm login

# Fix Nexus authentication
# Edit .npmrc.nexus with correct credentials
```

### Registry Configuration Issues
```bash
# Check current registry
npm run registry:status

# Switch registries
npm run registry:npm          # Switch to NPM
npm run registry:nexus        # Switch to Nexus
npm run registry:restore      # Restore original

# Force registry for specific commands
npm install --registry https://registry.npmjs.org/
```

### Cross-Registry Contamination
```bash
# Problem: Getting wrong versions from wrong registry
# Solution: Force correct registry in fix scripts

# NPM fix forces NPM registry
npm run fix:npm:deps:root

# Nexus fix forces Nexus registry  
npm run fix:nexus:deps:root
```

### Deployment Sync Issues
```bash
# Problem: Local and deployed versions out of sync
# Solution: Redeploy with current version

./run.sh github prod    # Redeploy to GitHub
./run.sh aws prod       # Redeploy to AWS

# Or use auto-fix
npm run fix:auto:github
npm run fix:auto:aws
```

## Complete Workflow Examples

### Switching from Local to NPM Mode
```bash
# Current: Local development (1.0.0)
# Target: NPM mode (0.1.4 available)

# Option 1: Auto-fix (Recommended)
npm run fix:auto:npm
./run.sh npm dev

# Option 2: Manual fix
npm run fix:npm:deps:root
./run.sh npm dev

# Option 3: Publish current version
npm run publish:npm:nobump
./run.sh npm dev
```

### Switching from NPM to Nexus Mode
```bash
# Current: NPM mode (0.1.4)
# Target: Nexus mode (1.0.0 available)

# Option 1: Auto-fix (Recommended)
npm run fix:auto:nexus
./run.sh nexus dev

# Option 2: Manual fix
npm run fix:nexus:deps:root
./run.sh nexus dev

# Option 3: Align versions
npm run version:set 1.0.0
./run.sh nexus dev
```

### Switching to GitHub Pages Mode
```bash
# Current: Local development
# Target: GitHub Pages deployment

# Development mode (read existing)
npm run fix:auto:github
./run.sh github dev

# Production mode (create and deploy)
./run.sh github prod  # Handles fixes automatically
```

### Switching to AWS S3 Mode
```bash
# Current: Local development
# Target: AWS S3 deployment

# Development mode (use existing)
npm run fix:auto:aws
./run.sh aws dev

# Production mode (build and deploy)
./run.sh aws prod     # Handles fixes automatically
```

### Publishing New Version to All Modes
```bash
# Set desired version
npm run version:set 2.0.0

# Publish to registries
npm run publish:npm:nobump
npm run publish:nexus:nobump

# Deploy to external services
./run.sh github prod
./run.sh aws prod

# Now all modes work with 2.0.0
./run.sh local dev    # Uses local 2.0.0
./run.sh npm dev      # Uses NPM 2.0.0
./run.sh nexus dev    # Uses Nexus 2.0.0
./run.sh github dev   # Uses GitHub 2.0.0
./run.sh aws dev      # Uses AWS 2.0.0
```

### Emergency Hotfix Workflow
```bash
# 1. Fix critical issue locally
# ... make fixes ...

# 2. Bump patch version
npm run version:bump:patch

# 3. Quick deploy to production
npm run publish:npm:nobump
./run.sh aws prod

# 4. Update other modes
npm run publish:nexus:nobump
./run.sh github prod

# 5. Verify all modes work
npm run check:npm
npm run check:nexus
npm run check:github
npm run check:aws
```

### Complete Mode Testing Workflow
```bash
# Test all modes work with current version
for mode in local npm nexus github aws; do
  echo "Testing $mode mode..."
  npm run fix:auto:$mode 2>/dev/null || npm run fix:auto
  ./run.sh $mode dev
  # Manual testing here
  # Stop servers before next iteration
done
```

## Advanced Troubleshooting

### Debug Mode
```bash
# Enable debug logging for fix scripts
DEBUG=fix:* npm run fix:auto

# Verbose npm logging
npm config set loglevel verbose
npm run fix:npm:deps:root
```

### Manual Registry Inspection
```bash
# Check what's actually in registries
npm view @cesarchamal/single-spa-auth-app versions --json
npm view @cesarchamal/single-spa-auth-app versions --registry http://localhost:8081/repository/npm-group/

# Check current package.json dependencies
cat single-spa-root/package.json | grep "@cesarchamal"
```

### Cache Issues
```bash
# Clear all caches
npm cache clean --force
rm -rf node_modules package-lock.json
npm install

# Clear registry-specific caches
npm cache clean --force --registry https://registry.npmjs.org/
```

### Network Issues
```bash
# Apply network fixes before dependency fixes
./run.sh local dev --fix-network

# Manual network configuration
npm config set timeout 60000
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000
```

## Integration with Launcher Scripts

### Automatic Fixes in Launchers
```bash
# Launcher scripts automatically run fixes
./run.sh npm dev      # Includes npm dependency fixes
./run.sh nexus dev    # Includes nexus dependency fixes
./run.sh github prod  # Includes deployment fixes
./run.sh aws prod     # Includes deployment fixes
```

### Manual Fixes Before Launching
```bash
# Run fixes manually before launcher
npm run fix:auto:npm
./run.sh npm dev --skip-fixes

# Or use auto-fix
npm run fix:auto
./run.sh [mode] dev
```

## Best Practices Summary

### Daily Development
1. Use `./run.sh local dev` for daily work
2. Run `npm run fix:auto` when switching modes
3. Use `npm run version:current` to check versions
4. Test mode switches before important deployments

### Before Deployment
1. Test locally: `./run.sh local prod`
2. Fix dependencies: `npm run fix:auto`
3. Verify versions: `npm run version:current`
4. Deploy: `./run.sh [mode] prod`

### After Issues
1. Run auto-fix: `npm run fix:auto`
2. Check status: `npm run check:[mode]`
3. Verify functionality: Test application manually
4. Document issues for future reference

### Version Management
1. Keep versions synchronized: `npm run version:set X.Y.Z`
2. Publish to all registries: `npm run publish:all:nobump`
3. Deploy to all services: `./run.sh github prod && ./run.sh aws prod`
4. Verify all modes work: `npm run check:all`