# NPM Install Troubleshooting Guide

## Common Issues and Solutions

### 1. ECONNRESET Network Errors

**Symptoms:**
- `npm ERR! code ECONNRESET`
- `npm ERR! syscall read`
- `npm ERR! errno -4077`
- `npm ERR! network read ECONNRESET`

**Root Causes:**
- Network instability or timeouts
- Corporate firewall/proxy blocking connections
- npm registry connection limits
- Large dependency trees causing long downloads

**Solution (Step-by-step):**

```bash
# 1. Configure npm timeouts and retry settings
npm config set audit false
npm config set fund false
npm config set fetch-timeout 600000
npm config set fetch-retries 5
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000

# 2. Clean cache and remove existing files
npm cache clean --force
rm -rf node_modules package-lock.json

# 3. Install with extended timeout and verbose logging
npm install --no-audit --no-fund --fetch-timeout=600000 --verbose
```

### 2. Invalid Version Errors

**Symptoms:**
- `TypeError: Invalid Version:`
- Errors in `semver` package during dependency resolution

**Solution:**
```bash
# Remove problematic packages from package.json
# Common culprits: babel-eslint@10.0.3, react-scripts@4.0.0

# Use compatible versions:
# babel-eslint: Remove entirely or use @10.0.1
# react-scripts: Use @3.4.4 instead of @4.0.0
```

### 3. Dependency Version Conflicts

**Symptoms:**
- `ERESOLVE` errors
- Peer dependency warnings
- Version mismatch errors

**Solution:**
```bash
# Use --force to override dependency conflicts
npm install --force --no-audit

# Or use --legacy-peer-deps for older projects
npm install --legacy-peer-deps --no-audit
```

### 4. npm ci Fallback Strategy

**For production environments:**
```bash
# Try npm ci first (faster, deterministic)
if [ -f "package-lock.json" ]; then
    npm ci || {
        echo "npm ci failed, falling back to npm install..."
        npm install
    }
else
    echo "No package-lock.json found, using npm install..."
    npm install
fi
```

### 5. Alternative Solutions

**Use Yarn (often more reliable):**
```bash
npm install -g yarn
yarn install --network-timeout 300000
```

**Use different registry:**
```bash
npm install --registry https://registry.npmmirror.com
```

**Limit concurrent connections:**
```bash
npm install --maxsockets 1 --force --no-audit
```

**Install in batches:**
```bash
npm install react react-dom --force --no-audit
npm install webpack webpack-cli --force --no-audit
npm install --force --no-audit
```

## Configuration Summary

**Recommended npm configuration for problematic networks:**
```bash
npm config set audit false
npm config set fund false
npm config set fetch-timeout 600000
npm config set fetch-retries 5
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000
```

**Check current configuration:**
```bash
npm config list
```

**Reset to defaults:**
```bash
npm config delete audit
npm config delete fund
npm config delete fetch-timeout
npm config delete fetch-retries
npm config delete fetch-retry-mintimeout
npm config delete fetch-retry-maxtimeout
```

## OpenSSL Compatibility Issues

**Symptoms:**
- `error:0308010C:digital envelope routines::unsupported`
- Build failures with Node.js 18+ and older Webpack versions
- OpenSSL 3.0 compatibility errors

**Root Cause:**
- Node.js 18+ uses OpenSSL 3.0 which removed legacy algorithms
- Older Webpack versions (4.x) rely on deprecated MD4 hash algorithm
- Windows Git Bash may restrict NODE_OPTIONS environment variable

**Automatic Solution (Launcher Scripts):**
The `run.sh` and `run.bat` scripts automatically handle OpenSSL compatibility:

```bash
# Linux/macOS/WSL - Sets NODE_OPTIONS globally
export NODE_OPTIONS="--openssl-legacy-provider"

# Windows Git Bash - Attempts NODE_OPTIONS with fallback
NODE_OPTIONS="--openssl-legacy-provider" npm run build 2>/dev/null || npm run build
```

**Manual Solution:**
```bash
# Set environment variable before build commands
export NODE_OPTIONS="--openssl-legacy-provider"
npm run build

# Or inline for single command
NODE_OPTIONS="--openssl-legacy-provider" npm run build

# Windows Command Prompt
set NODE_OPTIONS=--openssl-legacy-provider && npm run build

# Windows PowerShell
$env:NODE_OPTIONS="--openssl-legacy-provider"; npm run build
```

**Script Function Differences:**

| Function | Purpose | Windows Behavior | Linux/macOS Behavior |
|----------|---------|------------------|----------------------|
| `exec_npm()` | General npm commands | Skips NODE_OPTIONS | Sets NODE_OPTIONS globally |
| `exec_build()` | Build-specific commands | Attempts NODE_OPTIONS with fallback | Sets NODE_OPTIONS globally |

**exec_npm() vs exec_build():**
- **exec_npm()**: Used for `npm install`, `npm ci`, general npm operations
- **exec_build()**: Used for `npm run build`, build-specific commands with aggressive OpenSSL compatibility
- **Fallback Strategy**: `exec_build()` tries NODE_OPTIONS first, falls back to direct execution if restricted

## Network Diagnostics

**Test registry connectivity:**
```bash
curl -I https://registry.npmjs.org
curl -I https://registry.npmmirror.com
```

**Check DNS resolution:**
```bash
nslookup registry.npmjs.org
ping registry.npmjs.org
```

**Test with different network:**
- Try mobile hotspot
- Use VPN
- Try different WiFi network