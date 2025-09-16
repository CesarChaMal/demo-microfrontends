# Mode Switching Guide

This guide covers switching between different deployment modes: Local, NPM, Nexus, GitHub, and AWS.

## Available Modes

| Mode | Description | Use Case | Requirements |
|------|-------------|----------|--------------|
| **Local** | Development servers | Daily development | Node.js, npm |
| **NPM** | Public NPM packages | Public distribution | NPM account, published packages |
| **Nexus** | Private registry | Enterprise deployment | Nexus server, authentication |
| **GitHub** | GitHub Pages | Static hosting | GitHub account, repositories |
| **AWS** | S3 static website | Cloud hosting | AWS account, S3 bucket |

## Quick Mode Switching

### Using Launcher Scripts (Recommended)
```bash
# Switch to any mode with automatic setup
./run.sh local dev      # Local development
./run.sh npm dev        # NPM packages
./run.sh nexus dev      # Nexus registry
./run.sh github dev     # GitHub Pages
./run.sh aws dev        # AWS S3
```

### Using NPM Scripts
```bash
# Switch mode and serve
npm run mode:local && npm run serve
npm run mode:npm && npm run serve
npm run mode:nexus && npm run serve
npm run mode:github && npm run serve
npm run mode:aws && npm run serve
```

### Browser Console (Temporary)
```javascript
// Temporary mode switch (until page refresh)
localStorage.setItem('spa-mode', 'npm');
localStorage.setItem('spa-mode', 'nexus');
localStorage.setItem('spa-mode', 'github');
localStorage.setItem('spa-mode', 'aws');
localStorage.setItem('spa-mode', 'local');
// Then refresh the page
```

### URL Parameters (Temporary)
```
http://localhost:8080?mode=local
http://localhost:8080?mode=npm
http://localhost:8080?mode=nexus
http://localhost:8080?mode=github
http://localhost:8080?mode=aws
```

## Mode-Specific Configuration

### Local Mode
```bash
# Configuration
SPA_MODE=local
SPA_ENV=dev|prod

# What it does
- Starts all 12 development servers (ports 4201-4211)
- Uses SystemJS for module loading
- Serves from local webpack-dev-server
- Hot reload enabled

# URLs
Dev:  http://localhost:4201/single-spa-auth-app.js
Prod: /single-spa-auth-app.js (served from root)
```

### NPM Mode
```bash
# Configuration
SPA_MODE=npm

# Requirements
- Published NPM packages
- NPM authentication (for publishing)

# What it does
- Switches to NPM registry
- Fixes dependency versions
- Uses unpkg CDN for package loading
- Publishes packages if missing

# URLs
https://unpkg.com/@cesarchamal/single-spa-auth-app@latest/dist/bundle.js
```

### Nexus Mode
```bash
# Configuration
SPA_MODE=nexus

# Requirements
- .npmrc.nexus file with registry configuration
- Nexus server access and authentication

# What it does
- Switches to Nexus registry
- Configures authentication
- Uses private registry packages
- Publishes to private registry

# Example .npmrc.nexus
registry=http://localhost:8081/repository/npm-group/
//localhost:8081/repository/npm-group/:_auth=YWRtaW46YWRtaW4xMjM=
```

### GitHub Mode
```bash
# Configuration
SPA_MODE=github
GITHUB_TOKEN=ghp_xxxxxxxxxxxxx
GITHUB_USERNAME=cesarchamal
ORG_NAME=cesarchamal

# What it does
Dev:  Reads from existing GitHub Pages
Prod: Creates repositories and deploys everything

# URLs
https://cesarchamal.github.io/single-spa-auth-app/single-spa-auth-app.js
```

### AWS Mode
```bash
# Configuration
SPA_MODE=aws
S3_BUCKET=single-spa-demo-774145483743
AWS_REGION=eu-central-1
ORG_NAME=cesarchamal

# What it does
- Uses S3 static website hosting
- Loads via import map
- Deploys to S3 bucket

# URLs
Website: http://bucket.s3-website,region.amazonaws.com
Import Map: https://bucket.s3.region.amazonaws.com/@cesarchamal/importmap.json
```

## Mode Switching Workflow

### Automatic Mode Switching (Launcher)
```bash
# The launcher handles everything automatically
./run.sh npm dev
```

**What happens:**
1. **Registry Switch**: Changes NPM registry configuration
2. **Dependency Fix**: Resolves version mismatches
3. **Build Process**: Builds applications for target mode
4. **Publishing**: Publishes packages if needed (NPM/Nexus)
5. **Deployment**: Deploys to external services (GitHub/AWS)
6. **Server Start**: Starts appropriate servers

### Manual Mode Switching
```bash
# 1. Switch mode configuration
npm run mode:npm

# 2. Fix dependencies for new mode
npm run fix:npm:deps:root

# 3. Build applications
npm run build:all

# 4. Publish packages (if needed)
npm run publish:npm:nobump

# 5. Start server
npm run serve
```

## Environment Variables

### GitHub Mode Variables
```bash
# Required
export GITHUB_TOKEN=ghp_your_personal_access_token
export GITHUB_USERNAME=your-github-username

# Optional
export ORG_NAME=your-organization-name
```

**GitHub Token Permissions:**
- `repo` - Full repository access
- `workflow` - GitHub Actions access
- `pages` - GitHub Pages access

