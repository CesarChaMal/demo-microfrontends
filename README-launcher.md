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
- `aws` - Use AWS S3 for microfrontends

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
./run.sh aws prod     # AWS S3 mode with production build

# Windows examples
run.bat local prod
run.bat npm dev
run.bat github prod
run.bat aws prod
```

### What Each Combination Does

| Mode | Environment | Build Command | Server Command | Description |
|------|-------------|---------------|----------------|-------------|
| `local` | `dev` | `npm run build:dev` | `npm run dev:all` | All microfrontends running locally in dev mode |
| `local` | `prod` | `npm run build:prod` | `npm start` | Production build served locally |
| `npm` | `dev` | `npm run build:dev` | `npm run serve:root` | Dev build, NPM packages |
| `npm` | `prod` | `npm run build:prod` | `npm start` | Production build, NPM packages |
| `nexus` | `dev` | `npm run build:dev` | `npm run serve:root` | Dev build, Nexus registry |
| `nexus` | `prod` | `npm run build:prod` | `npm start` | Production build, Nexus registry |
| `github` | `dev` | `npm run build:dev` | `npm run serve:root` | Dev build, GitHub Pages |
| `github` | `prod` | `npm run build:prod` | `npm start` | Production build, GitHub Pages |
| `aws` | `dev` | `npm run build:dev` | `npm run serve:root` | Dev build, AWS S3 microfrontends |
| `aws` | `prod` | `npm run build:prod` | `npm start` | Production build, AWS S3 microfrontends |

## Environment Differences

### Development Environment (`dev`)

**Build Characteristics:**
- **Fast builds** - Unminified code, no optimization
- **Source maps** - For debugging
- **Hot reload** - Live code updates
- **Detailed error messages** - Better debugging
- **Development dependencies** - Testing tools, dev servers

**Build Command:** `npm run build:dev`

**Use Cases:**
- Active development and coding
- Debugging and testing features
- Hot reload for rapid iteration
- Full microfrontend ecosystem testing

### Production Environment (`prod`)

**Build Characteristics:**
- **Optimized builds** - Minified, tree-shaken, compressed
- **No source maps** - Smaller bundle size
- **Environment variables** - Production API endpoints
- **Security** - Remove dev tools, console logs
- **Performance** - Code splitting, lazy loading

**Build Command:** `npm run build:prod`

**Use Cases:**
- Testing production builds locally
- Performance testing
- Final validation before deployment
- CI/CD pipeline testing

### Build Script Architecture

**Root Level Scripts:**
- `build:dev` - Calls individual `build:*:dev` scripts
- `build:prod` - Calls individual `build:*:prod` scripts
- `build:all` - Legacy script (same as `build:dev`)
- `build:apps` - Legacy script (same as `build:all`)

**Individual App Scripts:**
- `build:auth:dev` / `build:auth:prod`
- `build:layout:dev` / `build:layout:prod`
- `build:vue:dev` / `build:vue:prod`
- And so on for all 11 microfrontends...

### Framework-Specific Build Modes

**Vue.js Apps:**
```bash
# Development
vue-cli-service build --target lib --formats umd src/singleSpaEntry.js --mode development

# Production
vue-cli-service build --target lib --formats umd src/singleSpaEntry.js --mode production
```

**Angular Apps:**
```bash
# Development
ng build --configuration development

# Production
ng build --configuration production
```

**React Apps:**
```bash
# Development
REACT_APP_ENV=development npm run build

# Production
REACT_APP_ENV=production npm run build
```

**Webpack-based Apps:**
```bash
# Development
webpack --mode development

# Production
webpack --mode production
```

## Deployment Scripts

### S3 Deployment

**Manual Deployment:**
```bash
# Linux/macOS/Git Bash
./deploy-s3.sh [dev|prod]

# Windows
deploy-s3.bat [dev|prod]
```

**GitHub Actions Deployment:**
```bash
# Linux/macOS/Git Bash
./trigger-deploy.sh

# Windows
trigger-deploy.bat
```

### S3 Bucket Setup

**Setup S3 bucket for public access:**
```bash
# Linux/macOS/Git Bash
./scripts/setup-s3.sh public

# Windows
scripts\setup-s3.bat public
```

**Available S3 setup actions:**
- `s3` - Basic S3 bucket only (default)
- `cors` - S3 bucket + CORS configuration
- `public` - Full public website setup (bucket + website + policy + CORS)

### Deployment Workflow

1. **Setup S3 bucket** (one-time):
   ```bash
   ./scripts/setup-s3.sh public
   ```

2. **Choose deployment method:**
   
   **Option A - Manual deployment:**
   ```bash
   ./deploy-s3.sh prod
   ```
   
   **Option B - GitHub Actions:**
   ```bash
   ./trigger-deploy.sh
   git add .
   git commit -m "Deploy all microfrontends"
   git push origin main
   ```

3. **Access your live app:**
   ```
   http://your-bucket.s3-website-region.amazonaws.com
   ```