@echo off
setlocal enabledelayedexpansion

REM Fix NPM Dependencies Script (Windows)
REM Usage: fix-npm-deps.bat [app-directory]

set APP_DIR=%1
if "%APP_DIR%"=="" set APP_DIR=single-spa-root
set ORG_NAME=%ORG_NAME%
if "%ORG_NAME%"=="" set ORG_NAME=cesarchamal

echo 🔧 Fixing NPM dependencies for %APP_DIR%...

REM 1. Switch to NPM registry
if exist ".npmrc.npm" (
    copy ".npmrc.npm" "%APP_DIR%\.npmrc" >nul
    echo ✅ Copied NPM registry config
) else if exist ".npmrc.backup" (
    copy ".npmrc.backup" "%APP_DIR%\.npmrc" >nul
    echo ✅ Restored original NPM registry config
) else (
    if exist "%APP_DIR%\.npmrc" del "%APP_DIR%\.npmrc"
    echo ✅ Using default NPM registry
)

REM 2. Check available versions in NPM
echo 🔍 Checking available versions in NPM...
for /f "tokens=*" %%i in ('npm view "@%ORG_NAME%/single-spa-auth-app" version 2^>nul') do set AVAILABLE_VERSION=%%i

if "%AVAILABLE_VERSION%"=="" (
    echo ❌ No packages found in NPM. Run: npm run publish:npm:prod
    exit /b 1
)

echo 📦 Latest available version: %AVAILABLE_VERSION%

REM 3. Update package.json dependencies
cd "%APP_DIR%"
echo 📝 Updating dependencies to version %AVAILABLE_VERSION%...

REM Simple replacement - update manually for now
echo ⚠️  Please manually update package.json dependencies to version %AVAILABLE_VERSION%

REM 4. Clear npm cache and install dependencies
echo 🧹 Clearing NPM cache...
npm cache clean --force

echo 📦 Installing dependencies...
npm install

if errorlevel 1 (
    echo ❌ Installation failed
    exit /b 1
) else (
    echo 🎉 Dependencies installed successfully!
)