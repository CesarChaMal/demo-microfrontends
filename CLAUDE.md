# CLAUDE.md - AI Assistant Guide for demo-microfrontends

## Project Overview

**Project Name:** demo-microfrontends
**Version:** 1.0.18
**Repository:** https://github.com/CesarChaMal/demo-microfrontends
**Type:** Microfrontend orchestration platform using Single-SPA
**Node Version:** v18.20.0 (see .nvmrc)
**NPM Version:** >=8.0.0

This is a **production-ready microfrontend demonstration platform** showcasing Single-SPA framework orchestration with 11 diverse framework implementations. It's a comprehensive platform with sophisticated deployment orchestration supporting 5 deployment modes (local, npm, nexus, github, aws), automated CI/CD via GitHub Actions, and a shared RxJS state management system.

### Live Demo
- **CloudFront CDN**: https://d3oyknhmr5oulj.cloudfront.net/
- **Login**: admin / 12345

---

## Architecture Overview

### Microfrontend Structure (12 Applications)

| App | Framework | Port | Route | Purpose |
|-----|-----------|------|-------|---------|
| Root | Single-SPA | 8080 | Orchestrator | Registers and manages all microfrontends |
| Auth | Vue.js 2 | 4201 | /login | Authentication and login |
| Layout | Vue.js 2 | 4202 | All routes | Header, navigation, footer |
| Home | AngularJS 1.x | 4203 | / | Landing page |
| Angular | Angular 8 | 4204 | /angular/* | Angular features |
| Vue | Vue.js 2 | 4205 | /vue/* | Vue features |
| React | React 16 | 4206 | /react/* | React features |
| Vanilla | ES2020+ | 4207 | /vanilla/* | Pure JavaScript |
| Web Components | Lit | 4208 | /webcomponents/* | Web Components/Lit |
| TypeScript | TypeScript | 4209 | /typescript/* | TypeScript features |
| jQuery | jQuery 3.6 | 4210 | /jquery/* | Legacy jQuery integration |
| Svelte | Svelte 3 | 4211 | /svelte/* | Svelte features |

### Key Architectural Patterns

1. **Single-SPA Registration Pattern**
   - Root app (`single-spa-root/root-application-dynamic.js`) registers all microfrontends
   - Each app exports `bootstrap()`, `mount()`, `unmount()` lifecycle methods
   - Route-based activation via activity functions

2. **Module Loading**
   - SystemJS 6.14.1 for dynamic UMD module loading
   - Each app builds to UMD format for cross-framework compatibility
   - Mode-aware loading (local/npm/nexus/github/aws)

3. **Shared State Management (RxJS)**
   - Location: `/shared/state-manager.js`
   - Exposed globally: `window.stateManager`
   - Three main observables:
     - `userState$`: Authentication state (BehaviorSubject)
     - `events$`: Cross-app event stream (Subject)
     - `employees$`: Shared employee data (BehaviorSubject)

4. **Build Strategy**
   - Webpack 4 for bundling
   - UMD output format for Single-SPA compatibility
   - Single chunk output (LimitChunkCountPlugin)
   - Mode-aware configuration

---

## Key Conventions for AI Assistants

### 1. Mode-Aware Configuration

**CRITICAL**: This codebase uses a unique multi-mode deployment strategy.

**5 Deployment Modes:**
- `local`: Development with localhost URLs (ports 4201-4211)
- `npm`: NPM registry via unpkg.com CDN
- `nexus`: Private Nexus registry
- `github`: GitHub Pages deployment
- `aws`: AWS S3 + CloudFront with import maps

**Configuration Files by Mode:**
```
package.json          ← Active (switched via scripts/switch-mode.js)
package-local.json    ← Local development
package-npm.json      ← NPM registry
package-nexus.json    ← Nexus registry
package-github.json   ← GitHub Pages
package-aws.json      ← AWS S3

.npmrc               ← Active
.npmrc.local         ← Local config
.npmrc.npm           ← NPM config
.npmrc.nexus         ← Nexus config
```

**Switching Modes:**
```bash
npm run mode:local    # Local development
npm run mode:npm      # NPM packages
npm run mode:nexus    # Nexus registry
npm run mode:github   # GitHub Pages
npm run mode:aws      # AWS S3
npm run mode:status   # Check current mode
```

### 2. Directory Structure Pattern

Each microfrontend follows this structure:
```
single-spa-{name}-app/
├── src/
│   ├── singleSpaEntry.js      # Single-SPA lifecycle exports
│   ├── index.js|App.js        # Main component
│   └── components/            # Framework-specific components
├── dist/                       # Build output
├── package.json               # App manifest
├── webpack.config.js          # Webpack config
└── [framework configs]         # tsconfig.json, angular.json, etc.
```

Root application:
```
single-spa-root/
├── src/ or root-application-dynamic.js  # App registration
├── public/
│   ├── employees.json                   # Shared data
│   └── index.html                       # HTML template
├── dist/                                # Build output
├── webpack.config.js                    # Standard config
├── webpack.aws.config.js                # S3-specific config
├── server.js                            # Express dev server
└── package*.json                        # Mode variants
```

### 3. Shared State Usage Pattern

**ALL apps can access:**
```javascript
// Subscribe to user authentication
window.stateManager.userState$.subscribe(state => {
  // state: {user, isAuthenticated, token}
})

// Login (from auth app)
window.stateManager.setUser({username: 'admin'}, 'token123')

// Logout (from layout app)
window.stateManager.logout()

// Cross-app events
window.stateManager.events$.subscribe(event => {
  console.log('Event:', event)
})

// Broadcast to all apps
window.stateManager.emit('custom-event', {data: 'hello'})

// Load shared employee data
window.stateManager.loadEmployees()
window.stateManager.employees$.subscribe(employees => {
  console.log('Employees:', employees)
})
```

### 4. Version Management

**IMPORTANT**: All packages must stay synchronized.

```bash
# Show current versions
npm run version:current

# Bump versions (updates ALL packages)
npm run version:bump:patch   # 0.1.0 → 0.1.1
npm run version:bump:minor   # 0.1.0 → 0.2.0
npm run version:bump:major   # 0.1.0 → 1.0.0

# Set specific version for all
npm run version:set 1.2.3
```

### 5. Script Organization (366 Scripts!)

**Installation:**
- `install:all` - Sequential install (root → all apps)
- `install:all:concurrent` - Parallel install
- `install:all:ci` - CI optimized (npm ci)

**Building:**
- `build:apps` - Build all apps sequentially
- `build:apps:concurrent` - Parallel build
- `build:apps:dev` - Development builds
- `build:apps:prod` - Production builds

**Publishing:**
- `publish:npm:all` - Complete NPM workflow
- `publish:nexus:all` - Complete Nexus workflow
- `publish:all` - Both registries

**Deployment:**
- `deploy:aws:prod` - Direct S3 upload (fastest)
- `deploy:github:all` - Deploy all to GitHub Pages
- `trigger:github:pages` - GitHub Actions (parallel, recommended)
- `trigger:aws:s3` - AWS via GitHub Actions

**Serving:**
- `serve:root` - Root app only
- `serve:local:dev` - Local development
- `serve:npm` - NPM mode
- `serve:aws` - AWS mode

### 6. Launcher Scripts (Enhanced)

**Recommended approach for development:**

```bash
# Linux/Mac
./run.sh [mode] [env] [options]

# Windows
run.bat [mode] [env] [options]

# Examples
./run.sh local dev                    # Local development
./run.sh local dev --clean            # Clean install first
./run.sh npm prod --skip-install      # Skip install for speed
./run.sh aws dev --fix-network        # Fix network issues
./run.sh local prod --offline         # Offline mode
```

**Options:**
- `--clean`: Remove node_modules before install
- `--skip-install`: Skip npm install
- `--skip-build`: Skip build step
- `--fix-network`: Configure npm for unstable networks
- `--offline`: Use local deps (local/nexus only)

**Stop all processes:**
```bash
./stop.sh    # Linux/Mac
stop.bat     # Windows
```

---

## Development Workflow

### Quick Start
```bash
# 1. Initial setup
npm run install:all

# 2. Build all apps
npm run build:apps

# 3. Start development (launches all 12 apps)
./run.sh local dev

# 4. Access application
# Open http://localhost:8080
```

### Fast Development Restart
```bash
# Skip install and build for faster restarts
./run.sh local dev --skip-install --skip-build
```

### Adding a New Microfrontend

1. **Create directory**: `single-spa-{name}-app/`
2. **Setup package.json** with framework dependencies
3. **Create singleSpaEntry.js**:
   ```javascript
   export const bootstrap = () => Promise.resolve()
   export const mount = (props) => {
     // Mount app to props.domElement
   }
   export const unmount = () => {
     // Cleanup
   }
   ```
4. **Configure webpack.config.js** (UMD output)
5. **Register in root** (`root-application-dynamic.js`):
   ```javascript
   singleSpa.registerApplication({
     name: '@org/app-name',
     app: () => loadModule('app-name'),
     activeWhen: activityFunction
   })
   ```
6. **Add port** (next available: 4212+)
7. **Update scripts** in root package.json

### Modifying Existing Apps

**ALWAYS:**
1. Read the app's package.json first
2. Check webpack.config.js for build config
3. Understand framework-specific patterns
4. Test in local mode first
5. Verify shared state integration

**NEVER:**
1. Change UMD output format
2. Skip lifecycle methods (bootstrap/mount/unmount)
3. Break Single-SPA registration
4. Modify port assignments without updating root

### Working with Shared State

**Location**: `/shared/state-manager.js`

**Adding new state:**
1. Add BehaviorSubject or Subject
2. Add getter method
3. Add setter/update method
4. Export via window.stateManager

**Example:**
```javascript
// In state-manager.js
const notifications$ = new Subject()

export const stateManager = {
  notifications$,
  notify(message) {
    this.notifications$.next({message, timestamp: Date.now()})
  }
}
```

---

## Critical File Locations

### For Common Tasks

| Task | Files to Check/Modify |
|------|----------------------|
| Add new microfrontend | `root-application-dynamic.js`, root `package.json` scripts |
| Fix build issues | App's `webpack.config.js`, `.babelrc`, `tsconfig.json` |
| Modify shared state | `/shared/state-manager.js` |
| Change deployment mode | `/scripts/switch-mode.js`, `package-*.json` variants |
| Add tests | App's `package.json`, `karma.conf.js` (Angular) |
| Debug routing | `root-application-dynamic.js` activity functions |
| Fix CORS | Root `server.js`, app `webpack.devServer` configs |
| Change ports | App `webpack.config.js` devServer port |
| Add CI/CD | `.github/workflows/*.yml` |
| Publish packages | `/scripts/publish-*.sh`, `.npmrc.*` configs |

### Important Configuration Files

```
/.nvmrc                    # Node version (18.20.0)
/package.json              # Root manifest, 366 scripts
/.eslintrc.js              # Root ESLint config
/.env.example              # Environment variable template

/single-spa-root/
  webpack.config.js        # Standard webpack config
  webpack.aws.config.js    # S3-specific with code splitting
  server.js                # Express dev server
  index.html               # HTML template (mode-aware)

/scripts/
  switch-mode.js           # Mode switching logic
  version-manager.js       # Version synchronization
  publish-npm.sh           # NPM publishing
  deploy-s3.sh             # S3 deployment
  deploy-github.sh         # GitHub deployment

/.github/workflows/
  deploy-github-pages.yml  # GitHub Pages deployment
  deploy-shared.yml        # Shared state deployment
  deploy-*.yml             # Per-app workflows
```

---

## Deployment Strategies

### Mode 1: Local Development
```bash
npm run mode:local
./run.sh local dev

# URLs: http://localhost:PORT/bundle.js
# Use Case: Full development environment
```

### Mode 2: NPM Registry
```bash
# Setup
export NPM_TOKEN=npm_xxxxx
npm run test:npm:auth

# Publish
npm run publish:npm:all

# Serve
npm run mode:npm
npm run serve:npm

# URLs: https://unpkg.com/@cesarchamal/package@latest/dist/bundle.js
# Use Case: Public package distribution
```

### Mode 3: Nexus Private Registry
```bash
# Configure .npmrc.nexus with auth
npm run test:nexus:auth

# Publish
npm run publish:nexus:all

# Serve
npm run mode:nexus
npm run serve:nexus

# URLs: https://nexus-registry.company.com/@cesarchamal/...
# Use Case: Enterprise private registry
```

### Mode 4: GitHub Pages
```bash
# Setup
export GITHUB_TOKEN=ghp_xxxxx
export GITHUB_USERNAME=your-username

# Deploy (parallel, recommended)
npm run trigger:github:pages

# Serve
npm run mode:github
npm run serve:github

# URLs: https://username.github.io/package/bundle.js
# Use Case: GitHub Pages hosting
```

### Mode 5: AWS S3 + CloudFront
```bash
# Setup (one-time)
npm run s3:setup:public
npm run cloudfront:setup:spa

# Deploy (recommended)
npm run deploy:aws:prod

# Or via GitHub Actions
npm run trigger:aws:s3

# Serve
npm run mode:aws
npm run serve:aws

# URLs: https://bucket.s3.region.amazonaws.com/...
# Use Case: Production CDN deployment
```

---

## Testing and Validation

### Status Checkers
```bash
npm run check:local      # Check local servers
npm run check:npm        # Check NPM packages
npm run check:nexus      # Check Nexus registry
npm run check:github     # Check GitHub repos
npm run check:aws        # Check S3 bucket
npm run check:cdn        # Check CloudFront CDN
```

### Authentication Testing
```bash
npm run test:npm:auth    # Test NPM_TOKEN
npm run test:nexus:auth  # Test Nexus auth
```

### Linting
```bash
npm run lint             # ESLint all files with auto-fix
npm run lint:check       # Check without fixing
```

---

## Troubleshooting Guide

### Common Issues

**1. Port Conflicts**
```bash
# Find process using port
lsof -i :8080  # Mac/Linux
netstat -ano | findstr :8080  # Windows

# Kill process
kill -9 <PID>  # Mac/Linux
taskkill /PID <PID> /F  # Windows

# Or use stop script
./stop.sh
```

**2. Node Version Issues**
```bash
# Use correct Node version
nvm use 18.20.0  # or nvm use (reads .nvmrc)
```

**3. OpenSSL Compatibility (Node 18+)**
Already handled by launcher scripts via:
```bash
NODE_OPTIONS=--openssl-legacy-provider
```

**4. Network/Registry Issues**
```bash
# Fix network configuration
./run.sh local dev --fix-network

# Switch registry
npm run registry:npm
npm run registry:nexus
npm run registry:restore
```

**5. Clean Installation**
```bash
# Complete cleanup
npm run clean
./run.sh local dev --clean

# Or manual
rm -rf node_modules package-lock.json
rm -rf */node_modules */package-lock.json
npm run install:all
```

**6. Mode Synchronization**
```bash
# Check current mode
npm run mode:status

