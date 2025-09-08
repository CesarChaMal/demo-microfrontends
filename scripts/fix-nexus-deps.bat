@echo off
setlocal enabledelayedexpansion

REM Fix Nexus Dependencies Script (Windows)
REM Usage: fix-nexus-deps.bat [app-directory]

set APP_DIR=%1
if "%APP_DIR%"=="" set APP_DIR=single-spa-root
set ORG_NAME=%ORG_NAME%
if "%ORG_NAME%"=="" set ORG_NAME=cesarchamal

echo 🔧 Fixing Nexus dependencies for %APP_DIR%...

REM 1. Copy Nexus registry config
if exist ".npmrc.nexus" (
    copy ".npmrc.nexus" "%APP_DIR%\.npmrc" >nul
    echo ✅ Copied Nexus registry config
) else (
    echo ❌ .npmrc.nexus not found
    exit /b 1
)

REM 2. Check available versions in Nexus
echo 🔍 Checking available versions in Nexus...
for /f "tokens=*" %%i in ('npm view "@%ORG_NAME%/single-spa-auth-app" version') do set AVAILABLE_VERSION=%%i

if "%AVAILABLE_VERSION%"=="" (
    echo ❌ No packages found in Nexus. Run: npm run publish:nexus:prod
    exit /b 1
)

echo 📦 Latest available version: %AVAILABLE_VERSION%

REM 3. Update package.json dependencies
cd "%APP_DIR%"
echo 📝 Updating dependencies to version %AVAILABLE_VERSION%...

REM Simple replacement - update manually for now
echo ⚠️  Please manually update package.json dependencies to version %AVAILABLE_VERSION%

REM 4. Install dependencies
echo 📦 Installing dependencies...
npm install

if errorlevel 1 (
    echo ❌ Installation failed
    exit /b 1
) else (
    echo 🎉 Dependencies installed successfully!
)