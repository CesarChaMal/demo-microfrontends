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
├── single-spa-login-example-with-npm-packages/  # Root application
├── single-spa-auth-app/                         # Vue.js authentication app
├── single-spa-layout-app/                       # Vue.js layout components
├── single-spa-home-app/                         # AngularJS home page
├── single-spa-angular-app/                      # Angular 8 application
├── single-spa-react-app/                        # React application
└── single-spa-vue-app/                          # Vue.js application
```

## Microfrontends

### 1. Root Application (`single-spa-login-example-with-npm-packages`)
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

## Prerequisites

- Node.js (v18.0.0 or higher)
- npm (v8.0.0 or higher)

## Quick Start

### Launcher Scripts (Recommended)

#### Mode-Aware Launcher (`run.sh` / `run.bat`)

**Basic Usage:**
```bash
# Windows - Start
run.bat [mode]
# Windows - Stop
stop.bat

# Linux/Mac - Start
./run.sh [mode]
# Linux/Mac - Stop
./stop.sh
```

**Available Modes:**
- `local` (default) - Local development with SystemJS
- `npm` - Uses NPM packages directly
- `nexus` - Uses Nexus private registry packages
- `github` - Loads from GitHub Pages

**What Each Mode Launches:**

| Mode | Apps Running | Ports Used | Use Case |
|------|-------------|------------|----------|
| `local` | All 7 apps (root + 6 microfrontends) | 8080, 4201-4206 | Full development environment |
| `npm` | Root app only | 8080 | Test NPM package loading |
| `nexus` | Root app only | 8080 | Test Nexus private registry |
| `github` | Root app only | 8080 | Test remote GitHub Pages loading |

**Examples:**
```bash
# Full development environment (all apps running)
run.bat
./run.sh

# Lightweight NPM package testing
run.bat npm
./run.sh npm

# Nexus private registry testing
run.bat nexus
./run.sh nexus

# GitHub Pages remote loading
run.bat github
./run.sh github
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
- Always runs all 7 applications
- Quick start for development
- Uses ports 8080, 4201-4206

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
npm run build:apps
npm run build
npm start
```

## Individual Application Setup

### Root Application
```bash
cd single-spa-login-example-with-npm-packages
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
- Similar patterns for: layout, home, vue, react

## Technology Stack

### Frontend Technologies
- **Single-SPA**: Microfrontend orchestration
- **Angular 8**: Modern Angular framework
- **React 16**: React library with hooks
- **Vue.js 2**: Progressive JavaScript framework
- **AngularJS 1.x**: Legacy Angular for comparison
- **Bootstrap 4**: CSS framework
- **SystemJS**: Module loader

### Build Tools
- **Webpack 4**: Module bundler
- **Babel**: JavaScript transpiler
- **ESLint**: Code linting
- **Various CLI tools**: Angular CLI, Vue CLI, Create React App

## Development Workflow

### Mode Selection

**URL Parameters (Temporary):**
```
http://localhost:8080?mode=local    # Local development
http://localhost:8080?mode=npm      # NPM packages
http://localhost:8080?mode=nexus    # Nexus private registry
http://localhost:8080?mode=github   # GitHub Pages
```

**Browser Console (Persistent):**
```javascript
localStorage.setItem('spa-mode', 'npm');     // Switch to NPM
localStorage.setItem('spa-mode', 'nexus');   // Switch to Nexus
localStorage.setItem('spa-mode', 'github');  // Switch to GitHub
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

## Features

- **Framework Agnostic**: Multiple frontend frameworks coexisting
- **Independent Deployment**: Each microfrontend can be deployed separately
- **Multiple Loading Strategies**: Local, NPM packages, or remote GitHub Pages
- **Dynamic Mode Switching**: Change loading strategy without code changes
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

- Juan Manuel López Pazos (Original author)
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

- [Single-SPA Documentation](https://single-spa.js.org/)
- [Microfrontends.info](https://microfrontends.info/)
- [Angular Documentation](https://angular.io/)
- [React Documentation](https://reactjs.org/)
- [Vue.js Documentation](https://vuejs.org/)