# Deployment Guide

This guide explains the different deployment methods available for the Demo Microfrontends project.

## Deployment Methods Overview

The project supports multiple deployment strategies with different execution contexts and use cases.

## NPM/Nexus Package Publishing

### Publishing Scripts Comparison

| Script | Process | Registry | Use Case |
|--------|---------|----------|----------|
| `publish:all` | NPM → Nexus (sequential) | Both registries | Publish to both NPM and Nexus |
| `publish:npm:all` | Build → Publish → Fix → Switch | NPM only | Complete NPM workflow |
| `publish:nexus:all` | Build → Publish → Fix → Switch | Nexus only | Complete Nexus workflow |

#### `npm run publish:all`
- **Process**: Runs `publish:npm:all` then `publish:nexus:all` sequentially
- **Registries**: Both NPM and Nexus
- **Use Case**: Publish packages to both registries for maximum distribution
- **Time**: Longest (builds twice, publishes to both)

#### `npm run publish:npm:all`
- **Process**: 
  1. Build all apps in production mode
  2. Publish packages to NPM registry
  3. Fix dependencies to use published NPM versions
  4. Switch to NPM mode for testing
- **Registry**: NPM (https://registry.npmjs.org/)
- **Use Case**: NPM-only publishing and testing
- **Time**: Medium (single registry)

#### `npm run publish:nexus:all`
- **Process**:
  1. Build all apps in production mode
  2. Publish packages to Nexus registry
  3. Fix dependencies to use published Nexus versions
  4. Switch to Nexus mode for testing
- **Registry**: Nexus (from .npmrc.nexus)
- **Use Case**: Private registry publishing and testing
- **Time**: Medium (single registry)

### Publishing Workflow Details

Each publishing script follows this pattern:
```bash
# 1. Build (in local mode)
npm run build:prod

# 2. Publish packages
npm run publish:[registry]:prod

# 3. Fix dependencies (force correct registry)
SKIP_INSTALL=true npm run fix:[registry]:deps

# 4. Switch to target mode
SKIP_INSTALL=true npm run mode:[registry]
```

### Registry-Specific Version Detection

- **NPM Fix**: Forces `--registry https://registry.npmjs.org/` to get NPM versions
- **Nexus Fix**: Forces `--registry [nexus-url]` from `.npmrc.nexus` to get Nexus versions
- **Prevents Cross-Contamination**: Each fix script checks only its target registry

### Publishing Requirements

#### NPM Publishing
- **Authentication**: `NPM_TOKEN` environment variable or `npm login`
- **Registry**: Public NPM registry
- **Packages**: Published as `@cesarchamal/single-spa-*`

#### Nexus Publishing  
- **Authentication**: `.npmrc.nexus` with registry and auth configuration
- **Registry**: Private Nexus repository
- **Packages**: Published to private registry for internal use

## Direct Deployment (Local Machine)

### AWS S3 Deployment

#### `npm run deploy:aws:prod`
- **Execution**: Runs locally on your machine
- **Process**: 
  1. Switch to AWS mode (`npm run mode:aws`)
  2. Build root app for AWS (`npm run build:root:aws:prod`)
  3. Deploy everything to S3 (`npm run deploy:s3:prod`)
- **What it deploys**: All 11 microfrontends + root app + import map + shared resources
- **Requirements**: AWS CLI configured locally, S3 bucket access
- **Speed**: ⚡ Fast (single operation)
- **Use Case**: Quick AWS deployment from local machine

**Example:**
```bash
npm run deploy:aws:prod
```

### GitHub Pages Deployment

#### `npm run deploy:github:all`
- **Execution**: Runs locally on your machine  
- **Process**: Deploys each app individually to separate GitHub repositories
- **What it deploys**: Creates 12 separate GitHub repositories with GitHub Pages
- **Requirements**: GitHub CLI + API token, repository creation permissions
- **Speed**: 🐌 Slower (12 sequential operations)
- **Use Case**: Local GitHub deployment with individual repositories

**Example:**
```bash
npm run deploy:github:all
```

## Remote Deployment (GitHub Actions)

### General GitHub Actions Trigger

#### `npm run trigger:actions`
- **Execution**: Triggers all configured GitHub Actions workflows
- **Process**: Adds triggers to all package.json files and pushes to GitHub
- **What it triggers**: All available workflows (build, test, deploy, etc.)
- **Requirements**: GitHub repository with Actions enabled
- **Speed**: 🔄 Medium (depends on GitHub Actions queue)
- **Use Case**: Trigger all CI/CD pipelines, comprehensive automation

**Example:**
```bash
npm run trigger:actions
```

### AWS via GitHub Actions

#### `npm run trigger:deploy:aws`
- **Execution**: Triggers GitHub Actions workflow that runs on GitHub servers
- **Process**: GitHub Actions builds and deploys to AWS S3
- **What it deploys**: All microfrontends to S3 via CI/CD pipeline
- **Requirements**: GitHub secrets (AWS credentials, S3 bucket info)
- **Speed**: 🔄 Medium (depends on GitHub Actions queue)
- **Use Case**: CI/CD AWS pipeline, automated deployments

**Example:**
```bash
npm run trigger:deploy:aws
```

### GitHub Pages via GitHub Actions

#### `npm run trigger:deploy:github`
- **Execution**: Triggers GitHub Actions workflow for GitHub Pages
- **Process**: GitHub Actions builds and deploys to GitHub Pages
- **What it deploys**: All microfrontends via GitHub Actions to Pages
- **Requirements**: GitHub Actions enabled, Pages configured
- **Speed**: 🔄 Medium (depends on GitHub Actions queue)
- **Use Case**: CI/CD GitHub pipeline, automated Pages deployment

**Example:**
```bash
npm run trigger:deploy:github
```

### Robust GitHub Pages Deployment

#### `npm run trigger:github:pages`
- **Execution**: Directly triggers the robust GitHub Pages workflow
- **Process**: Uses GitHub CLI to run the parallel deployment workflow
- **What it deploys**: All 12 apps in parallel using matrix strategy
- **Requirements**: GitHub CLI authenticated
- **Speed**: ⚡ Fast trigger, parallel execution (5-8 minutes)
- **Use Case**: Best GitHub deployment method, production-ready

**Example:**
```bash
npm run trigger:github:pages
```

### Advanced AWS S3 Deployment

#### `npm run trigger:aws:s3`
- **Execution**: Directly triggers advanced AWS S3 deployment workflow
- **Process**: Uses AWS CLI to run parallel S3 deployment with optimization
- **What it deploys**: All 12 apps in parallel with CloudFront invalidation
- **Requirements**: AWS CLI configured, S3 bucket access, CloudFront distribution
- **Speed**: ⚡ Fast trigger, parallel execution (3-5 minutes)
- **Use Case**: Best AWS deployment method, production-ready with CDN

**Example:**
```bash
npm run trigger:aws:s3
```

## Deployment Comparison

| Script | Where | What | Speed | Reliability | Use Case |
|--------|-------|------|-------|-------------|----------|
| `deploy:aws:prod` | Local | Direct S3 upload | ⚡ Fast | High | Quick AWS deployment |
| `deploy:github:all` | Local | 12 individual repos | 🐌 Slow | Medium | Local GitHub deployment |
| `trigger:actions` | GitHub Actions | All workflows | 🔄 Medium | High | Complete CI/CD pipeline |
| `trigger:deploy:aws` | GitHub Actions | Remote AWS deploy | 🔄 Medium | High | CI/CD AWS pipeline |
| `trigger:deploy:github` | GitHub Actions | Remote GitHub deploy | 🔄 Medium | Medium | CI/CD GitHub pipeline |
| `trigger:github:pages` | GitHub CLI | Parallel GitHub deploy | ⚡ Fast | High | Best GitHub deployment |
| `trigger:aws:s3` | AWS CLI | Parallel S3 + CDN | ⚡ Fast | High | Best AWS deployment |

## Recommended Deployment Methods

### For AWS S3
**Recommended**: `npm run trigger:aws:s3`
- Parallel execution with CloudFront invalidation
- Most reliable with retry logic and optimization
- Production-ready with CDN integration

**Alternative**: `npm run deploy:aws:prod`
- Direct upload from local machine
- Single operation, good for quick deployments

### For GitHub Pages
**Recommended**: `npm run trigger:github:pages`
- Parallel execution (fastest)
- Most reliable with retry logic
- Production-ready with proper error handling

## Deployment Architecture

### AWS S3 Architecture
```
deploy:aws:prod
├── mode:aws (switch configuration)
├── build:root:aws:prod (build root for AWS)
└── deploy:s3:prod
    ├── Build all 11 microfrontends
    ├── Create import map
    ├── Upload to S3 bucket
    ├── Set up CORS and policies
    └── Deploy shared resources
```

### GitHub Pages Architecture
```
deploy:github:all
├── deploy:github:auth (create repo + deploy)
├── deploy:github:layout (create repo + deploy)
├── ... (9 more apps)
└── deploy:github:root (deploy main app)

trigger:github:pages (parallel)
├── Matrix strategy (12 parallel jobs)
├── Each job: build + deploy independently
├── Automatic repository creation
└── Import map updates with retries
```

## Environment Variables

### AWS Deployment
Required environment variables in `.env`:
```bash
S3_BUCKET=your-s3-bucket-name
AWS_REGION=your-aws-region
ORG_NAME=your-organization-name
```

### GitHub Deployment
Required environment variables:
```bash
GITHUB_TOKEN=ghp_your_github_personal_access_token
GITHUB_USERNAME=your-github-username
ORG_NAME=your-organization-name  # optional
```

## Deployment Outputs

### AWS S3 Result
- **Website URL**: `http://bucket-name.s3-website,region.amazonaws.com`
- **Import Map**: `https://bucket.s3.region.amazonaws.com/@org/importmap.json`
- **Individual Apps**: `https://bucket.s3.region.amazonaws.com/@org/app-name/`

### GitHub Pages Result
- **Main URL**: `https://username.github.io/demo-microfrontends/`
- **Individual Repos**: `https://github.com/username/single-spa-app-name`
- **Individual Pages**: `https://username.github.io/single-spa-app-name/`

## Troubleshooting

### AWS Deployment Issues
1. **AWS CLI not configured**: Run `aws configure`
2. **S3 bucket permissions**: Ensure bucket policy allows public read
3. **CORS issues**: Script automatically configures CORS

### GitHub Deployment Issues
1. **GitHub CLI not authenticated**: Run `gh auth login`
2. **Repository creation fails**: Check GitHub token permissions
3. **Pages not enabled**: Enable Pages in repository settings

## Advanced Usage

### Custom S3 Bucket Setup
```bash
# Setup S3 bucket with full configuration
./scripts/setup-s3.sh public
```

### Hot Reload Development
```bash
# AWS hot sync (auto-upload changes)
npm run aws:hot-sync

# GitHub hot sync (auto-deploy changes)
npm run github:hot-sync
```

### Status Checking
```bash
# Check deployment status
npm run check:aws
npm run check:github
```

## Security Considerations

### AWS
- Use IAM roles with minimal required permissions
- Enable S3 bucket encryption
- Configure CloudFront for production

### GitHub
- Use fine-grained personal access tokens
- Limit token permissions to repository creation and Pages
- Enable branch protection rules for production

## Performance Optimization

### AWS S3
- Enable CloudFront CDN
- Configure proper caching headers
- Use S3 Transfer Acceleration

### GitHub Pages
- Use parallel deployment (`trigger:github:pages`)
- Enable GitHub Actions caching
- Optimize build artifacts size

## Cost Considerations

### AWS S3
- S3 storage costs (minimal for static files)
- Data transfer costs
- CloudFront costs (if used)

### GitHub Pages
- Free for public repositories
- GitHub Actions minutes (free tier: 2000 minutes/month)
- Private repository limitations

## Monitoring and Logging

### AWS
- CloudWatch logs for S3 access
- AWS CLI output for deployment status
- S3 access logs

### GitHub
- GitHub Actions logs
- Pages deployment status
- Repository insights

## Best Practices

1. **Use environment-specific configurations**
2. **Test deployments in staging first**
3. **Monitor deployment logs**
4. **Set up automated health checks**
5. **Use proper versioning strategies**
6. **Implement rollback procedures**
7. **Document deployment procedures**
8. **Use infrastructure as code when possible**