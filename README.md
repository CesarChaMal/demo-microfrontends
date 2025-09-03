# Demo Microfrontends with Single-SPA

A comprehensive demonstration of microfrontend architecture using Single-SPA framework, showcasing multiple frontend technologies working together in a unified application.

## Architecture Overview

This project demonstrates a microfrontend architecture with:
- **Root Application**: Orchestrates and manages all microfrontends
- **Multiple Microfrontends**: Independent applications built with different frameworks
- **Authentication**: Centralized login system
- **Shared Layout**: Common header, navigation, and footer components

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

### 2. Authentication App (`single-spa-auth-app`)
- **Framework**: Vue.js
- **Port**: 4201
- **Purpose**: Login functionality
- **Route**: `/login`

### 3. Layout App (`single-spa-layout-app`)
- **Framework**: Vue.js
- **Port**: 4202
- **Purpose**: Shared header, navbar, and footer
- **Active**: All routes except `/login`

### 4. Home App (`single-spa-home-app`)
- **Framework**: AngularJS 1.x
- **Port**: 4203
- **Purpose**: Landing page
- **Route**: `/`

### 5. Angular App (`single-spa-angular-app`)
- **Framework**: Angular 8
- **Port**: 4204
- **Purpose**: Feature-rich application with routing
- **Route**: `/angular/*`

### 6. React App (`single-spa-react-app`)
- **Framework**: React 16
- **Port**: 4206
- **Purpose**: React-based features
- **Route**: `/react/*`

### 7. Vue App (`single-spa-vue-app`)
- **Framework**: Vue.js 2
- **Port**: 4205
- **Purpose**: Vue-based features
- **Route**: `/vue/*`

### 8. Vanilla App (`single-spa-vanilla-app`)
- **Framework**: Pure JavaScript (ES2020+)
- **Port**: 4207
- **Purpose**: Modern vanilla JS with native APIs
- **Route**: `/vanilla/*`

### 9. Web Components App (`single-spa-webcomponents-app`)
- **Framework**: Lit + Web Components
- **Port**: 4208
- **Purpose**: Browser-native components with Shadow DOM
- **Route**: `/webcomponents/*`

### 10. TypeScript App (`single-spa-typescript-app`)
- **Framework**: TypeScript with strict typing
- **Port**: 4209
- **Purpose**: Type-safe development and compile-time validation
- **Route**: `/typescript/*`

### 11. jQuery App (`single-spa-jquery-app`)
- **Framework**: jQuery 3.6.0 (Legacy library)
- **Port**: 4210
- **Purpose**: Legacy library integration and migration strategies
- **Route**: `/jquery/*`

### 12. Svelte App (`single-spa-svelte-app`)
- **Framework**: Svelte 3 (Compile-time optimized)
- **Port**: 4211
- **Purpose**: Reactive programming with minimal runtime overhead
- **Route**: `/svelte/*`

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

| Mode | Environment | Apps Running | Build Type | Use Case |
|------|-------------|-------------|------------|----------|
| `local` | `dev` | All 12 apps | Development | Full development environment |
| `local` | `prod` | Root app only | Production | Test production build locally |
| `npm` | `dev` | Root app only | Development | Test NPM package loading |
| `npm` | `prod` | Root app only | Production | Test NPM packages in production |
| `nexus` | `dev` | Root app only | Development | Test Nexus private registry |
| `nexus` | `prod` | Root app only | Production | Test Nexus in production |
| `github` | `dev` | Root app only | Development | Read from existing GitHub Pages |
| `github` | `prod` | Root app only | Production | Create repos + deploy to GitHub Pages |
| `aws` | `dev` | Root app only | Development | Test AWS S3 loading |
| `aws` | `prod` | Root app only | Production | Test AWS S3 in production |

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
npm run build:apps
npm run build
npm start

# Or use launcher script
./run.sh local prod
run.bat local prod
```

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

### Mode-Specific Scripts
- `npm run serve:local` - Start in local development mode
- `npm run serve:npm` - Start in NPM packages mode
- `npm run serve:nexus` - Start in Nexus private registry mode
- `npm run serve:github` - Start in GitHub Pages mode
- `npm run serve:aws` - Start in AWS S3 mode

### Root Project Scripts
- `npm run install:all` - Install dependencies for all applications
- `npm run build:all` - Build all microfrontends
- `npm run serve:root` - Start root development server
- `npm run clean` - Clean all node_modules
- `npm start` - Start development environment

### Individual App Scripts
- `npm run install:auth` - Install auth app dependencies
- `npm run build:auth` - Build auth application
- `npm run install:angular` - Install Angular app dependencies
- `npm run build:angular` - Build Angular application
- Similar patterns for: layout, home, vue, react, vanilla, webcomponents, typescript, jquery, svelte

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
./deploy-s3.sh [dev|prod]

# Windows
deploy-s3.bat [dev|prod]
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

## Features

- **Framework Agnostic**: Multiple frontend frameworks coexisting
- **Independent Deployment**: Each microfrontend can be deployed separately
- **Multiple Loading Strategies**: Local, NPM packages, GitHub Pages, or AWS S3
- **Dynamic Mode Switching**: Change loading strategy without code changes
- **Environment-Driven Configuration**: AWS and GitHub settings via environment variables
- **Automated GitHub Deployment**: Auto-creates repos and deploys in production mode
- **Dual GitHub Modes**: Development (read existing) vs Production (create & deploy)
- **Shared Dependencies**: Common libraries managed efficiently
- **Authentication Flow**: Centralized login system
- **Routing**: Client-side routing across applications
- **Hot Reloading**: Development-friendly setup

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

## Troubleshooting

### Common Issues

1. **Port Conflicts**: Ensure all required ports are available
2. **Node Version**: Use Node.js v18 or higher
3. **Memory Issues**: Increase Node.js memory limit if needed
4. **CORS Issues**: Applications are configured with CORS support

### Debug Mode

Enable debug logging by setting environment variables:
```bash
DEBUG=single-spa:* npm run serve
```

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