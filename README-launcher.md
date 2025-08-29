# Launcher Scripts Usage

## Enhanced Launcher Scripts

The launcher scripts now support both **mode** and **environment** parameters:

### Usage

```bash
# Linux/Mac
./run.sh [mode] [environment]

# Windows
run.bat [mode] [environment]
```

### Parameters

**Mode** (first parameter):
- `local` (default) - Run all microfrontends locally
- `npm` - Use NPM packages
- `nexus` - Use Nexus private registry
- `github` - Use GitHub Pages

**Environment** (second parameter):
- `dev` (default) - Development build and server
- `prod` - Production build and server

### Examples

```bash
# Development (default)
./run.sh local dev
./run.sh local        # dev is default

# Production builds
./run.sh local prod   # Local mode with production build
./run.sh npm prod     # NPM mode with production build
./run.sh github prod  # GitHub mode with production build

# Windows examples
run.bat local prod
run.bat npm dev
run.bat github prod
```

### What Each Combination Does

| Mode | Environment | Build Command | Server Command | Description |
|------|-------------|---------------|----------------|-------------|
| `local` | `dev` | `npm run build:all` | `npm run dev:all` | All microfrontends running locally in dev mode |
| `local` | `prod` | `npm run build:apps` | `npm start` | Production build served locally |
| `npm` | `dev` | `npm run build:all` | `npm run serve:root` | Dev build, NPM packages |
| `npm` | `prod` | `npm run build:apps` | `npm start` | Production build, NPM packages |
| `nexus` | `dev` | `npm run build:all` | `npm run serve:root` | Dev build, Nexus registry |
| `nexus` | `prod` | `npm run build:apps` | `npm start` | Production build, Nexus registry |
| `github` | `dev` | `npm run build:all` | `npm run serve:root` | Dev build, GitHub Pages |
| `github` | `prod` | `npm run build:apps` | `npm start` | Production build, GitHub Pages |

### Production vs Development

**Development (`dev`)**:
- Uses `npm run build:all` (development builds)
- Starts development servers with hot reload
- Better for debugging and development

**Production (`prod`)**:
- Uses `npm run build:apps` (production builds)
- Starts optimized production server
- Minified, optimized builds for testing production-like behavior