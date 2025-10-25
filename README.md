# Demo Microfrontends with Single-SPA

A comprehensive demonstration of microfrontend architecture using Single-SPA framework, showcasing multiple frontend technologies working together in a unified application.

## ✍🏻 Motivation

This application demonstrates a comprehensive microfrontend architecture using Single-SPA with multiple deployment strategies including local development, NPM packages, Nexus private registry, GitHub Pages, and AWS S3. It showcases 12 different microfrontends built with various frameworks and technologies.

## ▶️ Live Demo

**Live Demo (CloudFront CDN):** [https://d3oyknhmr5oulj.cloudfront.net/](https://dn4u45z3eziu.cloudfront.net/)

**Alternative (S3 Direct):** [http://single-spa-demo-774145483743.s3-website.eu-central-1.amazonaws.com](http://single-spa-demo-774145483743.s3-website.eu-central-1.amazonaws.com)

**Login credentials:**

| User  | Password |
| ----- | -------- |
| admin | 12345    |

## Architecture Overview

This project demonstrates a microfrontend architecture with:
- **Root Application**: Orchestrates and manages all microfrontends
- **Multiple Microfrontends**: Independent applications built with different frameworks
- **Authentication**: Centralized login system
- **Shared Layout**: Common header, navigation, and footer components
- **RxJS State Management**: Real-time cross-app communication and shared state
- **Employee Data API**: Shared JSON data accessible across all microfrontends

## 🏗️ Microfrontend Architecture

This project consists of **12 microfrontends** working together:

| Microfrontend | Framework | Port | Route | Repository |
|---------------|-----------|------|-------|------------|
| 🎯 Root App | Single-SPA | 8080 | Orchestrator | [single-spa-root](https://github.com/cesarchamal/single-spa-root) |
| 🔐 Auth App | Vue.js | 4201 | /login | [single-spa-auth-app](https://github.com/cesarchamal/single-spa-auth-app) |
| 🎨 Layout App | Vue.js | 4202 | All routes | [single-spa-layout-app](https://github.com/cesarchamal/single-spa-layout-app) |
| 🏠 Home App | AngularJS | 4203 | / | [single-spa-home-app](https://github.com/cesarchamal/single-spa-home-app) |
| 🅰️ Angular App | Angular 8 | 4204 | /angular/* | [single-spa-angular-app](https://github.com/cesarchamal/single-spa-angular-app) |
| 💚 Vue App | Vue.js 2 | 4205 | /vue/* | [single-spa-vue-app](https://github.com/cesarchamal/single-spa-vue-app) |
| ⚛️ React App | React 16 | 4206 | /react/* | [single-spa-react-app](https://github.com/cesarchamal/single-spa-react-app) |
| 🍦 Vanilla App | ES2020+ | 4207 | /vanilla/* | [single-spa-vanilla-app](https://github.com/cesarchamal/single-spa-vanilla-app) |
| 🧩 Web Components | Lit | 4208 | /webcomponents/* | [single-spa-webcomponents-app](https://github.com/cesarchamal/single-spa-webcomponents-app) |
| 📘 TypeScript App | TypeScript | 4209 | /typescript/* | [single-spa-typescript-app](https://github.com/cesarchamal/single-spa-typescript-app) |
| 💎 jQuery App | jQuery 3.6 | 4210 | /jquery/* | [single-spa-jquery-app](https://github.com/cesarchamal/single-spa-jquery-app) |
| 🔥 Svelte App | Svelte 3 | 4211 | /svelte/* | [single-spa-svelte-app](https://github.com/cesarchamal/single-spa-svelte-app) |

## Project Structure

```
demo-microfrontends/
├── single-spa-root/                             # Root application
├── single-spa-auth-app/                         # Vue.js authentication app
├── single-spa-layout-app/                       # Vue.js layout components
├── single-spa-home-app/                         # AngularJS home page
├── single-spa-angular-app/                      # Angular 8 application
├── single-spa-react-app/                        # React application
├── single-spa-vue-app/                          # Vue.js application
├── single-spa-vanilla-app/                      # Vanilla JavaScript ES Module
├── single-spa-webcomponents-app/                # Web Components (Lit)
├── single-spa-typescript-app/                   # TypeScript application
├── single-spa-jquery-app/                       # jQuery legacy integration
├── single-spa-svelte-app/                       # Svelte application
└── scripts/                                     # Utility scripts for deployment
```

## 🔄 RxJS State Management

All 12 applications are integrated with a centralized RxJS-based state management system:

### **Global State Manager**
```javascript
// Available globally in all microfrontends
window.stateManager
```

### **User Authentication State**
```javascript
// Subscribe to user state changes
window.stateManager.userState$.subscribe(state => {
  console.log('User state:', state); // {user, isAuthenticated, token}
});

// Login (from auth app)
window.stateManager.setUser({username: 'admin'}, 'token');

// Logout (from layout app)
window.stateManager.logout();
```

### **Cross-App Event Communication**
```javascript
// Listen to events from other apps
window.stateManager.events$.subscribe(event => {
  console.log('Event received:', event);
});

// Broadcast events to other apps
window.stateManager.emit('custom-event', {data: 'hello'});
```

### **Shared Employee Data**
```javascript
// Load employee data from /employees.json
window.stateManager.loadEmployees();

// Subscribe to employee updates
window.stateManager.employees$.subscribe(employees => {
  console.log('Employees:', employees);
});

// Get current employees
const employees = window.stateManager.getEmployees();
```

### **Visual Shared State Showcase**

Each microfrontend includes a comprehensive **visual showcase** of the shared state management system:

**🎨 Showcase Features:**
- 🔄 **Shared State Management** header with framework identification
- 👤 **User State Display**: Real-time login status and username
- 👥 **Employee Data Visualization**: Count and preview of loaded employees
- 📡 **Interactive Buttons**: Load employees, broadcast messages, clear data
- 📨 **Recent Events Feed**: Live display of cross-app communication
- 🎯 **Cross-Framework Communication**: Visual notifications between apps

**🖼️ Showcase Implementation Status:**

| App | Visual Showcase | User State | Employee Data | Cross-App Events | Interactive Buttons |
|-----|----------------|------------|---------------|------------------|---------------------|
| 🔐 Auth App | ❌ | ✅ Login/Logout | ❌ | ✅ All events | ❌ |
| 🎨 Layout App | ❌ | ✅ User display | ❌ | ✅ All events | ❌ |
| 🏠 Home App | ✅ **Full Showcase** | ✅ User state | ✅ Employee display | ✅ Event feed | ✅ Load/Broadcast/Clear |
| 🅰️ Angular App | ✅ **Full Showcase** | ✅ User state | ✅ Employee display | ✅ Event feed | ✅ Load/Broadcast/Clear |
| 💚 Vue App | ✅ **Full Showcase** | ✅ User state | ✅ Employee display | ✅ Event feed | ✅ Load/Broadcast/Clear |
| ⚛️ React App | ✅ **Full Showcase** | ✅ Custom hooks | ✅ Employee display | ✅ Event feed | ✅ Load/Broadcast/Clear |
| 🍦 Vanilla App | ✅ **Full Showcase** | ✅ User state | ✅ Employee display | ✅ Event feed | ✅ Load/Broadcast/Clear |
| 🧩 Web Components | ✅ **Full Showcase** | ✅ User state | ✅ Employee display | ✅ Event feed | ✅ Load/Broadcast/Clear |
| 📘 TypeScript App | ✅ **Full Showcase** | ✅ User state | ✅ Employee display | ✅ Event feed | ✅ Load/Broadcast/Clear |
| 💎 jQuery App | ✅ **Full Showcase** | ✅ User state | ✅ Employee display | ✅ Event feed | ✅ Load/Broadcast/Clear |
| 🔥 Svelte App | ✅ **Full Showcase** | ✅ User state | ✅ Employee display | ✅ Event feed | ✅ Load/Broadcast/Clear |

### **Live Demo Features**
1. **Login Synchronization**: Login in auth app → All apps receive user state
2. **Visual State Showcase**: 9 apps display comprehensive shared state UI
3. **Employee Data Loading**: Click "Load Employees" → Data appears in all showcases
4. **Cross-App Broadcasting**: Click "Broadcast" → Messages appear in other apps
5. **Real-time Updates**: All state changes propagate instantly across frameworks
6. **Interactive Notifications**: Visual popup notifications for cross-app messages
7. **Console Logging**: Each app logs received events with unique emojis

## 🚀 Features

- **Framework Agnostic**: Multiple frontend frameworks coexisting
- **Independent Deployment**: Each microfrontend can be deployed separately
- **Multiple Loading Strategies**: Local, NPM packages, GitHub Pages, or AWS S3
- **Dynamic Mode Switching**: Change loading strategy without code changes
- **Centralized Version Management**: All packages synchronized automatically
- **NPM Publishing**: Automated publishing with version management
- **Environment-Driven Configuration**: AWS and GitHub settings via environment variables
- **Automated GitHub Deployment**: Auto-creates repos and deploys in production mode
- **Dual GitHub Modes**: Development (read existing) vs Production (create & deploy)
- **Shared Dependencies**: Common libraries managed efficiently
- **Authentication Flow**: Centralized login system
- **Routing**: Client-side routing across applications
- **Hot Reloading**: Development-friendly setup
- **ESLint Integration**: Code quality and consistency across all packages
- **🔄 RxJS State Management**: Real-time cross-microfrontend communication
- **📊 Shared Employee API**: JSON data accessible at `/employees.json`
- **🎪 Event Broadcasting**: Apps can send/receive events across frameworks
- **⚡ Live State Synchronization**: Login/logout updates all apps instantly
- **🔧 OpenSSL Compatibility**: Automatic Node.js 18+ compatibility via cross-env

## Prerequisites

- Node.js (v18.0.0 or higher)
- npm (v8.0.0 or higher)

## Quick Start

### AWS Setup Workflow (Recommended)

For AWS deployment with CloudFront CDN:

```bash
# 1. Setup S3 with full public configuration
npm run s3:setup:public

# 2. Setup CloudFront with SPA optimization  
npm run cloudfront:setup:spa

# 3. Deploy with CDN invalidation
npm run trigger:aws:s3
```

**Current Setup:**
- 🌍 **CloudFront CDN**: https://d3oyknhmr5oulj.cloudfront.net/
- 📦 **S3 Bucket**: single-spa-demo-774145483743
- 🆔 **Distribution ID**: E22CAYA3V9WRA9
- 🔒 **Features**: HTTPS, Custom error pages, JS caching, Gzip compression

### Launcher Scripts (Recommended)

#### Enhanced Mode-Aware Launcher (`run.sh` / `run.bat`)

**Basic Usage:**
```bash
# Linux/Mac
./run.sh [mode] [environment] [--clean] [--fix-network] [--skip-install] [--skip-build] [--offline]
# Windows
run.bat [mode] [environment] [--clean] [--fix-network] [--skip-install] [--skip-build] [--offline]
```

**Parameters:**
- **Mode** (first parameter): `local` (default), `npm`, `nexus`, `github`, `aws`
- **Environment** (second parameter): `dev` (default), `prod`
- **Options:**
  - `--clean`: Cleanup node_modules and package-lock.json (default: off)
  - `--fix-network`: Configure npm for problematic networks (default: off)
  - `--skip-install`: Skip npm install/ci for faster restarts (default: off)
  - `--skip-build`: Skip build process for faster restarts (default: off)
  - `--offline`: Use local dependencies instead of CDN (local/nexus only, default: off)

**Available Modes:**
- `local` - Local development with SystemJS
- `npm` - Uses NPM packages directly
- `nexus` - Uses Nexus private registry packages
- `github` - Loads from GitHub Pages
- `aws` - Loads from AWS S3 using import map

**Available Environments:**
- `dev` - Development build with hot reload
- `prod` - Production build with optimizations

**Examples:**
```bash
# Development (default)
./run.sh local dev
./run.sh local        # dev is default

# Fast restarts (skip install/build)
./run.sh local prod --skip-install --skip-build
./run.sh npm dev --skip-install

# Offline mode (no internet required)
./run.sh local prod --offline
./run.sh nexus dev --offline

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
run.bat local prod --offline
run.bat nexus dev --skip-install --skip-build
```

#### Quick Development Launcher (`dev-all.sh` / `dev-all.bat`)

**Always launches all applications** for immediate development:

```bash
# Windows
dev-all.bat

# Linux/Mac
./dev-all.sh
```

### Manual Setup

```bash
# 1. Install Dependencies
npm run install:all

# 2. Build All Applications
npm run build:all

# 3. Start Development Server
npm run serve:root
```

## Development Workflow

### Mode Selection

**URL Parameters (Temporary):**
```
http://localhost:8080?mode=local    # Local development
http://localhost:8080?mode=npm      # NPM packages
http://localhost:8080?mode=nexus    # Nexus private registry
http://localhost:8080?mode=github   # GitHub Pages
http://localhost:8080?mode=aws      # AWS S3
```

**Browser Console (Persistent):**
```javascript
localStorage.setItem('spa-mode', 'npm');     // Switch to NPM
localStorage.setItem('spa-mode', 'nexus');   // Switch to Nexus
localStorage.setItem('spa-mode', 'github');  // Switch to GitHub
localStorage.setItem('spa-mode', 'aws');     // Switch to AWS S3
localStorage.setItem('spa-mode', 'local');   // Switch to local
// Then refresh the page
```

### Application Routes

1. **Start Development**: Choose your launcher based on needs:
   - `./run.sh` - Mode-aware with setup/cleanup
   - `./dev-all.sh` - Quick development start
2. **Access Application**: Open http://localhost:8080
3. **Stop Development**: Run stop script to kill all processes
4. **Navigate Routes**:
   - `/` - Home (AngularJS)
   - `/login` - Authentication (Vue)
   - `/angular/*` - Angular features
   - `/react/*` - React features
   - `/vue/*` - Vue features
   - `/vanilla/*` - Vanilla JavaScript features
   - `/webcomponents/*` - Web Components features
   - `/typescript/*` - TypeScript features
   - `/jquery/*` - jQuery features
   - `/svelte/*` - Svelte features

### Hot Reload Development

For external deployment modes, use hot reload scripts to automatically sync changes:

**AWS S3 Hot Sync:**
```bash
# Terminal 1: Start application
./run.sh aws dev

# Terminal 2: Start hot sync (auto-uploads changes to S3)
npm run aws:hot-sync
```

**GitHub Hot Sync:**
```bash
# Terminal 1: Start application  
./run.sh github dev

# Terminal 2: Start hot sync (auto-deploys to GitHub repos)
npm run github:hot-sync
```

## Deployment

### 📋 Deployment Methods Overview

This project supports multiple deployment strategies with different execution contexts and use cases. For detailed information, see [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md).

#### Quick Deployment Reference

| Method | Command | Execution | Speed | Use Case |
|--------|---------|-----------|-------|----------|
| **AWS S3** | `npm run deploy:aws:prod` | Local | ⚡ Fast | Quick AWS deployment |
| **GitHub Pages** | `npm run deploy:github:all` | Local | 🐌 Slower | Local GitHub deployment |
| **AWS via Actions** | `npm run trigger:deploy:aws` | GitHub Actions | 🔄 Medium | CI/CD AWS pipeline |
| **GitHub via Actions** | `npm run trigger:deploy:github` | GitHub Actions | 🔄 Medium | CI/CD GitHub pipeline |
| **GitHub Parallel** | `npm run trigger:github:pages` | GitHub CLI | ⚡ Fast | **Recommended GitHub** |

#### Recommended Deployment Methods

**For AWS S3**: `npm run deploy:aws:prod`
- Fastest and most reliable
- Direct upload from local machine
- Single operation deploys everything

**For GitHub Pages**: `npm run trigger:github:pages`
- Parallel execution (fastest)
- Most reliable with retry logic
- Production-ready with proper error handling

### Deployment Modes

This project supports 5 different deployment modes, each with specific configuration and use cases:

#### **1. Local Mode** 🏠
```bash
# Configuration
SPA_MODE=local
SPA_ENV=dev|prod

# URLs
Dev:  http://localhost:4201-4211/app-name.js
Prod: /app-name.js (served from root server)

# Use Case: Full development environment
```

#### **2. NPM Mode** 📦
```bash
# Configuration  
SPA_MODE=npm
Requires: npm login, published packages

# URLs (via unpkg CDN)
https://unpkg.com/@cesarchamal/single-spa-auth-app@latest/dist/bundle.js

# Use Case: Public package distribution
```

#### **3. Nexus Mode** 🏢
```bash
# Configuration
SPA_MODE=nexus
Requires: Nexus registry access, authentication

# URLs
https://nexus-registry.company.com/@cesarchamal/single-spa-auth-app@latest/dist/bundle.js

# Use Case: Private enterprise registry
```

#### **4. GitHub Mode** 🐙
```bash
# Configuration
SPA_MODE=github
GITHUB_TOKEN=ghp_xxxxxxxxxxxxx
GITHUB_USERNAME=cesarchamal

# URLs
https://cesarchamal.github.io/single-spa-auth-app/single-spa-auth-app.js

# Use Case: GitHub Pages hosting
```

#### **5. AWS Mode** ☁️
```bash
# Configuration
SPA_MODE=aws
S3_BUCKET=single-spa-demo-774145483743
AWS_REGION=eu-central-1
ORG_NAME=cesarchamal

# URLs
Website: http://bucket.s3-website,region.amazonaws.com
Import Map: https://bucket.s3.region.amazonaws.com/@cesarchamal/importmap.json

# Use Case: AWS S3 static website hosting
```

## NPM Package Publishing

This project supports publishing all microfrontends as NPM packages for distribution and reuse.

### Publishing Scripts Comparison

| Script | Process | Registry | Use Case |
|--------|---------|----------|----------|
| `publish:all` | NPM → Nexus (sequential) | Both registries | Publish to both NPM and Nexus |
| `publish:npm:all` | Build → Publish → Fix → Switch | NPM only | Complete NPM workflow |
| `publish:nexus:all` | Build → Publish → Fix → Switch | Nexus only | Complete Nexus workflow |

### Publishing Workflow

**NPM Registry (with NPM_TOKEN):**
```bash
# 1. Set NPM automation token
export NPM_TOKEN=npm_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# 2. Test authentication (optional)
npm run test:npm:auth

# 3. Publish packages with version bump
npm run publish:npm:patch    # Bug fixes (0.1.0 → 0.1.1)
npm run publish:npm:minor    # New features (0.1.0 → 0.2.0)
npm run publish:npm:major    # Breaking changes (0.1.0 → 1.0.0)

# 4. Complete workflow (recommended)
npm run publish:npm:all      # Build → Publish → Fix → Switch

# 5. Test published packages
npm run mode:npm && npm run serve:npm
```

**Nexus Registry (with .npmrc.nexus):**
```bash
# 1. Configure .npmrc.nexus with authentication
# registry=http://localhost:8081/repository/npm-group/
# //localhost:8081/repository/npm-group/:_auth=<base64-user:pass>

# 2. Test authentication (optional)
npm run test:nexus:auth

# 3. Complete workflow (recommended)
npm run publish:nexus:all    # Build → Publish → Fix → Switch

# 4. Test published packages
npm run mode:nexus && npm run serve:nexus
```

**Both Registries:**
```bash
# Publish to both NPM and Nexus sequentially
npm run publish:all
```

For detailed publishing information, see [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md#npm-nexus-package-publishing).

## Technology Stack

### Frontend Technologies
- **Single-SPA**: Microfrontend orchestration
- **Angular 8**: Modern Angular framework
- **React 16**: React library with hooks
- **Vue.js 2**: Progressive JavaScript framework
- **AngularJS 1.x**: Legacy Angular for comparison
- **Vanilla JavaScript**: ES2020+ with native APIs
- **Web Components**: Lit framework with Shadow DOM
- **TypeScript**: Strict typing and compile-time validation
- **jQuery 3.6**: Legacy library integration
- **Svelte 3**: Compile-time optimized reactive framework
- **Bootstrap 4**: CSS framework
- **FontAwesome**: Icon library across all apps
- **SystemJS**: Module loader

### Build Tools
- **Webpack 4**: Module bundler
- **Babel**: JavaScript transpiler
- **ESLint**: Code linting with framework-specific configurations
- **TypeScript Compiler**: Type checking and transpilation
- **Svelte Compiler**: Compile-time optimization
- **Various CLI tools**: Angular CLI, Vue CLI, Create React App

## Configuration

### Port Configuration

| Application | Port | URL |
|-------------|------|-----|
| Root | 8080 | http://localhost:8080 |
| Auth | 4201 | http://localhost:4201 |
| Layout | 4202 | http://localhost:4202 |
| Home | 4203 | http://localhost:4203 |
| Angular | 4204 | http://localhost:4204 |
| Vue | 4205 | http://localhost:4205 |
| React | 4206 | http://localhost:4206 |
| Vanilla | 4207 | http://localhost:4207 |
| Web Components | 4208 | http://localhost:4208 |
| TypeScript | 4209 | http://localhost:4209 |
| jQuery | 4210 | http://localhost:4210 |
| Svelte | 4211 | http://localhost:4211 |

### GitHub Pages Configuration

The GitHub mode requires environment variables for GitHub configuration:

```bash
# Required for GitHub mode
GITHUB_TOKEN=ghp_your_github_personal_access_token
GITHUB_USERNAME=your-github-username

# Optional: Override organization name
ORG_NAME=your-organization-name
```

### AWS S3 Configuration

The AWS mode requires environment variables for S3 configuration:

```bash
# Required for AWS mode
S3_BUCKET=your-s3-bucket-name
AWS_REGION=your-aws-region
ORG_NAME=your-organization-name

# Optional: CloudFront CDN (auto-configured by setup scripts)
CLOUDFRONT_DISTRIBUTION_ID=E1234567890ABC

# Optional: Override full import map URL
IMPORTMAP_URL=https://custom-bucket.s3.amazonaws.com/@myorg/importmap.json
```

### Custom Domain Configuration

To use a custom domain with CloudFront (e.g., `microfrontends.yourdomain.com`):

```bash
# 1. Create SSL certificate in AWS Certificate Manager (ACM)
aws acm request-certificate --domain-name microfrontends.yourdomain.com --validation-method DNS

# 2. Update CloudFront distribution to use custom domain
# Use AWS Console or CLI to add alternate domain name and SSL certificate

# 3. Update DNS records to point to CloudFront
# Create CNAME record: microfrontends.yourdomain.com -> d1234567890abc.cloudfront.net

# Environment variable
CUSTOM_DOMAIN=microfrontends.yourdomain.com
```

**Note**: Custom domain setup requires:
- Valid SSL certificate in AWS Certificate Manager
- DNS configuration pointing to CloudFront distribution
- CloudFront distribution configured with custom domain and SSL certificate

## Available Scripts

### Core Scripts
- `npm start` - Start development environment
- `npm run build:all` - Build all applications
- `npm run install:all` - Install all dependencies
- `npm run clean` - Clean all node_modules
- `npm run lint` - Lint and fix all JavaScript/JSON files

### Publishing Scripts
- `npm run publish:all` - Publish to both NPM and Nexus registries
- `npm run publish:npm:all` - Complete NPM workflow (build → publish → fix → switch)
- `npm run publish:nexus:all` - Complete Nexus workflow (build → publish → fix → switch)
- `npm run publish:npm:patch` - Publish to NPM with patch version bump
- `npm run publish:nexus:patch` - Publish to Nexus with patch version bump

### Deployment Scripts
- `npm run deploy:aws:prod` - Deploy to AWS S3
- `npm run deploy:github:all` - Deploy to GitHub Pages
- `npm run trigger:actions` - Trigger all GitHub Actions workflows
- `npm run trigger:deploy:aws` - Trigger AWS deployment via GitHub Actions
- `npm run trigger:deploy:github` - Trigger GitHub deployment via GitHub Actions
- `npm run trigger:github:pages` - Trigger robust GitHub Pages deployment
- `npm run trigger:aws:s3` - Trigger advanced AWS S3 deployment with CDN

### AWS Setup Scripts
- `npm run s3:setup` - Basic S3 bucket setup
- `npm run s3:setup:basic` - Basic S3 bucket
- `npm run s3:setup:cors` - S3 bucket with CORS configuration
- `npm run s3:setup:public` - Full public S3 setup (recommended)
- `npm run cloudfront:setup` - Basic CloudFront distribution
- `npm run cloudfront:setup:basic` - Basic CloudFront distribution
- `npm run cloudfront:setup:spa` - SPA-optimized CloudFront (recommended)
- `npm run cloudfront:setup:full` - Full CloudFront setup with custom domain

### Mode Switching Scripts
- `npm run mode:local` - Switch to local development mode
- `npm run mode:npm` - Switch to NPM packages mode
- `npm run mode:nexus` - Switch to Nexus private registry mode
- `npm run mode:github` - Switch to GitHub Pages mode
- `npm run mode:aws` - Switch to AWS S3 mode
- `npm run mode:status` - Check current mode status

### Version Management Scripts
- `npm run version:current` - Show current versions of all packages
- `npm run version:bump:patch` - Bump patch version (0.1.0 → 0.1.1)
- `npm run version:bump:minor` - Bump minor version (0.1.0 → 0.2.0)
- `npm run version:bump:major` - Bump major version (0.1.0 → 1.0.0)
- `npm run version:set 1.2.3` - Set specific version for all packages

### Status Checker Scripts
- `npm run check:local` - Check local development servers and built files
- `npm run check:npm` - Check NPM packages and CDN accessibility
- `npm run check:nexus` - Check Nexus registry and package availability
- `npm run check:github` - Check GitHub repositories and Pages status
- `npm run check:aws` - Check AWS S3 bucket and file accessibility
- `npm run check:cdn` - Check CloudFront CDN status and S3 origin health

### Hot Reload Scripts
- `npm run aws:hot-sync` - Auto-sync file changes to AWS S3 bucket
- `npm run github:hot-sync` - Auto-deploy file changes to GitHub repositories

### Offline Mode Scripts
- `npm run offline:setup` - Download CDN dependencies locally (one-time setup)
- `npm run offline:serve` - Run in offline mode with local dependencies
- `npm run offline:build` - Build and serve in offline mode

### Authentication Testing Scripts
- `npm run test:npm:auth` - Test NPM authentication with NPM_TOKEN
- `npm run test:nexus:auth` - Test Nexus authentication with .npmrc.nexus

For a complete list of all available scripts, see the individual application directories.

## Troubleshooting

### Common Issues

1. **Port Conflicts**: Ensure all required ports are available
2. **Node Version**: Use Node.js v18 or higher
3. **OpenSSL Compatibility**: Automatic handling via launcher scripts
4. **Memory Issues**: Increase Node.js memory limit if needed
5. **CORS Issues**: Applications are configured with CORS support
6. **Registry Issues**: Run scripts automatically switch NPM registries

### Network Issues (ECONNRESET errors)
```bash
# Apply network fixes for unstable connections
./run.sh local dev --fix-network
run.bat npm prod --fix-network

# Use offline mode if network is completely unavailable
./run.sh local prod --offline
```

### Clean Installation
```bash
# Remove node_modules and package-lock.json before install
./run.sh local dev --clean
run.bat aws prod --clean
```

### Offline Mode (No Internet Required)
```bash
# First time setup - download dependencies
npm run offline:setup

# Run without internet connection
./run.sh local prod --offline
./run.sh nexus dev --offline

# Quick offline development
npm run offline:serve
```

### NPM Publishing Issues
```bash
# Test NPM authentication with token
export NPM_TOKEN=npm_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
npm run test:npm:auth

# Switch back to local mode if NPM packages fail
npm run mode:local
```

### Registry Configuration Issues
```bash
# Quick registry switching
npm run registry:npm      # Switch to NPM
npm run registry:nexus    # Switch to Nexus
npm run registry:status   # Check current
npm run registry:restore  # Restore original
```

### Debug Mode

Enable debug logging by setting environment variables:
```bash
DEBUG=single-spa:* npm run serve
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run linting: `npm run lint`
5. Test your changes
6. Submit a pull request

## License

MIT License - see individual LICENSE files in each application directory.

## Authors

- Cesar Francisco Chavez Maldonado (Original author)
- Various contributors

## Documentation

### Project Guides
- [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) - Comprehensive deployment and publishing guide
- [LAUNCHER.md](LAUNCHER.md) - Launcher scripts and configuration guide
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions
- [MODE-SWITCHING.md](MODE-SWITCHING.md) - Switching between deployment modes
- [VERSION-MANAGEMENT.md](VERSION-MANAGEMENT.md) - Version synchronization and management
- [DEPENDENCY-FIXES.md](DEPENDENCY-FIXES.md) - Dependency version fixes

### Framework Documentation
- [Single-SPA Documentation](https://single-spa.js.org/)
- [Angular Documentation](https://angular.io/)
- [React Documentation](https://reactjs.org/)
- [Vue.js Documentation](https://vuejs.org/)
- [Svelte Documentation](https://svelte.dev/)
- [TypeScript Documentation](https://www.typescriptlang.org/)
- [Lit Documentation](https://lit.dev/)
- [jQuery Documentation](https://jquery.com/)

### Microfrontends Resources
- [Microfrontends.info](https://microfrontends.info/)
- [Micro Frontends by Martin Fowler](https://martinfowler.com/articles/micro-frontends.html)
- [Building Micro-Frontends Book](https://www.buildingmicrofrontends.com/)

### Build Tools & Libraries
- [Webpack Documentation](https://webpack.js.org/)
- [Babel Documentation](https://babeljs.io/)
- [SystemJS Documentation](https://github.com/systemjs/systemjs)
- [FontAwesome Documentation](https://fontawesome.com/)
- [Bootstrap Documentation](https://getbootstrap.com/)

### Version Management & Publishing
- [Semantic Versioning](https://semver.org/)
- [NPM Publishing Guide](https://docs.npmjs.com/packages-and-modules/contributing-packages-to-the-registry)
- [NPM Scopes](https://docs.npmjs.com/about-scopes)