# Force switch
npm run mode:local
npm run build:apps
```

**7. Offline Development**
```bash
# One-time setup
npm run offline:setup

# Run offline
./run.sh local prod --offline
npm run offline:serve
```

---

## Git Workflow for AI Assistants

### Current Branch
```
claude/claude-md-mhxybau7k5mfjv8p-01NGhdt8uV12NDqKbjpW6NWP
```

### Making Changes

**ALWAYS:**
1. Work on the designated branch above
2. Commit with clear messages
3. Push with `-u origin <branch-name>`
4. Branch name MUST start with `claude/` and match session ID

**Commit Pattern:**
```bash
# Make changes
git add .
git commit -m "Clear description of changes"
git push -u origin claude/claude-md-mhxybau7k5mfjv8p-01NGhdt8uV12NDqKbjpW6NWP
```

**Retry Logic for Network Failures:**
- Push: Retry up to 4 times with exponential backoff (2s, 4s, 8s, 16s)
- Fetch/Pull: Same retry logic

---

## Environment Variables

### Required by Mode

**GitHub Mode:**
```bash
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxx
GITHUB_USERNAME=your-github-username
ORG_NAME=cesarchamal  # Optional override
```

**AWS Mode:**
```bash
S3_BUCKET=single-spa-demo-774145483743
AWS_REGION=eu-central-1
ORG_NAME=cesarchamal
CLOUDFRONT_DISTRIBUTION_ID=E22CAYA3V9WRA9  # Optional
IMPORTMAP_URL=https://...  # Optional override
```

**NPM Mode:**
```bash
NPM_TOKEN=npm_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Configuration File
Copy and customize:
```bash
cp .env.example .env
# Edit .env with your values
```

