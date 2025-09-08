# Dependency Version Fixes

This guide helps resolve version mismatches when switching between NPM and Nexus registries.

## Problem

When switching between deployment modes, you may encounter version mismatches:
- Local version: 1.0.0
- NPM registry: 0.1.4  
- Nexus registry: 1.0.0

This causes `npm install` to fail with "No matching version found" errors.

## Quick Fixes

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

## Available Fix Scripts

### Auto-Fix (Recommended)
- `npm run fix:auto` - Auto-detect mode and fix dependencies
- `npm run fix:auto:npm` - Auto-fix for NPM mode
- `npm run fix:auto:nexus` - Auto-fix for Nexus mode

### NPM Fixes
- `npm run fix:npm:deps` - Fix any app's NPM dependencies
- `npm run fix:npm:deps:root` - Fix root app NPM dependencies

### Nexus Fixes  
- `npm run fix:nexus:deps` - Fix any app's Nexus dependencies
- `npm run fix:nexus:deps:root` - Fix root app Nexus dependencies

### Manual Scripts
- `bash ./scripts/fix-npm-deps.sh [app-directory]`
- `bash ./scripts/fix-nexus-deps.sh [app-directory]`
- `scripts\fix-npm-deps.bat [app-directory]` (Windows)
- `scripts\fix-nexus-deps.bat [app-directory]` (Windows)

## What the Fix Scripts Do

### NPM Fix Script
1. Switches to NPM registry (removes custom .npmrc)
2. Checks latest available version in NPM registry
3. Updates package.json dependencies to exact version
4. Clears NPM cache and installs dependencies

### Nexus Fix Script  
1. Copies Nexus registry config (.npmrc.nexus → .npmrc)
2. Checks latest available version in Nexus registry
3. Updates package.json dependencies to exact version
4. Installs dependencies using Nexus authentication

### Auto-Fix Script
1. **Auto-detects current mode** from registry configuration
2. **Checks if packages exist** in target registry
3. **Publishes missing packages** using current version (nobump)
4. **Fixes dependencies** automatically using appropriate fix script
5. **Provides next steps** for running the application

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

### Registry Switching
```bash
# Always use fix scripts when switching registries
npm run fix:npm:deps:root     # Before NPM mode
npm run fix:nexus:deps:root   # Before Nexus mode
```

## Troubleshooting

### "Cannot find module" Error (Runtime)
```bash
# Auto-fix for runtime module loading errors
npm run fix:auto

# Or target specific mode
npm run fix:auto:nexus    # For Nexus mode
npm run fix:auto:npm      # For NPM mode
```

### "No matching version found" Error (Install)
```bash
# Quick fix - let script handle it
npm run fix:npm:deps:root
# or
npm run fix:nexus:deps:root
```

### "Package not found" Error
```bash
# Publish packages first
npm run publish:npm:prod      # For NPM
npm run publish:nexus:prod    # For Nexus
```

### Authentication Errors
```bash
# Test authentication
npm run test:npm:auth         # For NPM
npm run test:nexus:auth       # For Nexus
```

### Registry Configuration Issues
```bash
# Check current registry
npm run registry:status

# Switch registries
npm run registry:npm          # Switch to NPM
npm run registry:nexus        # Switch to Nexus
npm run registry:restore      # Restore original
```

## Example Workflows

### Switching from Local to NPM
```bash
# Current: Local development (1.0.0)
# Target: NPM mode (0.1.4 available)

npm run fix:npm:deps:root
./run.sh npm dev
```

### Switching from NPM to Nexus  
```bash
# Current: NPM mode (0.1.4)
# Target: Nexus mode (1.0.0 available)

npm run fix:nexus:deps:root
./run.sh nexus dev
```

### Publishing New Version
```bash
# Set desired version
npm run version:set 2.0.0

# Publish to both registries
npm run publish:npm:nobump
npm run publish:nexus:nobump

# Now both modes work with 2.0.0
./run.sh npm dev      # Uses NPM 2.0.0
./run.sh nexus dev    # Uses Nexus 2.0.0
```