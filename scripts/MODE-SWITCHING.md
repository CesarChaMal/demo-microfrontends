# Mode Switching System

The Demo Microfrontends project supports multiple loading strategies through a comprehensive mode switching system. This allows you to seamlessly switch between different deployment and development configurations.

## 🔄 Available Modes

### 1. **Local Mode** (Default)
- **Purpose**: Local development with individual dev servers
- **Loading**: Microfrontends from ports 4201-4211
- **Use Case**: Active development and debugging

### 2. **NPM Mode**
- **Purpose**: Load microfrontends from published NPM packages
- **Loading**: ES6 imports from NPM registry
- **Use Case**: Testing published packages, production-like setup

### 3. **GitHub Mode**
- **Purpose**: Load microfrontends from GitHub Pages
- **Loading**: Remote imports from GitHub repositories
- **Use Case**: Public deployment, sharing demos

### 4. **AWS Mode**
- **Purpose**: Load microfrontends from AWS S3
- **Loading**: Import map from S3 bucket
- **Use Case**: Enterprise deployment, CDN distribution

## 🛠 Mode Switching Commands

### Quick Commands

```bash
# Switch modes
npm run mode:local     # Local development
npm run mode:npm       # NPM packages
npm run mode:github    # GitHub Pages
npm run mode:aws       # AWS S3

# Check current mode
npm run mode:status

# Switch and serve
npm run serve:npm      # NPM mode + start server
npm run serve:github   # GitHub mode + start server
npm run serve:aws      # AWS mode + start server
```

### Manual Commands

```bash
# Using the mode switcher directly
node switch-mode.js local
node switch-mode.js npm
node switch-mode.js github
node switch-mode.js aws
node switch-mode.js status
```

## 📋 Mode Comparison

| Mode | Dependencies | Build Required | External Services | Best For |
|------|-------------|----------------|-------------------|----------|
| **Local** | Local packages | ✅ All apps | None | Development |
| **NPM** | Published packages | ❌ None | NPM Registry | Testing packages |
| **GitHub** | Local packages | ❌ None | GitHub Pages | Public demos |
| **AWS** | Local packages | ❌ None | AWS S3 | Enterprise deployment |

## 🏠 Local Mode

### Configuration
- **Package**: Uses standard `package.json`
- **Dependencies**: Local development dependencies only
- **Servers**: All 12 microfrontends + root (ports 4201-4211, 8080)

### Usage
```bash
# Switch to local mode
npm run mode:local

# Start development
npm run serve:local:dev    # All apps with hot reload
npm run serve:local:prod   # Production build locally

# Direct URL access
http://localhost:8080      # Auto-detects development
http://localhost:8080?dev  # Force development mode
http://localhost:8080?prod # Force production mode
```

### When to Use
- ✅ Active development
- ✅ Debugging individual microfrontends
- ✅ Testing integration between apps
- ✅ Hot reload development

## 📦 NPM Mode

### Configuration
- **Package**: Switches to `package-npm.json` with published dependencies
- **Dependencies**: `@cesarchamal/single-spa-*-app` packages
- **Servers**: Root server only (port 8080)

### Prerequisites
```bash
# Packages must be published first
npm run publish:patch
```

### Usage
```bash
# Switch to NPM mode (installs NPM packages)
npm run mode:npm

# Start server
npm run serve:npm

# Direct URL access
http://localhost:8080?mode=npm
```

### When to Use
- ✅ Testing published packages
- ✅ Production-like environment
- ✅ Package distribution validation
- ✅ CI/CD pipeline testing

## 🐙 GitHub Mode

### Configuration
- **Package**: Uses standard `package.json`
- **Environment**: Requires GitHub configuration
- **Servers**: Root server + optional GitHub API server

### Prerequisites
```bash
# Required environment variables (.env file)
GITHUB_TOKEN=ghp_your_personal_access_token
GITHUB_USERNAME=your-github-username  # Optional, defaults to cesarchamal
```

### Usage
```bash
# Switch to GitHub mode
npm run mode:github

# Start server
npm run serve:github

# Development mode (read existing)
http://localhost:8080?mode=github&env=dev

# Production mode (create & deploy)
http://localhost:8080?mode=github&env=prod
```

### Behavior
- **Dev Mode**: Reads from existing GitHub Pages repositories
- **Prod Mode**: Creates repositories and deploys all microfrontends

### When to Use
- ✅ Public demos and showcases
- ✅ Sharing with external teams
- ✅ GitHub Pages deployment
- ✅ Open source distribution

## ☁️ AWS Mode

### Configuration
- **Package**: Uses standard `package.json`
- **Environment**: Requires AWS S3 configuration
- **Servers**: Root server only

### Prerequisites
```bash
# Required environment variables (.env file)
S3_BUCKET=your-s3-bucket-name
AWS_REGION=your-aws-region
ORG_NAME=your-organization-name

# Optional: Custom import map URL
IMPORTMAP_URL=https://custom-bucket.s3.amazonaws.com/@myorg/importmap.json
```

