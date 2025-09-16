# Troubleshooting Guide

This guide helps resolve common issues when working with the microfrontend application.

## Quick Fixes

### Application Won't Start
```bash
# Clean installation and network fixes
./run.sh local dev --clean --fix-network

# Or use quick development launcher
./dev-all.sh
```

### Port Conflicts
```bash
# Check what's using the ports
netstat -tulpn | grep :8080
netstat -tulpn | grep :4201

# Kill processes using the ports
kill -9 $(lsof -t -i:8080)
pkill -f "webpack-dev-server"

# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

### Module Loading Errors
```bash
# Auto-fix dependencies
npm run fix:auto

# Or target specific mode
npm run fix:auto:npm
npm run fix:auto:nexus
```

## Common Issues

### 1. Node.js Version Issues

**Problem:** Application fails to start with OpenSSL or Node.js errors

**Solution:**
```bash
# Check Node.js version (requires v18+)
node --version

# Launcher scripts handle OpenSSL compatibility automatically
./run.sh local dev  # Includes --openssl-legacy-provider fix
```

**Manual Fix:**
```bash
export NODE_OPTIONS="--openssl-legacy-provider"
npm start
```

### 2. Network and Connection Issues

**Problem:** ECONNRESET, ETIMEDOUT, or npm install failures

**Solution:**
```bash
# Apply network fixes
./run.sh local dev --fix-network

# Manual network configuration
npm config set registry https://registry.npmjs.org/
npm config set timeout 60000
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000
```

### 3. Dependency Version Mismatches

**Problem:** "No matching version found" or module loading errors

**Solution:**
```bash
# Auto-detect and fix
npm run fix:auto

# Specific registry fixes
npm run fix:npm:deps:root     # For NPM mode
npm run fix:nexus:deps:root   # For Nexus mode

# Check current versions
npm run version:current
```

### 4. Registry Authentication Issues

**Problem:** 401 Unauthorized or authentication failures

**NPM Solution:**
```bash
# Test NPM authentication
npm run test:npm:auth

# Set NPM token
export NPM_TOKEN=npm_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
npm login
```

**Nexus Solution:**
```bash
# Test Nexus authentication
npm run test:nexus:auth

# Check .npmrc.nexus configuration
cat .npmrc.nexus
```

### 5. Build Failures

**Problem:** Webpack build errors or compilation failures

**Solution:**
```bash
# Clean build
npm run clean
npm run build:all

# Individual app builds
cd single-spa-[app-name]
npm run build

# Check for ESLint errors
npm run lint
```

### 6. Layout and Styling Issues

**Problem:** Header, navbar, or footer not displaying correctly

**Solution:**
```bash
# Check if layout app is running
curl http://localhost:4202/single-spa-layout-app.js

# Verify authentication state
# Layout only renders when authenticated
```

**Manual Check:**
- Login at `/login` first
- Layout components only show for authenticated users
- Check browser console for JavaScript errors

### 7. Hot Reload Not Working

**Problem:** Changes not reflecting in browser

**Solution:**
```bash
# Restart development servers
./run.sh local dev

# Check if files are being watched
# Look for "webpack compiled" messages in terminal

# Clear browser cache
# Hard refresh: Ctrl+Shift+R (Chrome/Firefox)
```

### 8. Memory Issues

**Problem:** "JavaScript heap out of memory" errors

**Solution:**
```bash
# Increase Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=4096"
./run.sh local dev

# Or permanently in package.json scripts
"serve": "cross-env NODE_OPTIONS='--max-old-space-size=4096' webpack serve"
```

### 9. CORS Issues

**Problem:** Cross-origin request blocked errors

**Solution:**
- Applications are pre-configured with CORS support
- Check if all development servers are running
- Verify URLs in browser network tab

**Manual CORS Fix:**
```javascript
// In webpack.config.js
devServer: {
  headers: {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, PATCH, OPTIONS",
    "Access-Control-Allow-Headers": "X-Requested-With, content-type, Authorization"
  }
}
```

### 10. GitHub Mode Issues

**Problem:** GitHub deployment or loading failures

**Solution:**
```bash
# Check environment variables
echo $GITHUB_TOKEN
echo $GITHUB_USERNAME

# Test GitHub authentication
gh auth status

# Check repository status
npm run check:github
```

**Environment Setup:**
```bash
export GITHUB_TOKEN=ghp_your_token_here
export GITHUB_USERNAME=your-username
export ORG_NAME=your-org-name
```

### 11. AWS Mode Issues

**Problem:** AWS S3 deployment or loading failures

**Solution:**
```bash
# Check environment variables
echo $S3_BUCKET
echo $AWS_REGION
echo $ORG_NAME

