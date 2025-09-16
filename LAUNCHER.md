# Launcher Scripts Guide

This guide covers the launcher scripts for running the microfrontend application in different modes and environments.

## Available Launchers

### 1. Enhanced Mode-Aware Launcher (`run.sh` / `run.bat`)

**Primary launcher** with full configuration options and setup capabilities.

#### Basic Usage
```bash
# Linux/Mac
./run.sh [mode] [environment] [--clean] [--fix-network]

# Windows
run.bat [mode] [environment] [--clean] [--fix-network]
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

#### Examples
```bash
# Development (default)
./run.sh local dev
./run.sh local        # dev is default

# With cleanup and network fixes
./run.sh local dev --clean --fix-network
./run.sh npm prod --clean
./run.sh aws dev --fix-network

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
```

### 2. Quick Development Launcher (`dev-all.sh` / `dev-all.bat`)

**Always launches all applications** for immediate development without configuration.

```bash
# Windows
dev-all.bat

# Linux/Mac
./dev-all.sh
```

**Features:**
- Starts all 12 microfrontends simultaneously
- Uses local development mode
- No configuration required
- Fastest way to start development

## Launcher Features

### Automatic Setup
- **Dependency Installation**: Installs missing dependencies
- **Build Process**: Builds applications as needed
- **Registry Configuration**: Switches NPM registries automatically
- **Version Fixes**: Resolves version mismatches between registries
- **Network Configuration**: Applies network fixes for unstable connections

### Mode-Specific Behavior

#### Local Mode
```bash
./run.sh local dev
```
- Starts all 12 development servers (ports 4201-4211)
- Uses SystemJS for module loading
- Hot reload enabled
- No external dependencies

#### NPM Mode
```bash
./run.sh npm dev
```
- Switches to NPM registry
- Fixes dependency versions automatically
- Uses published NPM packages via unpkg CDN
- Builds and publishes if packages missing

#### Nexus Mode
```bash
./run.sh nexus dev
```
- Switches to Nexus private registry
- Configures authentication from `.npmrc.nexus`
- Fixes dependency versions for Nexus
- Uses private registry packages

#### GitHub Mode
```bash
./run.sh github dev   # Development: read existing repos
./run.sh github prod  # Production: create repos + deploy
```
- **Dev Environment**: Reads from existing GitHub Pages
- **Prod Environment**: Creates repositories and deploys everything
- Requires `GITHUB_TOKEN` and `GITHUB_USERNAME` environment variables

#### AWS Mode
```bash
./run.sh aws dev
./run.sh aws prod
```
- Uses AWS S3 static website hosting
- Loads applications via import map
- Requires `S3_BUCKET`, `AWS_REGION`, and `ORG_NAME` environment variables

### Environment-Specific Features

#### Development Environment (`dev`)
- Hot reload enabled
- Source maps included
- Development optimizations
- Console logging enabled
- Fast build times

#### Production Environment (`prod`)
- Minified bundles
- Optimized for performance
- Source maps excluded
- Production-ready builds
- Smaller bundle sizes

## Advanced Options

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
```
Applies both cleanup and network fixes for maximum reliability.

## Launcher Workflow

### Standard Workflow
1. **Parameter Parsing**: Processes mode, environment, and options
2. **Environment Setup**: Configures Node.js compatibility (OpenSSL)
3. **Dependency Check**: Installs missing dependencies if needed
4. **Registry Configuration**: Switches to appropriate NPM registry
5. **Version Fixes**: Resolves version mismatches automatically
6. **Build Process**: Builds applications for target environment
7. **Server Startup**: Starts development servers or serves built files
8. **Status Report**: Shows running servers and access URLs

### Error Handling
- **Automatic Retry**: Retries failed operations with different configurations
- **Fallback Modes**: Falls back to local mode if external modes fail
- **Dependency Fixes**: Automatically resolves common dependency issues
- **Network Resilience**: Applies network fixes automatically when needed

## Stopping Applications

### Manual Stop
```bash
# Kill all Node.js processes (use with caution)
pkill -f node

# Windows
taskkill /f /im node.exe
```

### Graceful Stop
```bash
# Use Ctrl+C in the terminal running the launcher
# This stops all spawned processes gracefully
```

## Troubleshooting

### Common Issues

#### Port Conflicts
```bash
# Check what's using ports 4201-4211 and 8080
netstat -tulpn | grep :4201
netstat -tulpn | grep :8080

# Kill specific processes
kill -9 $(lsof -t -i:4201)
```

#### Permission Errors
```bash
# Make scripts executable (Linux/Mac)
chmod +x run.sh dev-all.sh

# Run as administrator (Windows)
# Right-click → "Run as administrator"
```

#### Node.js Version Issues
```bash
# Check Node.js version (requires v18+)
node --version

# Update Node.js if needed
# Use nvm, n, or download from nodejs.org
```

#### Registry Authentication
```bash
# Test NPM authentication
npm run test:npm:auth

# Test Nexus authentication
npm run test:nexus:auth
```

### Debug Mode
```bash
# Enable debug logging
DEBUG=single-spa:* ./run.sh local dev

# Verbose npm logging
npm config set loglevel verbose
./run.sh npm dev
```

### Recovery Commands
```bash
# Reset everything to clean state
./run.sh local dev --clean --fix-network

# Force local mode if other modes fail
npm run mode:local
./run.sh local dev
```

## Performance Tips

### Faster Startup
```bash
# Use quick launcher for development
./dev-all.sh

# Skip cleanup unless needed
./run.sh local dev  # Instead of --clean
```

### Memory Optimization
```bash
# Increase Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=4096"
./run.sh local dev
```

### Build Optimization
```bash
# Use production builds for better performance
./run.sh local prod

# Parallel builds (handled automatically)
# Launcher builds multiple apps simultaneously
```

## Integration with Other Tools

### Hot Reload Sync
```bash
# Terminal 1: Start application
./run.sh aws dev

# Terminal 2: Start hot sync
npm run aws:hot-sync
```

### CI/CD Integration
```bash
# Production deployment
./run.sh github prod  # Creates and deploys everything
./run.sh aws prod     # Builds and uploads to S3
```

### Development Workflow
```bash
# Daily development
./dev-all.sh          # Quick start

# Testing different modes
./run.sh npm dev      # Test NPM packages
./run.sh nexus dev    # Test private registry
./run.sh github dev   # Test GitHub Pages
```

## Best Practices

### Development
- Use `./dev-all.sh` for daily development
- Use `./run.sh local dev` when you need specific configuration
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
- Check logs in terminal for specific error messages
- Use debug mode for detailed troubleshooting
- Verify environment variables for external modes