---

## Best Practices for AI Assistants

### DO:
- Use TodoWrite tool for multi-step tasks
- Read package.json and webpack configs before modifying
- Test in local mode first
- Check mode status before deployment
- Use concurrent scripts for parallel operations
- Verify shared state integration
- Run linting before commits
- Use launcher scripts for development
- Check status with `check:*` scripts

### DON'T:
- Change UMD output format
- Modify Single-SPA lifecycle methods without understanding
- Skip version synchronization
- Commit without testing locally
- Change ports without updating all references
- Mix deployment modes
- Modify package.json without updating mode variants
- Skip build steps in production
- Push to main branch
- Use force push without explicit permission

### Code Quality
- Follow ESLint rules (Airbnb base)
- Maintain framework-specific conventions
- Keep components small and focused
- Use descriptive variable names
- Add comments for complex logic
- Preserve existing patterns

### Security
- Never commit secrets to git
- Use environment variables for sensitive data
- Validate all user inputs
- Avoid XSS vulnerabilities
- Sanitize data before display
- Follow OWASP top 10 guidelines

---

## Technology Stack Reference

### Core Technologies
- **Single-SPA**: 4.4.2 (microfrontend orchestration)
- **SystemJS**: 6.14.1 (module loader)
- **RxJS**: 6.4.0 (reactive state management)
- **Webpack**: 4.41.5 (bundler)
- **Node.js**: 18.20.0

