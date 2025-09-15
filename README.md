# Demo Microfrontends with Single-SPA

A comprehensive demonstration of microfrontend architecture using Single-SPA framework, showcasing multiple frontend technologies working together in a unified application.

## ✍🏻 Motivation

This application demonstrates a comprehensive microfrontend architecture using Single-SPA with multiple deployment strategies including local development, NPM packages, Nexus private registry, GitHub Pages, and AWS S3. It showcases 12 different microfrontends built with various frameworks and technologies.

## ▶️ Live Demo

**Live Demo:** [http://single-spa-demo-774145483743.s3-website.eu-central-1.amazonaws.com/](http://single-spa-demo-774145483743.s3-website.eu-central-1.amazonaws.com/)

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
| 🎯 Root App | Single-SPA | 8080 | Orchestrator | [single-spa-root](https://github.com/cesarchamal/single-spa-root) |

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

## Microfrontends

### 1. Root Application (`single-spa-root`)
- **Framework**: Single-SPA orchestrator
- **Port**: 8080
- **Purpose**: Manages routing and application lifecycle
- **Technologies**: JavaScript, Webpack, SystemJS
- **Build Scripts**: `build`, `build:dev`, `build:prod`, `build:aws:prod`

### 2. Authentication App (`single-spa-auth-app`)
- **Framework**: Vue.js
- **Port**: 4201
- **Purpose**: Login functionality
- **Route**: `/login`
- **Build Scripts**: `build`, `build:dev`, `build:prod`

### 3. Layout App (`single-spa-layout-app`)
- **Framework**: Vue.js
- **Port**: 4202
- **Purpose**: Shared header, navbar, and footer
- **Active**: All routes except `/login`
- **Build Scripts**: `build`, `build:dev`, `build:prod`

### 4. Home App (`single-spa-home-app`)
- **Framework**: AngularJS 1.x
- **Port**: 4203
- **Purpose**: Landing page
- **Route**: `/`
- **Build Scripts**: `build`, `build:dev`, `build:prod`

### 5. Angular App (`single-spa-angular-app`)
- **Framework**: Angular 8
- **Port**: 4204
- **Purpose**: Feature-rich application with routing
- **Route**: `/angular/*`
- **Build Scripts**: `build`, `build:dev`, `build:prod`

### 6. React App (`single-spa-react-app`)
- **Framework**: React 16
- **Port**: 4206
- **Purpose**: React-based features
- **Route**: `/react/*`
- **Build Scripts**: `build`, `build:dev`, `build:prod`

### 7. Vue App (`single-spa-vue-app`)
- **Framework**: Vue.js 2
- **Port**: 4205
- **Purpose**: Vue-based features
- **Route**: `/vue/*`
- **Build Scripts**: `build`, `build:dev`, `build:prod`

### 8. Vanilla App (`single-spa-vanilla-app`)
- **Framework**: Pure JavaScript (ES2020+)
- **Port**: 4207
- **Purpose**: Modern vanilla JS with native APIs
- **Route**: `/vanilla/*`
- **Build Scripts**: `build`, `build:dev`, `build:prod`

### 9. Web Components App (`single-spa-webcomponents-app`)
- **Framework**: Lit + Web Components
- **Port**: 4208
- **Purpose**: Browser-native components with Shadow DOM
- **Route**: `/webcomponents/*`
- **Build Scripts**: `build`, `build:dev`, `build:prod`

### 10. TypeScript App (`single-spa-typescript-app`)
- **Framework**: TypeScript with strict typing
- **Port**: 4209
- **Purpose**: Type-safe development and compile-time validation
- **Route**: `/typescript/*`
- **Build Scripts**: `build`, `build:dev`, `build:prod`

### 11. jQuery App (`single-spa-jquery-app`)
- **Framework**: jQuery 3.6.0 (Legacy library)
- **Port**: 4210
- **Purpose**: Legacy library integration and migration strategies
- **Route**: `/jquery/*`
- **Build Scripts**: `build`, `build:dev`, `build:prod`

### 12. Svelte App (`single-spa-svelte-app`)
- **Framework**: Svelte 3 (Compile-time optimized)
- **Port**: 4211
- **Purpose**: Reactive programming with minimal runtime overhead
- **Route**: `/svelte/*`
- **Build Scripts**: `build`, `build:dev`, `build:prod`

## Prerequisites

- Node.js (v18.0.0 or higher)
- npm (v8.0.0 or higher)

## Quick Start

### Launcher Scripts (Recommended)

#### Enhanced Mode-Aware Launcher (`run.sh` / `run.bat`)

**Basic Usage:**
```bash
# Linux/Mac
./run.sh [mode] [environment] [--clean] [--fix-network]
# Windows
run.bat [mode] [environment] [--clean] [--fix-network]
```

**Parameters:**
- **Mode** (first parameter): `local` (default), `npm`, `nexus`, `github`, `aws`
- **Environment** (second parameter): `dev` (default), `prod`
- **Options:**
  - `--clean`: Cleanup node_modules and package-lock.json (default: off)
  - `--fix-network`: Configure npm for problematic networks (default: off)

**Available Modes:**
- `local` - Local development with SystemJS
- `npm` - Uses NPM packages directly
- `nexus` - Uses Nexus private registry packages
- `github` - Loads from GitHub Pages
- `aws` - Loads from AWS S3 using import map

**Available Environments:**
- `dev` - Development build with hot reload
- `prod` - Production build with optimizations

**What Each Combination Launches:**

| Mode | Environment | Apps Running | Build Type | Publishing | Use Case |
|------|-------------|-------------|------------|------------|----------|
| `local` | `dev` | All 12 apps | Development | None | Full development environment |
| `local` | `prod` | Root app only | Production | None | Test production build locally |
| `npm` | `dev` | Root app only | Development | Version only | Test NPM package loading |
| `npm` | `prod` | Root app only | Production | All 12 packages | Publish + test NPM packages |
| `nexus` | `dev` | Root app only | Development | Version only | Test Nexus private registry |
| `nexus` | `prod` | Root app only | Production | All 12 packages | Publish + test Nexus packages |
| `github` | `dev` | Root app only | Development | None | Read from existing GitHub Pages |
| `github` | `prod` | Root app only | Production | Deploy to GitHub | Create repos + deploy to GitHub Pages |
| `aws` | `dev` | Root app only | Development | None | Test AWS S3 loading |
| `aws` | `prod` | Root app only | Production | Deploy to S3 | Test AWS S3 in production |

**Examples:**
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

#### Quick Development Launcher (`dev-all.sh` / `dev-all.bat`)

**Always launches all applications** for immediate development:

```bash
# Windows
dev-all.bat

# Linux/Mac
./dev-all.sh
```

**Features:**
- No setup/cleanup steps
- Always runs all 12 applications
- Quick start for development
- Uses ports 8080, 4201-4211

### Troubleshooting Options

**Network Issues (ECONNRESET errors):**
```bash
# Apply network fixes for unstable connections
./run.sh local dev --fix-network
run.bat npm prod --fix-network
```

**Clean Installation:**
```bash
# Remove node_modules and package-lock.json before install
./run.sh local dev --clean
run.bat aws prod --clean
```

**Combined Options:**
```bash
# Clean install with network fixes
./run.sh local dev --clean --fix-network
run.bat npm prod --clean --fix-network
```

**What `--fix-network` does:**
- Sets npm fetch timeout to 10 minutes
- Configures retry parameters for better resilience
- Disables audit and fund checks to reduce network overhead
- Helps resolve `ECONNRESET` and timeout issues

**What `--clean` does:**
- Removes `node_modules` directories
- Removes `package-lock.json` files
- Clears npm cache
- Forces fresh dependency installation

### Manual Setup

```bash
# 1. Install Dependencies
npm run install:all

# 2. Build All Applications
npm run build:all

# 3. Start Development Server
npm run serve:root
```

### Production Build
```bash
# Manual production build
npm run build
npm start

# Or use launcher script
./run.sh local prod
run.bat local prod
```

## Scripts Organization

### Root Scripts (User-facing)
- `run.sh` / `run.bat` - Main launcher scripts
- `stop.sh` / `stop.bat` - Stop all services

### Utility Scripts (`scripts/` folder)
- `deploy-s3.sh` / `deploy-s3.bat` - AWS S3 deployment
- `deploy-github.sh` / `deploy-github.bat` - GitHub Pages deployment
- `create-github-repo.sh` / `create-github-repo.bat` - GitHub repository creation
- `github-repo-server.js` - GitHub API server for repository management
- `switch-mode.js` - Mode switching utility (local/npm/nexus/github/aws)
- `version-manager.js` - Centralized version management
- `publish-npm.sh` / `publish-npm.bat` - NPM publishing automation
- `publish-nexus.sh` / `publish-nexus.bat` - Nexus publishing automation
- `setup-s3.sh` / `setup-s3.bat` - S3 bucket setup and configuration
- `trigger-*.sh` / `trigger-*.bat` - GitHub Actions deployment triggers
- `update-importmap.mjs` - Import map management for deployments
- `test-npm-auth.sh` / `test-npm-auth.bat` - NPM authentication testing
- `test-nexus-auth.sh` / `test-nexus-auth.bat` - Nexus authentication testing
- `aws-hot-sync.sh` / `aws-hot-sync.bat` - AWS S3 hot reload sync
- `github-hot-sync.sh` / `github-hot-sync.bat` - GitHub hot reload sync
- `check-*.sh` / `check-*.bat` - Status checker scripts for all deployment modes

## Individual Application Setup

### Root Application
```bash
cd single-spa-root
npm install
npm run serve:root
```

### Each Microfrontend
```bash
cd [app-directory]
npm install
npm run build
```

## Available Scripts

### GitHub Pages Deployment Scripts

#### GitHub Pages Deployment Workflows

This project includes two GitHub Actions workflows for deploying to GitHub Pages:

**1. Simple GitHub Pages Deploy** (`deploy-github-simple.yml`):
- **Trigger**: Automatic on `push` to `main` branch
- **Architecture**: Single job, sequential deployment
- **Process**: Builds all apps first, then deploys using bash script
- **Speed**: ~15-20 minutes (sequential)
- **Best For**: Development/testing, automatic deployment

**2. Robust GitHub Pages Deploy** (`deploy-github-pages.yml`):
- **Trigger**: Manual via `workflow_dispatch`
- **Architecture**: Matrix strategy with 12 parallel jobs
- **Process**: Each app builds and deploys independently
- **Speed**: ~5-8 minutes (parallel)
- **Best For**: Production deployments, reliability

#### Deployment Comparison

| Feature | Simple Deploy | Robust Deploy |
|---------|---------------|---------------|
| **Jobs** | 1 sequential job | 12 parallel jobs |
| **Build Time** | 15-20 minutes | 5-8 minutes |
| **Failure Impact** | One failure = total failure | Isolated failures |
| **Repository Creation** | Via bash script | Via GitHub API |
| **Import Map Updates** | Single attempt | 3 retry attempts |
| **GitHub Pages Setup** | Manual API calls | Automatic |
| **Resource Efficiency** | Low (sequential) | High (parallel) |
| **Error Handling** | Basic | Advanced |
| **Monitoring** | Single log stream | Per-app logs |

#### Triggering GitHub Pages Deployment

**Option 1: GitHub Web Interface**
1. Go to repository **Actions** tab
2. Find **"Deploy to GitHub Pages (Manual)"** workflow
3. Click **"Run workflow"** button

**Option 2: GitHub CLI**
```bash
# Trigger robust deployment (recommended)
npm run trigger:github:pages

# Or use GitHub CLI directly
gh workflow run deploy-github-pages.yml
```

**Option 3: Automatic (Simple)**
- Simple deployment triggers automatically on every push to `main`
- No manual intervention required

### Trigger Scripts
- `npm run trigger:actions` - Trigger all GitHub Actions deployments
- `npm run trigger:deploy:aws` - Trigger AWS S3 deployment
- `npm run trigger:deploy:github` - Trigger GitHub Pages deployment
- `npm run trigger:github:pages` - Trigger robust GitHub Pages deployment (manual)

#### Individual App Trigger Scripts
- `npm run trigger:root` - Trigger GitHub Actions for root app only
- `npm run trigger:auth` - Trigger GitHub Actions for auth app only
- `npm run trigger:layout` - Trigger GitHub Actions for layout app only
- `npm run trigger:home` - Trigger GitHub Actions for home app only
- `npm run trigger:angular` - Trigger GitHub Actions for Angular app only
- `npm run trigger:vue` - Trigger GitHub Actions for Vue app only
- `npm run trigger:react` - Trigger GitHub Actions for React app only
- `npm run trigger:vanilla` - Trigger GitHub Actions for vanilla app only
- `npm run trigger:webcomponents` - Trigger GitHub Actions for webcomponents app only
- `npm run trigger:typescript` - Trigger GitHub Actions for TypeScript app only
- `npm run trigger:jquery` - Trigger GitHub Actions for jQuery app only
- `npm run trigger:svelte` - Trigger GitHub Actions for Svelte app only

### Status Checker Scripts
- `npm run check:local` - Check local development servers and built files
- `npm run check:npm` - Check NPM packages and CDN accessibility
- `npm run check:nexus` - Check Nexus registry and package availability
- `npm run check:github` - Check GitHub repositories and Pages status
- `npm run check:aws` - Check AWS S3 bucket and file accessibility

### Dependency Fix Scripts
- `npm run fix:auto` - Auto-detect mode and fix dependencies
- `npm run fix:auto:npm` - Auto-fix for NPM mode
- `npm run fix:auto:nexus` - Auto-fix for Nexus mode
- `npm run fix:nexus:deps` - Fix Nexus dependency version mismatches
- `npm run fix:nexus:deps:root` - Fix root app Nexus dependencies
- `npm run fix:npm:deps` - Fix NPM dependency version mismatches
- `npm run fix:npm:deps:root` - Fix root app NPM dependencies

### Authentication Testing Scripts
- `npm run test:npm:auth` - Test NPM authentication with NPM_TOKEN
- `npm run test:nexus:auth` - Test Nexus authentication with .npmrc.nexus
- `./scripts/test-npm-auth.sh` - Direct script execution (Linux/macOS/Git Bash)
- `scripts\test-npm-auth.bat` - Direct script execution (Windows)
- `./scripts/test-nexus-auth.sh` - Direct script execution (Linux/macOS/Git Bash)
- `scripts\test-nexus-auth.bat` - Direct script execution (Windows)

### Hot Reload Scripts
- `npm run aws:hot-sync` - Auto-sync file changes to AWS S3 bucket
- `npm run github:hot-sync` - Auto-deploy file changes to GitHub repositories
- `./scripts/aws-hot-sync.sh` - Direct script execution (Linux/macOS/Git Bash)
- `scripts\aws-hot-sync.bat` - Direct script execution (Windows)
- `./scripts/github-hot-sync.sh` - Direct script execution (Linux/macOS/Git Bash)
- `scripts\github-hot-sync.bat` - Direct script execution (Windows)

### Registry Switching Scripts
- `npm run registry:npm` - Switch to NPM registry
- `npm run registry:nexus` - Switch to Nexus registry
- `npm run registry:status` - Check current registry
- `npm run registry:restore` - Restore original registry

### Mode-Specific Scripts
- `npm run serve:local:dev` - Start in local development mode
- `npm run serve:local:prod` - Start in local production mode
- `npm run serve:npm` - Start in NPM packages mode
- `npm run serve:nexus` - Start in Nexus private registry mode
- `npm run serve:github` - Start in GitHub Pages mode
- `npm run serve:aws` - Start in AWS S3 mode

### Mode Switching Scripts
- `npm run mode:npm` - Switch to NPM mode (after publishing)
- `npm run mode:local` - Switch back to local development mode
- `npm run mode:github` - Switch to GitHub Pages mode
- `npm run mode:aws` - Switch to AWS S3 mode
- `npm run mode:status` - Check current mode status

### Version Management Scripts
- `npm run version:current` - Show current versions of all packages
- `npm run version:bump:patch` - Bump patch version (0.1.0 → 0.1.1)
- `npm run version:bump:minor` - Bump minor version (0.1.0 → 0.2.0)
- `npm run version:bump:major` - Bump major version (0.1.0 → 1.0.0)
- `npm run version:set 1.2.3` - Set specific version for all packages
- `npm run version:reset` - Reset all packages to base version (default: 0.1.0)
- `npm run version:clean` - Remove _trigger fields from packages

### Publishing Scripts

#### NPM Registry Publishing
- `npm run publish:npm` - Publish to NPM (default: patch version, dev environment)
- `npm run publish:npm:patch` - Publish to NPM with patch version bump
- `npm run publish:npm:minor` - Publish to NPM with minor version bump
- `npm run publish:npm:major` - Publish to NPM with major version bump
- `npm run publish:npm:dev` - Version management only (no publishing)
- `npm run publish:npm:prod` - Publish all 12 packages (11 microfrontends + root app)
- `npm run publish:npm:nobump` - Publish without version bump
- `npm run publish:npm:prod:nobump` - Publish all packages without version bump

#### Nexus Registry Publishing
- `npm run publish:nexus` - Publish to Nexus (default: patch version, dev environment)
- `npm run publish:nexus:patch` - Publish to Nexus with patch version bump
- `npm run publish:nexus:minor` - Publish to Nexus with minor version bump
- `npm run publish:nexus:major` - Publish to Nexus with major version bump
- `npm run publish:nexus:dev` - Version management only (no publishing)
- `npm run publish:nexus:prod` - Publish all 12 packages (11 microfrontends + root app)
- `npm run publish:nexus:nobump` - Publish without version bump
- `npm run publish:nexus:prod:nobump` - Publish all packages without version bump

#### Publishing Mode Behavior
- **Dev Mode**: Only updates package versions, no actual publishing
- **Prod Mode**: Publishes all packages to registry for public/private access
- **Nobump Mode**: Publishes using current version without bumping

#### Version Control Workflow
```bash
# Set specific version then publish without bumping
npm run version:set 1.0.0
npm run publish:nexus:nobump

# Or let it auto-bump
npm run publish:nexus:patch  # 1.0.0 → 1.0.1
```

##### Individual Publishing Scripts

**NPM Individual Publishing:**
- `npm run publish:npm:root:patch` - Publish root app to NPM with patch version bump
- `npm run publish:npm:auth:patch` - Publish auth app to NPM with patch version bump
- `npm run publish:npm:layout:patch` - Publish layout app to NPM with patch version bump
- `npm run publish:npm:home:patch` - Publish home app to NPM with patch version bump
- `npm run publish:npm:angular:patch` - Publish Angular app to NPM with patch version bump
- `npm run publish:npm:vue:patch` - Publish Vue app to NPM with patch version bump
- `npm run publish:npm:react:patch` - Publish React app to NPM with patch version bump
- `npm run publish:npm:vanilla:patch` - Publish Vanilla app to NPM with patch version bump
- `npm run publish:npm:webcomponents:patch` - Publish Web Components app to NPM with patch version bump
- `npm run publish:npm:typescript:patch` - Publish TypeScript app to NPM with patch version bump
- `npm run publish:npm:jquery:patch` - Publish jQuery app to NPM with patch version bump
- `npm run publish:npm:svelte:patch` - Publish Svelte app to NPM with patch version bump

**Nexus Individual Publishing:**
- `npm run publish:nexus:root:patch` - Publish root app to Nexus with patch version bump
- `npm run publish:nexus:auth:patch` - Publish auth app to Nexus with patch version bump
- Similar pattern for all 12 apps with :patch, :minor, :major variants

**Version Variants Available:**
- `:patch` - Bug fixes (0.1.0 → 0.1.1)
- `:minor` - New features (0.1.0 → 0.2.0)
- `:major` - Breaking changes (0.1.0 → 1.0.0)

#### Backward-Compatible Aliases
- `npm run publish:all` - Publish all packages to NPM (alias for publish:npm)
- `npm run publish:patch` - Bump patch version and publish to NPM
- `npm run publish:minor` - Bump minor version and publish to NPM
- `npm run publish:major` - Bump major version and publish to NPM

### Build Scripts Overview

#### Build All 12 Applications (Root + 11 Microfrontends)
```bash
npm run build:apps         # Standard build (all 12 apps)
npm run build:apps:dev     # Development build (all 12 apps)
npm run build:apps:prod    # Production build (all 12 apps)
```

#### Build Only 11 Microfrontends (Excluding Root)
```bash
npm run build              # Standard build (11 microfrontends only)
npm run build:dev          # Development build (11 microfrontends only)
npm run build:prod         # Production build (11 microfrontends only)
```

#### Build Only Root Application
```bash
npm run build:root         # Standard root build
npm run build:root:dev     # Development root build
npm run build:root:prod    # Production root build
```

**Key Differences:**
- **`build:apps:*`** = Root app + 11 microfrontends (12 total applications)
- **`build:*`** = Only 11 microfrontends (excludes root application)
- **`build:root:*`** = Only root application (excludes microfrontends)

### Installation Scripts

#### Development vs CI Installation

**Development Installation (Flexible):**
```bash
npm run install:all        # Install all applications (development)
npm run install:root       # Install root app only
npm run install:apps       # Install all microfrontends
```

**CI Installation (Fast & Deterministic):**
```bash
npm run install:all:ci     # Install all applications (CI)
npm run install:root:ci    # Install root app only (CI)
npm run install:apps:ci    # Install all microfrontends (CI)
```

#### `npm ci` vs `npm install`

| Feature | `npm ci` (Clean Install) | `npm install` |
|---------|-------------------------|---------------|
| **Speed** | ⚡ 2x faster | 🐌 Slower |
| **Requirements** | Requires `package-lock.json` | Creates `package-lock.json` if missing |
| **Behavior** | Deletes `node_modules` first | Keeps existing `node_modules` |
| **Dependencies** | Installs exactly from lock file | Resolves from `package.json` |
| **Lock File** | Never modifies `package-lock.json` | Updates `package-lock.json` if needed |
| **Deterministic** | ✅ Exact reproducible builds | ❌ May get newer versions |
| **Sync Check** | Fails if package files out of sync | Flexible, resolves conflicts |

**When to Use Each:**

**Use `npm ci` for:**
- ✅ CI/CD pipelines
- ✅ Production deployments  
- ✅ Docker builds
- ✅ Exact reproducible builds

**Use `npm install` for:**
- ✅ Local development
- ✅ Adding new packages
- ✅ Updating dependencies
- ✅ Initial project setup

**Individual CI Installation Scripts:**
```bash
# Individual apps with CI
npm run install:auth:ci
npm run install:angular:ci
npm run install:react:ci
# ... (all 12 apps available)
```

### Root Project Scripts
- `npm run serve:root` - Start root development server
- `npm run clean` - Clean all node_modules
- `npm run clean:root` - Clean root application node_modules
- `npm run clean:apps` - Clean all microfrontend node_modules
- `npm start` - Start development environment
- `npm run lint` - Lint and fix all JavaScript/JSON files
- `npm run lint:check` - Check linting without fixing

### Individual App Scripts

**Installation Scripts:**
- `npm run install:root` - Install root app dependencies
- `npm run install:auth` - Install auth app dependencies
- `npm run install:layout` - Install layout app dependencies
- `npm run install:home` - Install home app dependencies
- `npm run install:angular` - Install Angular app dependencies
- `npm run install:vue` - Install Vue app dependencies
- `npm run install:react` - Install React app dependencies
- `npm run install:vanilla` - Install Vanilla app dependencies
- `npm run install:webcomponents` - Install Web Components app dependencies
- `npm run install:typescript` - Install TypeScript app dependencies
- `npm run install:jquery` - Install jQuery app dependencies
- `npm run install:svelte` - Install Svelte app dependencies

**Build Scripts (per app):**
- `npm run build:auth` / `npm run build:auth:dev` / `npm run build:auth:prod`
- `npm run build:layout` / `npm run build:layout:dev` / `npm run build:layout:prod`
- Similar patterns for: home, angular, vue, react, vanilla, webcomponents, typescript, jquery, svelte

**Root App Build Scripts:**
- `npm run build:root` - Build root app (standard)
- `npm run build:root:dev` - Build root app for development
- `npm run build:root:prod` - Build root app for production
- `npm run build:root:aws` - Build root app for AWS mode
- `npm run build:root:aws:dev` - Build root app for AWS development
- `npm run build:root:aws:prod` - Build root app for AWS production
- `npm run build:root:npm` - Build root app for NPM mode
- `npm run build:root:nexus` - Build root app for Nexus mode
- `npm run build:root:github` - Build root app for GitHub mode

**Serve Scripts:**
- `npm run serve:root` - Serve root app
- `npm run serve:auth` - Serve auth app individually
- Similar patterns for all other apps

**Clean Scripts (per app):**
- `npm run clean:auth` - Clean auth app node_modules
- `npm run clean:layout` - Clean layout app node_modules
- Similar patterns for all other apps

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

## Development Workflow

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

**Features:**
- **File watching** with `fswatch` (auto-installs on Linux/macOS)
- **Smart deployment** - only syncs changed applications
- **Cross-platform** - Linux, macOS, Windows, WSL support
- **Fallback polling** when `fswatch` unavailable

**Requirements:**
- **AWS**: `S3_BUCKET`, `AWS_REGION`, `ORG_NAME` environment variables
- **GitHub**: `GITHUB_USERNAME`, `GITHUB_API_TOKEN` environment variables

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

### Debug Console Messages

Each microfrontend logs mount/unmount events to the browser console:
- 🔐 Auth App mounted/unmounted
- 🎨 Layout App mounted/unmounted
- 🏠 Home App (AngularJS) mounted/unmounted
- 🅰️ Angular App mounted/unmounted
- 💚 Vue App mounted/unmounted
- ⚛️ React App mounted/unmounted
- 🍦 Vanilla JS App mounted/unmounted
- 🧩 Web Components App mounted/unmounted
- 📘 TypeScript App mounted/unmounted
- 💎 jQuery App mounted/unmounted
- 🔥 Svelte App mounted/unmounted

### Launcher Script Comparison

| Script | Setup/Cleanup | Mode Support | Apps Launched | Options | Best For |
|--------|---------------|--------------|---------------|---------|----------|
| `run.sh/bat` | ✅ Full setup | ✅ All modes | Mode-dependent | `--clean`, `--fix-network` | Production-like testing |
| `dev-all.sh/bat` | ❌ Minimal | ❌ Local only | Always all apps | None | Quick development |

## Port Configuration

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

## GitHub Pages Configuration

The GitHub mode requires environment variables for GitHub configuration:

```bash
# Required for GitHub mode
GITHUB_TOKEN=ghp_your_github_personal_access_token
GITHUB_USERNAME=your-github-username

# Optional: Override organization name
ORG_NAME=your-organization-name
```

### GitHub Mode Behavior

**Development Mode** (`github dev`):
- Reads from existing GitHub Pages repositories
- No repository creation or deployment
- Fast startup, minimal setup
- Requires repositories to already exist

**Production Mode** (`github prod`):
- Automatically creates GitHub repositories
- Builds and deploys all microfrontends
- Deploys root application for public access
- Creates fully public URL: `https://{username}.github.io/demo-microfrontends/`

## AWS S3 Configuration

### Environment Variables
The AWS mode requires environment variables for S3 configuration:

```bash
# Required for AWS mode
S3_BUCKET=your-s3-bucket-name
AWS_REGION=your-aws-region
ORG_NAME=your-organization-name

# Optional: Override full import map URL
IMPORTMAP_URL=https://custom-bucket.s3.amazonaws.com/@myorg/importmap.json
```

### Configuration Methods

**1. Environment Variables:**
```bash
S3_BUCKET=my-bucket AWS_REGION=us-west-2 ORG_NAME=myorg ./run.sh aws prod
```

**2. .env File (single-spa-root/.env):**
```bash
S3_BUCKET=my-bucket
AWS_REGION=us-west-2
ORG_NAME=myorg
```

**3. GitHub Actions (uses secrets):**
```yaml
env:
  S3_BUCKET: ${{ secrets.S3_BUCKET }}
  AWS_REGION: ${{ secrets.AWS_REGION }}
  ORG_NAME: ${{ secrets.ORG_NAME }}
```

### Import Map Structure
The AWS mode loads microfrontends from an S3-hosted import map:
```json
{
  "imports": {
    "@myorg/auth-app": "https://bucket.s3.region.amazonaws.com/@myorg/auth-app/commit-sha/bundle.js",
    "@myorg/layout-app": "https://bucket.s3.region.amazonaws.com/@myorg/layout-app/commit-sha/bundle.js"
  }
}
```

## Deployment

### S3 Bucket Setup

Before deploying, set up your S3 bucket for public website hosting:

```bash
# Linux/macOS/Git Bash
./scripts/setup-s3.sh public

# Windows
scripts\setup-s3.bat public
```

**Available setup actions:**
- `s3` - Basic S3 bucket only (default)
- `cors` - S3 bucket + CORS configuration  
- `public` - Full public website setup (bucket + website + policy + CORS)

### AWS Deployment Scripts

#### Quick AWS Deployment
```bash
# Build for AWS and deploy to S3 in one command
npm run deploy:aws         # Production deployment (default)
npm run deploy:aws:dev     # Development deployment
npm run deploy:aws:prod    # Production deployment (explicit)
```

#### Individual S3 Sync Scripts
```bash
# Sync individual apps to S3 (after building)
npm run sync:s3:root       # Root app only
npm run sync:s3:auth       # Auth app only
npm run sync:s3:layout     # Layout app only
npm run sync:s3:home       # Home app only
npm run sync:s3:angular    # Angular app only
npm run sync:s3:vue        # Vue app only
npm run sync:s3:react      # React app only
npm run sync:s3:vanilla    # Vanilla JS app only
npm run sync:s3:webcomponents  # Web Components app only
npm run sync:s3:typescript # TypeScript app only
npm run sync:s3:jquery     # jQuery app only
npm run sync:s3:svelte     # Svelte app only
npm run sync:s3:all        # All apps in sequence
```

**S3 Sync Features:**
- **Proper Synchronization**: Uses `--delete` flag to remove stale files
- **Hot-Update Exclusion**: Root app excludes development artifacts
- **Environment Variables**: Uses `S3_BUCKET` and `ORG_NAME` from .env
- **Organized Paths**: Each app syncs to `@{ORG_NAME}/app-name/` structure

**Usage Examples:**
```bash
# Quick single app update
npm run build:react:prod && npm run sync:s3:react

# Update root app only
npm run build:root:aws:prod && npm run sync:s3:root

# Full deployment (build + sync all)
npm run deploy:aws:prod

# Development workflow
npm run build:auth:dev && npm run sync:s3:auth
```

### Deployment Methods

#### Method 1: GitHub Actions (Recommended)

**Trigger all deployments:**
```bash
# Linux/macOS/Git Bash
./trigger-deploy.sh

# Windows
trigger-deploy.bat
```

**Then commit and push:**
```bash
git add .
git commit -m "Deploy all microfrontends to S3"
git push origin main
```

This triggers GitHub Actions workflows that:
- Build each microfrontend with versioned URLs
- Deploy to S3 with proper caching
- Update import map automatically
- Deploy root application

#### Method 2: Manual Deployment

**Direct deployment to S3:**
```bash
# Linux/macOS/Git Bash
./scripts/deploy-s3.sh [dev|prod]

# Windows
scripts\deploy-s3.bat [dev|prod]
```

**What manual deployment does:**
1. Builds all applications (dev or prod)
2. Deploys root application to S3 bucket root
3. Creates and uploads import map
4. Deploys each microfrontend to organized S3 paths
5. Shows final website URL

### Live Application

After deployment, your microfrontend application will be publicly accessible at:
```
http://your-bucket-name.s3-website-region.amazonaws.com
```

**Example:**
```
http://single-spa-demo-774145483743.s3-website-eu-central-1.amazonaws.com
```

## NPM Package Publishing

This project supports publishing all microfrontends as NPM packages for distribution and reuse.

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

# 4. Test published packages
npm run mode:npm && npm run serve:npm
```

**Nexus Registry (with .npmrc.nexus):**
```bash
# 1. Configure .npmrc.nexus with authentication
# registry=http://localhost:8081/repository/npm-group/
# //localhost:8081/repository/npm-group/:_auth=<base64-user:pass>

# 2. Test authentication (optional)
npm run test:nexus:auth

# 3. Publish packages with version bump
npm run publish:nexus:patch  # Bug fixes to Nexus
npm run publish:nexus:minor  # New features to Nexus
npm run publish:nexus:major  # Breaking changes to Nexus

# 4. Test published packages
npm run mode:nexus && npm run serve:nexus
```

### Published Packages

All packages are published under the `@cesarchamal` scope:

- `@cesarchamal/single-spa-root` - Root orchestrator application
- `@cesarchamal/single-spa-auth-app` - Vue.js authentication
- `@cesarchamal/single-spa-layout-app` - Vue.js layout components
- `@cesarchamal/single-spa-home-app` - AngularJS home page
- `@cesarchamal/single-spa-angular-app` - Angular 8 application
- `@cesarchamal/single-spa-vue-app` - Vue.js application
- `@cesarchamal/single-spa-react-app` - React application
- `@cesarchamal/single-spa-vanilla-app` - Vanilla JavaScript
- `@cesarchamal/single-spa-webcomponents-app` - Web Components (Lit)
- `@cesarchamal/single-spa-typescript-app` - TypeScript application
- `@cesarchamal/single-spa-jquery-app` - jQuery legacy integration
- `@cesarchamal/single-spa-svelte-app` - Svelte application

### Version Management

All packages use synchronized versioning:

```bash
# Check current versions
npm run version:current

# Manual version management
npm run version:bump:patch   # 0.1.0 → 0.1.1
npm run version:bump:minor   # 0.1.0 → 0.2.0
npm run version:bump:major   # 0.1.0 → 1.0.0
npm run version:set 2.0.0    # Set specific version
npm run version:reset        # Reset to 0.1.0
npm run version:reset 1.0.0  # Reset to custom version

# Publishing automatically handles versioning
npm run publish:npm:minor    # Bumps version + publishes to NPM
npm run publish:nexus:minor  # Bumps version + publishes to Nexus

# Backward-compatible aliases (default to NPM)
npm run publish:minor        # Bumps version + publishes to NPM
```

### Mode Switching

```bash
# Local development (default)
npm run mode:local
npm run serve:local:dev

# NPM packages (after publishing)
npm run mode:npm
npm run serve:npm

# Check current mode
npm run mode:status
```

## Deployment Modes

This project supports 5 different deployment modes, each with specific configuration and use cases:

### **1. Local Mode** 🏠
```bash
# Configuration
SPA_MODE=local
SPA_ENV=dev|prod

# URLs
Dev:  http://localhost:4201-4211/app-name.js
Prod: /app-name.js (served from root server)

# Deployment
- No external deployment
- Serves from local dev servers or static files
- 12 individual ports (4201-4211) in dev
- Single server (8080) in prod

# Build Process
npm run build:dev   # Individual dev servers
npm run build:prod  # Static files to root/dist
```

### **2. NPM Mode** 📦
```bash
# Configuration  
SPA_MODE=npm
Requires: npm login, published packages

# Package Structure
@cesarchamal/single-spa-auth-app@0.1.0
@cesarchamal/single-spa-layout-app@0.1.0
# ... 11 microfrontends total

# URLs (via unpkg CDN)
https://unpkg.com/@cesarchamal/single-spa-auth-app@latest/dist/bundle.js

# Deployment Process
1. Version bump (patch/minor/major)
2. Build all apps (npm run build:prod)
3. Publish to NPM registry
4. Switch package.json to include NPM dependencies
5. Load via ES6 imports from CDN

# Package Switching
npm run mode:npm    # Switches to package-npm.json
npm run mode:local  # Switches back to package.json
```

### **3. Nexus Mode** 🏢
```bash
# Configuration
SPA_MODE=nexus
Requires: Nexus registry access, authentication

# Package Structure
Same as NPM but published to private Nexus registry

# URLs
https://nexus-registry.company.com/@cesarchamal/single-spa-auth-app@latest/dist/bundle.js

# Deployment Process
1. Configure NPM registry: npm config set registry https://nexus.company.com
2. Authenticate with Nexus
3. Same publishing process as NPM
4. Load via ES6 imports from private registry
```

### **4. GitHub Mode** 🐙
```bash
# Configuration
SPA_MODE=github
GITHUB_TOKEN=ghp_xxxxxxxxxxxxx
GITHUB_USERNAME=cesarchamal

# Repository Structure
cesarchamal/single-spa-auth-app (GitHub Pages enabled)
cesarchamal/single-spa-layout-app
# ... 11 repos + 1 root repo = 12 total

# URLs
https://cesarchamal.github.io/single-spa-auth-app/single-spa-auth-app.js

# Deployment Process (Dev vs Prod)
Dev:  Reads from existing GitHub Pages (no deployment)
Prod: Creates repos + builds + deploys + enables GitHub Pages

# GitHub API Usage
- Creates repositories via GitHub API
- Enables GitHub Pages via API
- Pushes built files to main branch
- Each app gets its own repository
```

### **5. AWS Mode** ☁️
```bash
# Configuration
SPA_MODE=aws
S3_BUCKET=single-spa-demo-774145483743
AWS_REGION=eu-central-1
ORG_NAME=cesarchamal

# S3 Structure
bucket/
├── index.html (root app)
├── root-application.js
├── @cesarchamal/
│   ├── importmap.json
│   ├── auth-app/single-spa-auth-app.umd.js
│   ├── layout-app/single-spa-layout-app.umd.js
│   └── ... (11 microfrontends)

# Import Map (Dynamic Loading)
{
  "imports": {
    "@cesarchamal/auth-app": "https://bucket.s3.region.amazonaws.com/@cesarchamal/auth-app/single-spa-auth-app.umd.js"
  }
}

# URLs
Website: http://bucket.s3-website-region.amazonaws.com
Import Map: https://bucket.s3.region.amazonaws.com/@cesarchamal/importmap.json

# Deployment Process
1. Setup S3 bucket (public, website hosting, CORS)
2. Build all apps + root app with AWS config
3. Upload root app to bucket root
4. Upload microfrontends to organized paths
5. Generate and upload import map
6. SystemJS loads apps dynamically via import map
```

### **Mode Comparison Table**

| Mode | Loading Strategy | Dependencies | Build Config | Deployment Target |
|------|-----------------|--------------|--------------|-------------------|
| **Local** | SystemJS from localhost/static | Local files | Standard webpack | Local servers |
| **NPM** | SystemJS from CDN | No special deps | `--env.mode=npm` | NPM registry |
| **Nexus** | SystemJS from private CDN | No special deps | `--env.mode=nexus` | Nexus registry |
| **GitHub** | SystemJS from GitHub Pages | No special deps | `--env.mode=github` | GitHub repositories |
| **AWS** | SystemJS + Import Map | No special deps | `--env.mode=aws` + AWS config | S3 bucket |

### **Runtime Behavior**
- **Mode Detection**: Auto-detects S3 websites, uses URL params, localStorage, or env vars
- **Authentication**: All modes require login (admin/12345) except login page
- **Error Handling**: CORS, 403, 404 errors handled per mode
- **Fallbacks**: Import map failures return empty maps to prevent crashes

Each mode provides a complete microfrontend deployment strategy suitable for different organizational needs and infrastructure requirements.

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

Each microfrontend now includes a comprehensive **visual showcase** of the shared state management system:

**🎨 Showcase Features:**
- 🔄 **Shared State Management** header with framework identification
- 👤 **User State Display**: Real-time login status and username
- 👥 **Employee Data Visualization**: Count and preview of loaded employees
- 📡 **Interactive Buttons**: Load employees, broadcast messages, clear data
- 📨 **Recent Events Feed**: Live display of cross-app communication
- 🎯 **Cross-Framework Communication**: Visual notifications between apps

**🖼️ Showcase Implementation Status:**

| App | Visual Showcase | User State | Employee Data | Cross-App Events | Interactive Buttons |
|-----|----------------|------------|---------------|------------------|--------------------|
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

### **Integration Status**
| App | State Subscriptions | Event Broadcasting | Event Listening | Employee Loading |
|-----|--------------------|--------------------|-----------------|------------------|
| 🔐 Auth App | ✅ Login/Logout | ✅ login-success | ✅ All events | ❌ |
| 🎨 Layout App | ✅ User display | ✅ logout | ✅ All events | ❌ |
| 🏠 Home App | ✅ User state | ✅ Cross-app messages | ✅ All events | ✅ Load button |
| 🅰️ Angular App | ✅ User state | ✅ Cross-app messages | ✅ All events | ✅ Load button |
| 💚 Vue App | ✅ User state | ✅ Cross-app messages | ✅ All events | ✅ Load button |
| ⚛️ React App | ✅ Custom hooks | ✅ Cross-app messages | ✅ All events | ✅ Load button |
| 🍦 Vanilla App | ✅ User state | ✅ Cross-app messages | ✅ All events | ✅ Load button |
| 🧩 Web Components | ✅ User state | ✅ Cross-app messages | ✅ All events | ✅ Load button |
| 📘 TypeScript App | ✅ User state | ✅ Cross-app messages | ✅ All events | ✅ Load button |
| 💎 jQuery App | ✅ User state | ✅ Cross-app messages | ✅ All events | ✅ Load button |
| 🔥 Svelte App | ✅ User state | ✅ Cross-app messages | ✅ All events | ✅ Load button |

### **Live Demo Features**
1. **Login Synchronization**: Login in auth app → All apps receive user state
2. **Visual State Showcase**: 9 apps display comprehensive shared state UI
3. **Employee Data Loading**: Click "Load Employees" → Data appears in all showcases
4. **Cross-App Broadcasting**: Click "Broadcast" → Messages appear in other apps
5. **Real-time Updates**: All state changes propagate instantly across frameworks
6. **Interactive Notifications**: Visual popup notifications for cross-app messages
7. **Console Logging**: Each app logs received events with unique emojis

### **Showcase User Experience**

**🎯 Try This Demo Flow:**
1. **Login**: Use admin/12345 → See user state update in all showcases
2. **Load Data**: Click "Load Employees" in React app → See data in Vue, Angular, etc.
3. **Broadcast**: Click "Broadcast from Vue" → See notification in React, Angular, etc.
4. **Clear Data**: Click "Clear Data" in any app → See data disappear everywhere
5. **Cross-Framework**: Navigate between /react, /vue, /angular → State persists

**🎨 Visual Elements:**
- **Gradient Background**: Purple gradient distinguishes showcase sections
- **Real-time Counters**: Employee count updates instantly
- **Preview Text**: Shows first 3 employee names with "(+X more)" indicator
- **Color-coded Buttons**: Green (load), Blue (broadcast), Red (clear)
- **Event Feed**: Shows last 3 cross-app messages with source identification
- **Status Indicators**: ✅ logged in, ❌ not logged in, 📊 data count

### **Employee API Endpoint**
- **URL**: `http://localhost:8080/employees.json`
- **Data**: 6 employee records with id, name, email, avatar
- **Integration**: Load via "Load Employees" buttons in React, Vue, Vanilla, Svelte apps
- **State**: Shared across all microfrontends via `employees$` observable

### **Mode Compatibility**

| Mode | State Manager | Cross-App Events | Employee API | Full Support |
|------|---------------|------------------|--------------|-------------|
| **Local** | ✅ | ✅ | ✅ `/employees.json` | ✅ **100%** |
| **NPM** | ✅ | ✅ | ✅ `/employees.json` | ✅ **100%** |
| **Nexus** | ✅ | ✅ | ✅ `/employees.json` | ✅ **100%** |
| **GitHub** | ✅ | ✅ | ✅ `/{repo}/employees.json` | ✅ **100%** |
| **AWS** | ✅ | ✅ | ✅ `/employees.json` | ✅ **100%** |

**All deployment modes fully support:**
- ✅ Login/logout state synchronization across all apps
- ✅ Real-time event broadcasting between microfrontends
- ✅ Shared employee data loading via `/employees.json`
- ✅ Console logging with unique app emojis
- ✅ Cross-framework communication (React ↔ Vue ↔ Angular ↔ etc.)

## Features

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

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run linting: `npm run lint-all:loose`
5. Test your changes
6. Submit a pull request

## License

MIT License - see individual LICENSE files in each application directory.

## Authors

- Cesar Francisco Chavez Maldonado (Original author)
- Various contributors

## Status Checking

Comprehensive status checker scripts are available for all deployment modes to help diagnose issues and verify deployments:

### Quick Status Checks

```bash
# Check all modes
npm run check:local    # Local dev servers & built files
npm run check:npm      # NPM packages & CDN accessibility
npm run check:nexus    # Nexus registry & connectivity
npm run check:github   # GitHub repos & Pages status
npm run check:aws      # S3 bucket & file accessibility

# Direct script execution
# Linux/macOS/Git Bash
./scripts/check-local-status.sh
./scripts/check-npm-status.sh
./scripts/check-nexus-status.sh
./scripts/check-github-status.sh
./scripts/check-aws-status.sh

# Windows
scripts\check-local-status.bat
scripts\check-npm-status.bat
scripts\check-nexus-status.bat
scripts\check-github-status.bat
scripts\check-aws-status.bat
```

### What Each Checker Tests

| Mode | Tests | Key Checks |
|------|-------|------------|
| **Local** | Dev servers, ports, built files | Port availability, HTTP endpoints, dist/ files |
| **NPM** | Package registry, CDN access | Package existence, unpkg/jsdelivr CDN |
| **Nexus** | Registry connectivity, packages | Nexus server, direct access, NPM proxy |
| **GitHub** | Repositories, Pages status | Repo existence, Pages enablement, file access |
| **AWS** | S3 bucket, import map | Website URLs, API URLs, import map |

### Status Output

Each checker provides:
- ✅ **Success indicators** with HTTP status codes
- ❌ **Error indicators** with specific failure reasons
- ⚠️ **Warning indicators** for partial success (e.g., 403 forbidden)
- 📊 **Summary tables** with all results
- 🔧 **Actionable recommendations** for fixing issues

## Troubleshooting

### Common Issues

1. **Port Conflicts**: Ensure all required ports are available
2. **Node Version**: Use Node.js v18 or higher
3. **OpenSSL Compatibility**: Automatic handling via launcher scripts (see OpenSSL section above)
4. **Memory Issues**: Increase Node.js memory limit if needed
5. **CORS Issues**: Applications are configured with CORS support
6. **Registry Issues**: Run scripts automatically switch NPM registries
7. **GitHub Actions Failures**: Individual apps use public NPM registry automatically
8. **Deployment Issues**: Use status checkers to identify missing files or configuration problems

### Debug Mode

Enable debug logging by setting environment variables:
```bash
DEBUG=single-spa:* npm run serve
```

### Version Management Issues

```bash
# Check all package versions
npm run version:current

# Reset all versions to match main package
npm run version:set $(node -e "console.log(require('./package.json').version)")

# Clean any _trigger fields
npm run version:clean
```

### NPM Publishing Issues

```bash
# Test NPM authentication with token
export NPM_TOKEN=npm_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
npm run test:npm:auth

# Check NPM authentication manually
npm whoami

# Test publishing (dry run)
cd single-spa-auth-app
npm publish --dry-run

# Switch back to local mode if NPM packages fail
npm run mode:local
```

### Nexus Publishing Issues

```bash
# Test Nexus authentication
npm run test:nexus:auth

# Check Nexus configuration
cat .npmrc.nexus

# Verify Nexus server is running
curl http://localhost:8081/repository/npm-group/

# Switch back to local mode if Nexus packages fail
npm run mode:local
```

### Registry Configuration Issues

**Automatic Registry Switching:**
The run scripts automatically switch NPM registries:
- NPM mode: Uses public NPM registry (`https://registry.npmjs.org/`)
- Nexus mode: Uses Nexus registry (`http://localhost:8081/repository/npm-group/`)
- Local mode: Restores original configuration

**Manual Registry Management:**
```bash
# Quick registry switching
npm run registry:npm      # Switch to NPM
npm run registry:nexus    # Switch to Nexus
npm run registry:status   # Check current
npm run registry:restore  # Restore original

# Advanced management
npm config get registry   # Check current registry
npm config delete registry # Reset to default
ls -la .npmrc*            # Verify .npmrc files

# Use run scripts for automatic switching
./run.sh npm dev    # Auto-switches to public NPM
./run.sh nexus dev  # Auto-switches to Nexus
./run.sh local dev  # Restores original config
```

**Configuration Files:**
- `.npmrc.npm` - Public NPM registry template (committed)
- `.npmrc.nexus.example` - Nexus registry template (copy and customize)
- `.npmrc` - Active configuration (auto-generated, not committed)
- `.npmrc.backup` - Backup of original configuration

## Additional Resources

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
- [VERSION-MANAGEMENT.md](scripts/VERSION-MANAGEMENT.md) - Detailed version management guide
- [NPM-PUBLISHING.md](single-spa-root/NPM-PUBLISHING.md) - Complete publishing guide