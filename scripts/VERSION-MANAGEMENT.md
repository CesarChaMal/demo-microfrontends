# Version Management System

This project uses a centralized version management system to keep all packages synchronized.

## 📦 Package Structure

All packages share the same version number:
- **Main Package**: `demo-microfrontends`
- **Root App**: `@cesarchamal/single-spa-root`
- **11 Microfrontends**: `@cesarchamal/single-spa-*-app`

## 🛠 Version Manager Commands

### Basic Usage

```bash
# Show current versions
npm run version:current
node version-manager.js current

# Bump patch version (0.1.0 → 0.1.1)
npm run version:bump:patch
node version-manager.js bump patch

# Bump minor version (0.1.0 → 0.2.0)
npm run version:bump:minor
node version-manager.js bump minor

# Bump major version (0.1.0 → 1.0.0)
npm run version:bump:major
node version-manager.js bump major

# Set specific version
npm run version:set 1.2.3
node version-manager.js set 1.2.3

# Clean _trigger fields (if any)
npm run version:clean
node version-manager.js clean
```

### Windows Commands

```cmd
REM Show current versions
version-manager.bat current

REM Bump versions
version-manager.bat bump patch
version-manager.bat bump minor
version-manager.bat bump major

REM Set specific version
version-manager.bat set 1.2.3

REM Clean _trigger fields
version-manager.bat clean
```

## 🚀 Publishing with Version Management

The publishing scripts automatically handle version management:

```bash
# NPM Registry Publishing
npm run publish:npm:patch    # Patch version to NPM
npm run publish:npm:minor    # Minor version to NPM
npm run publish:npm:major    # Major version to NPM
./scripts/publish-npm.sh patch

# Nexus Registry Publishing
npm run publish:nexus:patch  # Patch version to Nexus
npm run publish:nexus:minor  # Minor version to Nexus
npm run publish:nexus:major  # Major version to Nexus
./scripts/publish-nexus.sh patch

# Windows
scripts\publish-npm.bat patch
scripts\publish-nexus.bat patch

# Backward-compatible aliases (default to NPM)
npm run publish:patch        # Alias for publish:npm:patch
npm run publish:minor        # Alias for publish:npm:minor
npm run publish:major        # Alias for publish:npm:major
```

## 🔄 How It Works

1. **Centralized Version**: All packages use the same version from the main `package.json`
2. **Automatic Sync**: Version manager updates all packages simultaneously
3. **Dependency Updates**: Cross-package dependencies are automatically updated
4. **Clean Fields**: Removes any `_trigger` fields during updates

## 📋 What Gets Updated

When you run version management:

### ✅ Version Field
```json
{
  "version": "0.1.1"  // Updated in all packages
}
```

### ✅ Dependencies
```json
{
  "dependencies": {
    "@cesarchamal/single-spa-auth-app": "^0.1.1",  // Auto-updated
    "@cesarchamal/single-spa-layout-app": "^0.1.1" // Auto-updated
  }
}
```

### ✅ Cleanup
```json
{
  // "_trigger": "1756836062"  // Removed if present
}
```

## 🎯 Publishing Workflow

### 1. Development
```bash
# Work on your changes
git add .
git commit -m "feat: add new feature"
```

### 2. Version & Publish
```bash
# NPM Registry (all in one)
npm run publish:npm:patch

# Nexus Registry (all in one)
npm run publish:nexus:patch

# Backward-compatible (defaults to NPM)
npm run publish:patch

# Or step by step
npm run version:bump:patch
npm run publish:npm  # or publish:nexus
```

### 3. Git Tagging (Optional)
```bash
# Tag the release
git tag v$(node -e "console.log(require('./package.json').version)")
git push origin --tags
```

## 🔍 Verification

Check that all packages have the same version:

```bash
npm run version:current
```

Expected output:
```
📋 Current version: 0.1.1

📦 Package versions:
  demo-microfrontends: 0.1.1
  @cesarchamal/single-spa-root: 0.1.1
  @cesarchamal/single-spa-auth-app: 0.1.1
  @cesarchamal/single-spa-layout-app: 0.1.1
  ... (all packages show same version)
```

## 🚨 Important Notes

- **Always use the version manager** - Don't manually edit version numbers
- **All packages stay synchronized** - No individual versioning
- **Dependencies auto-update** - Cross-references are maintained
- **Clean builds recommended** - Run `npm run clean` if issues occur

## 🛠 Troubleshooting

### Version Mismatch
```bash
# Reset all versions to match main package
npm run version:set $(node -e "console.log(require('./package.json').version)")
```

### Publishing Failures
```bash
# Check NPM authentication
npm whoami

# Dry run to test
cd single-spa-auth-app
npm publish --dry-run
```

### Build Issues
```bash
# Clean and rebuild
npm run clean
npm run install:all
npm run build:prod
```