### Frameworks by App
- Angular 8 (single-spa-angular-app)
- React 16 (single-spa-react-app)
- Vue.js 2 (single-spa-vue-app, auth, layout)
- Svelte 3 (single-spa-svelte-app)
- AngularJS 1.x (single-spa-home-app)
- TypeScript (single-spa-typescript-app)
- Lit/Web Components (single-spa-webcomponents-app)
- jQuery 3.6 (single-spa-jquery-app)
- Vanilla ES2020+ (single-spa-vanilla-app)

### Build Tools
- Webpack 4, Babel 7, TypeScript Compiler
- Angular CLI, Vue CLI
- ESLint 8.57.0

### UI Libraries
- Bootstrap 4.4.1
- FontAwesome 5.12.x

### Testing
- Jasmine 3.5.0, Karma 4.1.0 (Angular)
- Jest (React)
- Protractor 5.4.2 (E2E)

---

## Quick Command Reference

```bash
# Development
./run.sh local dev                    # Start dev environment
./stop.sh                              # Stop all processes
npm run mode:status                    # Check current mode

# Building
npm run build:apps                     # Build all apps
npm run build:apps:concurrent          # Parallel build
npm run build:apps:prod                # Production build

# Installation
npm run install:all                    # Sequential install
npm run install:all:concurrent         # Parallel install
npm run clean && npm run install:all   # Clean install

# Publishing
npm run publish:npm:all                # Publish to NPM
npm run publish:nexus:all              # Publish to Nexus
npm run publish:all                    # Publish to both

# Deployment
npm run deploy:aws:prod                # Deploy to S3 (fastest)
npm run trigger:github:pages           # Deploy to GitHub (parallel)
npm run trigger:aws:s3                 # Deploy via Actions (CDN)

# Version Management
npm run version:current                # Show versions
npm run version:bump:patch             # Bump patch version
npm run version:bump:minor             # Bump minor version

# Status Checking
npm run check:local                    # Check local status
npm run check:npm                      # Check NPM status
npm run check:aws                      # Check AWS status
npm run check:cdn                      # Check CloudFront

# Hot Reload (External Modes)
npm run aws:hot-sync                   # Auto-sync to S3
npm run github:hot-sync                # Auto-deploy to GitHub

# Offline Development
npm run offline:setup                  # One-time setup
./run.sh local prod --offline          # Run offline
```

