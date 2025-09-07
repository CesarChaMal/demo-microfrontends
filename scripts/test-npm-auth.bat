@echo off
setlocal enabledelayedexpansion

REM Test NPM Authentication Script (Windows)
REM Usage: test-npm-auth.bat

echo 🧪 Testing NPM Authentication...
echo 🔍 Current directory: %CD%

REM Check if NPM_TOKEN is set
if not defined NPM_TOKEN (
    echo ❌ NPM_TOKEN not set. Please set it first:
    echo    set NPM_TOKEN=npm_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    exit /b 1
)

echo ✅ NPM_TOKEN is set

REM Test authentication setup
echo 🔑 Setting up NPM authentication...
npm config set //registry.npmjs.org/:_authToken %NPM_TOKEN%

REM Test npm whoami
echo 🔍 Testing npm whoami...
npm whoami >nul 2>&1
if errorlevel 1 (
    echo ❌ NPM authentication failed
    exit /b 1
) else (
    echo ✅ NPM authentication successful!
)

REM Test dry run publish on auth app (smallest app)
echo 🧪 Testing dry run publish on single-spa-auth-app...
cd single-spa-auth-app

REM Check if built
if not exist "dist\single-spa-auth-app.umd.js" (
    echo 📦 Building auth app first...
    npm run build:prod
)

echo 🧪 Running npm publish --dry-run...
set "NPM_CONFIG_//registry.npmjs.org/:_authToken=%NPM_TOKEN%"
npm publish --dry-run >nul 2>&1

if errorlevel 1 (
    echo ❌ Dry run failed. Check authentication setup.
    cd ..
    exit /b 1
) else (
    echo ✅ Dry run successful! NPM_TOKEN authentication is working.
)

cd ..
echo 🎉 NPM authentication test completed successfully!