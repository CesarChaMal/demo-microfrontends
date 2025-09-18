# Launcher Scripts Guide

This guide covers the launcher scripts for running the microfrontend application in different modes and environments.

## Available Launchers

### Enhanced Mode-Aware Launcher (`run.sh` / `run.bat`)

**Primary launcher** with full configuration options and setup capabilities.

#### Basic Usage
```bash
# Linux/Mac
./run.sh [mode] [environment] [--clean] [--fix-network] [--skip-install] [--skip-build] [--offline]

# Windows
run.bat [mode] [environment] [--clean] [--fix-network] [--skip-install] [--skip-build] [--offline]
```

#### Parameters

**Mode** (first parameter):
- `local` (default) - Local development with SystemJS
- `npm` - Uses NPM packages directly
- `nexus` - Uses Nexus private registry packages
- `github` - Loads from GitHub Pages
- `aws` - Loads from AWS S3 using import map

**Environment** (second parameter):
- `dev` (default) - Development build with hot reload
- `prod` - Production build with optimizations

**Options**:
- `--clean` - Cleanup node_modules and package-lock.json (default: off)
- `--fix-network` - Configure npm for problematic networks (default: off)
- `--skip-install` - Skip npm install/ci for faster restarts (default: off)
- `--skip-build` - Skip build process for faster restarts (default: off)
- `--offline` - Use local dependencies instead of CDN (local/nexus only, default: off)

#### Examples
```bash
# Development (default)
./run.sh local dev
./run.sh local        # dev is default

# With cleanup and network fixes
./run.sh local dev --clean --fix-network
./run.sh npm prod --clean
./run.sh aws dev --fix-network

# Fast restarts (skip install/build)
./run.sh local prod --skip-install --skip-build
./run.sh npm dev --skip-install

# Offline mode (no internet required)
./run.sh local prod --offline
./run.sh nexus dev --offline

# GitHub modes
./run.sh github dev   # Read from existing GitHub Pages
./run.sh github prod  # Create repos + deploy everything

# Production builds
./run.sh local prod   # Local production build
./run.sh npm prod     # NPM production build
./run.sh aws prod     # AWS S3 production build

# Windows examples
run.bat local prod --clean
run.bat npm dev --fix-network
run.bat aws prod --clean --fix-network
run.bat local prod --offline
run.bat nexus dev --skip-install --skip-build
```



## Advanced Options

### Skip Options for Faster Development

#### Skip Install (`--skip-install`)
```bash
./run.sh local prod --skip-install
```
**What it does:**
- Skips npm install/ci for main package and microfrontends
- Uses existing node_modules directories
- Significantly faster startup times

**When to use:**
- Dependencies haven't changed since last run
- Quick restarts during development
- Same mode as previous run

#### Skip Build (`--skip-build`)
```bash
./run.sh local prod --skip-build
```
**What it does:**
- Skips build process for all applications
- Uses existing built files in dist directories
- Fastest possible startup

**When to use:**
- Code hasn't changed since last build
- Testing configuration changes only
- Same mode and environment as previous run

#### Combined Skip Options
```bash
./run.sh local prod --skip-install --skip-build
```
**Sequential Workflow Example:**
```bash
./run.sh local prod                              # Run 1: Full setup
./run.sh local prod --skip-install --skip-build  # Run 2: Fast restart
./run.sh aws prod --skip-install                 # Run 3: Mode change (auto-rebuilds)
```

### Offline Mode (`--offline`)
```bash
./run.sh local prod --offline
./run.sh nexus dev --offline
```
**What it does:**
- Downloads CDN dependencies locally (one-time setup)
- Uses local dependencies instead of internet CDN
- Works without internet connection

**Supported modes:** local, nexus only

**Setup:**
```bash
# First time setup (downloads dependencies)
npm run offline:setup

# Then run offline
./run.sh local prod --offline
```

### Cleanup Option (`--clean`)
```bash
./run.sh local dev --clean
```
**What it does:**
- Removes all `node_modules` directories
- Deletes all `package-lock.json` files
- Forces fresh dependency installation
- Resolves dependency conflicts

**When to use:**
- After switching Node.js versions
- When experiencing dependency conflicts
- After long periods without development
- When packages seem corrupted

### Network Fix Option (`--fix-network`)
```bash
./run.sh npm prod --fix-network
```
**What it does:**
- Increases npm timeout settings
- Configures retry logic for failed downloads
- Sets up proxy-friendly configurations
- Applies network stability fixes

**When to use:**
- Experiencing ECONNRESET errors
- Behind corporate firewalls
- On unstable network connections
- When npm install frequently fails