---

## Additional Resources

### Documentation Files
- `README.md` - User-facing documentation
- `DEPLOYMENT-GUIDE.md` - Comprehensive deployment guide
- `LAUNCHER.md` - Launcher script documentation
- `TROUBLESHOOTING.md` - Issue resolution guide
- `MODE-SWITCHING.md` - Mode switching details
- `VERSION-MANAGEMENT.md` - Version sync guide

### External Documentation
- [Single-SPA Docs](https://single-spa.js.org/)
- [Microfrontends Guide](https://martinfowler.com/articles/micro-frontends.html)
- [SystemJS Docs](https://github.com/systemjs/systemjs)
- [RxJS Docs](https://rxjs.dev/)

---

## Summary for AI Assistants

This is a **sophisticated microfrontend platform**, not a simple demo. Key characteristics:

1. **Multi-mode deployment** - Single codebase, 5 deployment targets
2. **Framework diversity** - 11 apps across 9+ frameworks
3. **Shared state** - RxJS-based cross-framework communication
4. **Production-ready** - Live on CloudFront CDN
5. **Highly automated** - 366 npm scripts, comprehensive CI/CD
6. **Version synchronized** - All packages maintained in lockstep

**Most Important**: Always check the deployment mode before making changes, maintain UMD compatibility, and keep shared state integration intact.

**Last Updated**: 2025-11-13
**Version**: 1.0.18
**Maintained by**: Cesar Francisco Chavez Maldonado