### Usage
```bash
# Switch to AWS mode
npm run mode:aws

# Start server
npm run serve:aws

# Direct URL access
http://localhost:8080?mode=aws
```

### Import Map Structure
```json
{
  "imports": {
    "@myorg/auth-app": "https://bucket.s3.region.amazonaws.com/@myorg/auth-app/v1.0.0/bundle.js",
    "@myorg/layout-app": "https://bucket.s3.region.amazonaws.com/@myorg/layout-app/v1.0.0/bundle.js"
  }
}
```

### When to Use
- ✅ Enterprise deployment
- ✅ CDN distribution
- ✅ High availability setup
- ✅ Global content delivery

## 🔍 Mode Status and Debugging

### Check Current Mode
```bash
npm run mode:status
```

**Example Output:**
```
📋 Current Mode Status:
🏠 Current mode: LOCAL
🌐 Start with: npm run serve:local:dev
🔄 Switch to NPM: npm run mode:npm

📦 Available NPM packages:
  - @cesarchamal/single-spa-auth-app@^0.1.0
  - @cesarchamal/single-spa-layout-app@^0.1.0
  - ... (11 more packages)
```

### Debug Information
Each mode provides debug information in the browser console:
```javascript
// Local mode debug
🔍 LOCAL Mode Debug Info:
  - URL: http://localhost:8080
  - Port: 8080
  - isProduction: false
  - Mode will be: DEVELOPMENT (individual ports)

// NPM mode debug
🚀 Single-SPA Mode: NPM
Loading single-spa-auth-app from NPM

// GitHub mode debug
🚀 Single-SPA Mode: GITHUB
Loading single-spa-auth-app from GitHub: https://cesarchamal.github.io/...

// AWS mode debug
🚀 Single-SPA Mode: AWS
📦 Loading import map from: https://bucket.s3.region.amazonaws.com/@myorg/importmap.json
```

## 🔄 Mode Switching Workflow

### Development to Production
```bash
# 1. Start with local development
npm run mode:local
npm run serve:local:dev

# 2. Test production build locally
npm run serve:local:prod

# 3. Publish packages
npm run publish:patch

# 4. Test NPM packages
npm run mode:npm
npm run serve:npm

# 5. Deploy to GitHub Pages
npm run mode:github
./run.sh github prod

# 6. Deploy to AWS S3
npm run mode:aws
./run.sh aws prod
```

### Quick Mode Testing
```bash
# Test all modes quickly
npm run mode:local && npm run serve:local:dev &
npm run mode:npm && npm run serve:npm &
npm run mode:github && npm run serve:github &
npm run mode:aws && npm run serve:aws &
```

## 🛠 Advanced Configuration

### Custom Mode URLs
```javascript
// Browser console - temporary mode switch
localStorage.setItem('spa-mode', 'npm');
window.location.reload();

// URL parameters - one-time mode switch
http://localhost:8080?mode=github&env=prod
```

### Environment-Specific Configuration
```bash
# .env file for different environments
# Development
MODE=local
DEBUG=true

# Staging
MODE=npm
NPM_REGISTRY=https://npm.staging.company.com

# Production
MODE=aws
S3_BUCKET=prod-microfrontends
AWS_REGION=us-east-1
```

## 🚨 Troubleshooting

### Mode Switch Failures
```bash
# Reset to local mode
npm run mode:local

# Check package.json state
npm run mode:status

# Manual reset
cd single-spa-root
git checkout package.json
npm install
```

### NPM Mode Issues
```bash
# Check if packages are published
npm view @cesarchamal/single-spa-auth-app

# Verify NPM authentication
npm whoami

# Switch back to local if packages unavailable
npm run mode:local
```

### GitHub Mode Issues
```bash
# Check environment variables
echo $GITHUB_TOKEN
echo $GITHUB_USERNAME

# Verify GitHub API access
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

### AWS Mode Issues
```bash
# Check environment variables
echo $S3_BUCKET
echo $AWS_REGION
echo $ORG_NAME

# Test S3 access
aws s3 ls s3://$S3_BUCKET

# Verify import map
curl $IMPORTMAP_URL
```

## 📚 Related Documentation

- [VERSION-MANAGEMENT.md](VERSION-MANAGEMENT.md) - Version synchronization
- [NPM-PUBLISHING.md](../single-spa-root/NPM-PUBLISHING.md) - Package publishing
- [README.md](../README.md) - Main project documentation
- [GitHub Pages Configuration](../README.md#github-pages-configuration)
- [AWS S3 Configuration](../README.md#aws-s3-configuration)

## 🎯 Best Practices

1. **Start Local**: Always begin development in local mode
2. **Test NPM**: Validate packages before external deployment
3. **Use GitHub for Demos**: Share public demos via GitHub Pages
4. **Deploy AWS for Production**: Use AWS S3 for enterprise deployment
5. **Check Status**: Always verify current mode before switching
6. **Environment Variables**: Keep sensitive configuration in .env files
7. **Version Sync**: Use centralized version management across all modes