### AWS Mode Variables
```bash
# Required
export S3_BUCKET=your-s3-bucket-name
export AWS_REGION=your-aws-region
export ORG_NAME=your-organization-name

# Optional
export IMPORTMAP_URL=https://custom-bucket.s3.amazonaws.com/@myorg/importmap.json
```

**AWS Credentials:**
- Configure via `aws configure`
- Or use IAM roles/environment variables
- Requires S3 read/write permissions

## Mode-Specific Features

### Development vs Production

#### Development Environment
```bash
./run.sh [mode] dev
```
- **GitHub**: Reads from existing repositories
- **AWS**: Uses existing S3 files
- **NPM/Nexus**: Uses existing packages
- **Local**: Starts development servers

#### Production Environment
```bash
./run.sh [mode] prod
```
- **GitHub**: Creates repositories and deploys
- **AWS**: Builds and uploads to S3
- **NPM/Nexus**: Builds and publishes packages
- **Local**: Serves production builds

### Hot Reload Support

**Local Mode**: Built-in hot reload
```bash
./run.sh local dev  # Automatic hot reload
```

**External Modes**: Hot sync scripts
```bash
# Terminal 1: Start application
./run.sh aws dev

# Terminal 2: Start hot sync
npm run aws:hot-sync    # Auto-uploads changes to S3
npm run github:hot-sync # Auto-deploys to GitHub
```

## Troubleshooting Mode Switching

### Common Issues

#### Registry Authentication
```bash
# Test authentication
npm run test:npm:auth
npm run test:nexus:auth

# Fix authentication
npm login                    # For NPM
# Edit .npmrc.nexus          # For Nexus
```

#### Version Mismatches
```bash
# Auto-fix dependencies
npm run fix:auto

# Manual fix
npm run fix:npm:deps:root
npm run fix:nexus:deps:root
```

#### Missing Packages
```bash
# Publish missing packages
npm run publish:npm:nobump
npm run publish:nexus:nobump
```

#### Environment Variables
```bash
# Check required variables
echo $GITHUB_TOKEN $GITHUB_USERNAME
echo $S3_BUCKET $AWS_REGION $ORG_NAME

# Set missing variables
export GITHUB_TOKEN=ghp_xxxxx
export S3_BUCKET=my-bucket
```

### Recovery Commands
```bash
# Reset to local mode
npm run mode:local
./run.sh local dev

# Clean reset with fixes
./run.sh local dev --clean --fix-network
```

## Mode Status and Checking

### Check Current Mode
```bash
# Show current mode configuration
npm run mode:status

# Check all modes
npm run check:local
npm run check:npm
npm run check:nexus
npm run check:github
npm run check:aws
```

### Verify Mode Setup
```bash
# Local mode
curl http://localhost:4201/single-spa-auth-app.js

# NPM mode
curl https://unpkg.com/@cesarchamal/single-spa-auth-app@latest/dist/bundle.js

# GitHub mode
curl https://cesarchamal.github.io/single-spa-auth-app/single-spa-auth-app.js

# AWS mode
curl https://your-bucket.s3.amazonaws.com/@cesarchamal/single-spa-auth-app/single-spa-auth-app.js
```

## Best Practices

### Development Workflow
```bash
# Daily development
./run.sh local dev

# Test NPM packages
./run.sh npm dev

# Test private registry
./run.sh nexus dev

# Test deployment
./run.sh github dev
./run.sh aws dev
```

### Production Deployment
```bash
# Deploy to GitHub Pages
./run.sh github prod

# Deploy to AWS S3
./run.sh aws prod

# Publish to registries
./run.sh npm prod
./run.sh nexus prod
```

### Mode Testing
```bash
# Test all modes work
for mode in local npm nexus github aws; do
  echo "Testing $mode mode..."
  ./run.sh $mode dev
  # Test application functionality
  # Stop servers
done
```

### Version Synchronization
```bash
# Keep versions synchronized across modes
npm run version:set 1.2.3
npm run publish:npm:nobump
npm run publish:nexus:nobump
./run.sh github prod
./run.sh aws prod
```

## Advanced Mode Switching

### Conditional Mode Selection
```bash
# Choose mode based on environment
if [ "$CI" = "true" ]; then
  ./run.sh github prod
else
  ./run.sh local dev
fi
```

### Batch Mode Testing
```bash
# Test multiple modes
npm run test:all:modes

# Custom batch testing
for mode in npm nexus; do
  ./run.sh $mode dev
  npm test
done
```

### Mode-Specific Configuration
```javascript
// In application code
const mode = localStorage.getItem('spa-mode') || 'local';
const config = {
  local: { apiUrl: 'http://localhost:3000' },
  npm: { apiUrl: 'https://api.example.com' },
  nexus: { apiUrl: 'https://internal-api.company.com' },
  github: { apiUrl: 'https://api.github-pages.com' },
  aws: { apiUrl: 'https://api.aws-s3.com' }
};
```

## Integration with CI/CD

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
- name: Deploy to GitHub Pages
  run: ./run.sh github prod

- name: Deploy to AWS S3
  run: ./run.sh aws prod
```

### Environment-Based Deployment
```bash
# Development environment
if [ "$NODE_ENV" = "development" ]; then
  ./run.sh local dev
fi

# Staging environment
if [ "$NODE_ENV" = "staging" ]; then
  ./run.sh github dev
fi

# Production environment
if [ "$NODE_ENV" = "production" ]; then
  ./run.sh aws prod
fi
```