# Test AWS credentials
aws s3 ls s3://$S3_BUCKET

# Check S3 status
npm run check:aws
```

**Environment Setup:**
```bash
export S3_BUCKET=your-bucket-name
export AWS_REGION=your-region
export ORG_NAME=your-org-name
```

## Debug Mode

### Enable Debug Logging
```bash
# Single-SPA debug logs
DEBUG=single-spa:* ./run.sh local dev

# NPM debug logs
npm config set loglevel verbose
./run.sh npm dev

# Webpack debug logs
DEBUG=webpack:* ./run.sh local dev
```

### Browser Debug
```javascript
// In browser console
localStorage.setItem('devtools', true);
window.singleSpa.getAppNames();
window.singleSpa.getAppStatus('single-spa-auth-app');

// Check state manager
window.stateManager.userState$.subscribe(console.log);
window.stateManager.events$.subscribe(console.log);
```

## Performance Issues

### Slow Startup
```bash
# Use quick launcher
./dev-all.sh

# Skip unnecessary rebuilds
./run.sh local dev  # Instead of --clean

# Parallel builds (automatic in launcher)
```

### High Memory Usage
```bash
# Monitor memory usage
top -p $(pgrep -f webpack-dev-server)

# Reduce concurrent builds
# Edit launcher scripts to build sequentially
```

### Slow Hot Reload
```bash
# Check file watchers
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Reduce watched files in webpack.config.js
watchOptions: {
  ignored: /node_modules/,
  poll: 1000
}
```

## Recovery Procedures

### Complete Reset
```bash
# Nuclear option - reset everything
./run.sh local dev --clean --fix-network

# Manual reset
npm run clean
rm -rf node_modules package-lock.json
npm install
npm run build:all
```

### Registry Reset
```bash
# Reset NPM configuration
npm run registry:restore
npm cache clean --force

# Reset to local mode
npm run mode:local
./run.sh local dev
```

### Process Cleanup
```bash
# Kill all Node.js processes (use with caution)
pkill -f node

# Kill specific webpack processes
pkill -f webpack-dev-server

# Windows
taskkill /f /im node.exe
taskkill /f /fi "WINDOWTITLE eq webpack-dev-server"
```

## Diagnostic Commands

### System Check
```bash
# Check Node.js and npm versions
node --version
npm --version

# Check available ports
netstat -tulpn | grep -E ':(8080|420[1-9]|421[01])'

# Check disk space
df -h
```

### Application Status
```bash
# Check all modes
npm run check:local
npm run check:npm
npm run check:nexus
npm run check:github
npm run check:aws

# Check current mode
npm run mode:status

# Check versions
npm run version:current
```

### Network Diagnostics
```bash
# Test external connectivity
curl -I https://registry.npmjs.org/
curl -I https://unpkg.com/

# Test local servers
curl http://localhost:8080
curl http://localhost:4201/single-spa-auth-app.js
```

## Error Messages and Solutions

### "Cannot resolve module"
```bash
# Fix dependencies
npm run fix:auto

# Reinstall dependencies
npm run clean && npm install
```

### "Port already in use"
```bash
# Find and kill process
lsof -ti:8080 | xargs kill -9

# Use different ports (edit package.json)
```

### "Permission denied"
```bash
# Fix script permissions
chmod +x run.sh dev-all.sh

# Run as administrator (Windows)
```

### "Module not found"
```bash
# Check if module exists
npm list [module-name]

# Reinstall specific module
npm install [module-name]

# Clear npm cache
npm cache clean --force
```

### "Authentication required"
```bash
# NPM login
npm login

# Check authentication
npm whoami

# Use token authentication
export NPM_TOKEN=your_token
```

## Getting Help

### Log Collection
```bash
# Collect logs for support
./run.sh local dev > debug.log 2>&1

# Include system information
node --version >> debug.log
npm --version >> debug.log
uname -a >> debug.log
```

### Minimal Reproduction
```bash
# Create minimal test case
./run.sh local dev --clean
# Document exact steps that cause the issue
```

### Community Resources
- [Single-SPA Documentation](https://single-spa.js.org/)
- [Single-SPA Slack Community](https://single-spa.slack.com/)
- [GitHub Issues](https://github.com/single-spa/single-spa/issues)

### Project-Specific Help
- Check individual app README files
- Review [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)
- Check [DEPENDENCY-FIXES.md](DEPENDENCY-FIXES.md)
- Review [MODE-SWITCHING.md](MODE-SWITCHING.md)