### Combined Options
```bash
./run.sh aws prod --clean --fix-network
./run.sh local prod --skip-install --skip-build --offline
```

## Offline Mode Setup

### Initial Setup
```bash
# Download all CDN dependencies locally (one-time)
npm run offline:setup

# Or manually
bash ./scripts/download-offline-deps.sh
```

### Usage
```bash
# Run without internet
./run.sh local prod --offline
./run.sh nexus dev --offline

# Quick offline development
npm run offline:serve
```

### What Gets Downloaded
- SystemJS
- Single-SPA
- Bootstrap CSS/JS
- Bootstrap Vue
- jQuery
- Vue.js and Vue Router
- All framework dependencies

### File Structure
```
single-spa-root/dist/lib/
├── systemjs@6.14.1/dist/system.min.js
├── single-spa@5.9.0/lib/system/single-spa.min.js
├── bootstrap@4.6.0/dist/css/bootstrap.min.css
├── vue@2.6.11/dist/vue.js
└── ... (all other dependencies)
```

## Mode-Specific Behavior

### Local Mode
```bash
./run.sh local dev
```
- Starts all 12 development servers (ports 4201-4211)
- Uses SystemJS for module loading
- Hot reload enabled
- No external dependencies
- Supports offline mode

### NPM Mode
```bash
./run.sh npm dev
```
- Switches to NPM registry
- Fixes dependency versions automatically
- Uses published NPM packages via unpkg CDN
- Builds and publishes if packages missing

### Nexus Mode
```bash
./run.sh nexus dev
```
- Switches to Nexus private registry
- Configures authentication from `.npmrc.nexus`
- Fixes dependency versions for Nexus
- Uses private registry packages
- Supports offline mode

### GitHub Mode
```bash
./run.sh github dev   # Development: read existing repos
./run.sh github prod  # Production: create repos + deploy
```
- **Dev Environment**: Reads from existing GitHub Pages
- **Prod Environment**: Creates repositories and deploys everything
- Requires `GITHUB_TOKEN` and `GITHUB_USERNAME` environment variables

### AWS Mode
```bash
./run.sh aws dev
./run.sh aws prod
```
- Uses AWS S3 static website hosting
- Loads applications via import map
- Requires `S3_BUCKET`, `AWS_REGION`, and `ORG_NAME` environment variables

## Launcher Workflow

### Standard Workflow
1. **Parameter Parsing**: Processes mode, environment, and options
2. **Mode Change Detection**: Checks if rebuild needed when switching modes
3. **Environment Setup**: Configures Node.js compatibility (OpenSSL)
4. **Offline Setup**: Downloads local dependencies if --offline enabled
5. **Dependency Check**: Installs missing dependencies (unless --skip-install)
6. **Registry Configuration**: Switches to appropriate NPM registry
7. **Version Fixes**: Resolves version mismatches automatically
8. **Build Process**: Builds applications for target environment (unless --skip-build)
9. **Server Startup**: Starts development servers or serves built files
10. **Status Report**: Shows running servers and access URLs

### Error Handling
- **Automatic Retry**: Retries failed operations with different configurations
- **Fallback Modes**: Falls back to local mode if external modes fail
- **Dependency Fixes**: Automatically resolves common dependency issues
- **Network Resilience**: Applies network fixes automatically when needed

## Performance Tips

### Faster Startup
```bash
# Skip unnecessary steps
./run.sh local dev --skip-install --skip-build

# Offline mode for no internet
./run.sh local prod --offline

# Skip cleanup unless needed
./run.sh local dev  # Instead of --clean
```

### Memory Optimization
```bash
# Increase Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=4096"
./run.sh local dev
```

## Best Practices

### Development
- Use `./run.sh local dev` for daily development
- Use `--skip-install --skip-build` for fast restarts
- Use `--offline` when working without internet
- Apply `--clean` after major changes or when switching Node versions

### Testing
- Test each mode before deployment: `./run.sh [mode] dev`
- Use production builds for performance testing: `./run.sh [mode] prod`
- Verify external modes work: `npm run check:[mode]`

### Deployment
- Always use production environment for deployment: `./run.sh [mode] prod`
- Test locally before deploying: `./run.sh local prod`
- Use appropriate mode for target environment

### Troubleshooting
- Start with `--clean --fix-network` for persistent issues
- Try `--skip-install --skip-build` if only testing configuration
- Use `--offline` if experiencing network issues
- Check logs in terminal for specific error messages
- Use debug mode for detailed troubleshooting