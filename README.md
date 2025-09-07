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
├── single-spa-login/  # Root application
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
└── single-spa-svelte-app/                       # Svelte application
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
./run.sh [mode] [environment]
# Windows
run.bat [mode] [environment]
```

**Parameters:**
- **Mode** (first parameter): `local` (default), `npm`, `nexus`, `github`, `aws`
- **Environment** (second parameter): `dev` (default), `prod`

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

# GitHub modes
./run.sh github dev   # Read from existing GitHub Pages
./run.sh github prod  # Create repos + deploy everything

# Production builds
./run.sh local prod   # Local production build
./run.sh npm prod     # NPM production build
./run.sh aws prod     # AWS S3 production build

# Windows examples
run.bat local prod
run.bat npm dev
run.bat aws prod
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
- `switch-mode.js` - Mode switching utility (local/npm/github/aws)
- `version-manager.js` - Centralized version management
- `publish-npm.sh` / `publish-npm.bat` - NPM publishing automation
- `publish-nexus.sh` / `publish-nexus.bat` - Nexus publishing automation
- `setup-s3.sh` / `setup-s3.bat` - S3 bucket setup and configuration
- `trigger-*.sh` / `trigger-*.bat` - GitHub Actions deployment triggers
- `update-importmap.mjs` - Import map management for deployments
- `test-build.sh` - Build testing utility
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

### Trigger Scripts
- `npm run trigger:actions` - Trigger all GitHub Actions deployments
- `npm run trigger:deploy:aws` - Trigger AWS S3 deployment
- `npm run trigger:deploy:github` - Trigger GitHub Pages deployment

### Status Checker Scripts
- `npm run check:local` - Check local development servers and built files
- `npm run check:npm` - Check NPM packages and CDN accessibility
- `npm run check:nexus` - Check Nexus registry and package availability
- `npm run check:github` - Check GitHub repositories and Pages status
- `npm run check:aws` - Check AWS S3 bucket and file accessibility

### Authentication Testing Scripts
- `npm run test:npm:auth` - Test NPM authentication with NPM_TOKEN
- `npm run test:nexus:auth` - Test Nexus authentication with .npmrc.nexus
- `./scripts/test-npm-auth.sh` - Direct script execution (Linux/macOS/Git Bash)
- `scripts\test-npm-auth.bat` - Direct script execution (Windows)

### Hot Reload Scripts
- `npm run aws:hot-sync` - Auto-sync file changes to AWS S3 bucket
- `npm run github:hot-sync` - Auto-deploy file changes to GitHub repositories

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

#### Nexus Registry Publishing
- `npm run publish:nexus` - Publish to Nexus (default: patch version, dev environment)
- `npm run publish:nexus:patch` - Publish to Nexus with patch version bump
- `npm run publish:nexus:minor` - Publish to Nexus with minor version bump
- `npm run publish:nexus:major` - Publish to Nexus with major version bump
- `npm run publish:nexus:dev` - Version management only (no publishing)
- `npm run publish:nexus:prod` - Publish all 12 packages (11 microfrontends + root app)

#### Publishing Mode Behavior
- **Dev Mode**: Only updates package versions, no actual publishing
- **Prod Mode**: Publishes all packages to registry for public/private access

#### Individual Publishing Scripts
- `npm run publish:npm:root:patch` - Publish root app to NPM with patch version bump
- `npm run publish:npm:auth:patch` - Publish auth app to NPM with patch version bump
- `npm run publish:nexus:root:patch` - Publish root app to Nexus with patch version bump
- Similar scripts available for all 12 apps with :patch, :minor, :major variants

#### Backward-Compatible Aliases
- `npm run publish:all` - Publish all packages to NPM (alias for publish:npm)
- `npm run publish:patch` - Bump patch version and publish to NPM
- `npm run publish:minor` - Bump minor version and publish to NPM
- `npm run publish:major` - Bump major version and publish to NPM

### Root Project Scripts
- `npm run install:all` - Install dependencies for all applications
- `npm run build` - Build all microfrontends
- `npm run build:dev` - Build all microfrontends for development
- `npm run build:prod` - Build all microfrontends for production
- `npm run serve:root` - Start root development server
- `npm run clean` - Clean all node_modules
- `npm start` - Start development environment
- `npm run lint` - Lint and fix all JavaScript/JSON files
- `npm run lint:check` - Check linting without fixing

### Individual App Scripts
- `npm run install:auth` - Install auth app dependencies
- `npm run build:auth` - Build auth application
- `npm run build:auth:dev` - Build auth app for development
- `npm run build:auth:prod` - Build auth app for production
- `npm run serve:auth` - Serve auth app individually
- Similar patterns for: layout, home, angular, vue, react, vanilla, webcomponents, typescript, jquery, svelte

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

| Script | Setup/Cleanup | Mode Support | Apps Launched | Best For |
|--------|---------------|--------------|---------------|----------|
| `run.sh/bat` | ✅ Full setup | ✅ All modes | Mode-dependent | Production-like testing |
| `dev-all.sh/bat` | ❌ Minimal | ❌ Local only | Always all apps | Quick development |

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
| Svelte | 4211 | http://localhost:4211 |calhost:4208 |
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
3. **Memory Issues**: Increase Node.js memory limit if needed
4. **CORS Issues**: Applications are configured with CORS support
5. **Registry Issues**: Run scripts automatically switch NPM registries
6. **GitHub Actions Failures**: Individual apps use public NPM registry automatically
7. **Deployment Issues**: Use status checkers to identify missing files or configuration problems

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