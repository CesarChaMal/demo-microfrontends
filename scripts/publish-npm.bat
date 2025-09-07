@echo off
setlocal enabledelayedexpansion

REM NPM Publishing Script for All Microfrontends (Windows)
REM Usage: publish-all.bat [version-type] [environment]
REM version-type: patch (default), minor, major
REM environment: dev (default), prod

set VERSION_TYPE=%1
if "%VERSION_TYPE%"=="" set VERSION_TYPE=patch
set ENVIRONMENT=%2
if "%ENVIRONMENT%"=="" set ENVIRONMENT=dev

echo 🔍 DEBUG: Called from run.bat: %FROM_RUN_SCRIPT%

REM Auto-switch to NPM registry if not called from run.bat
if not "%FROM_RUN_SCRIPT%"=="true" (
    echo 🔄 Auto-switching to NPM registry...
    if exist ".npmrc" copy ".npmrc" ".npmrc.backup" >nul
    if exist ".npmrc.npm" (
        copy ".npmrc.npm" ".npmrc" >nul
        echo 📝 Registry switched to NPM
    ) else (
        echo ❌ Error: .npmrc.npm not found. Please create it first.
        exit /b 1
    )
)

echo 🚀 Publishing to NPM...
echo 📦 Version bump type: %VERSION_TYPE%
echo 🌐 Environment: %ENVIRONMENT%
echo.
echo 🔑 Authentication Options:
echo   - NPM_TOKEN: Use automation token (recommended for CI/CD)
echo   - NPM_OTP: Provide 2FA code for interactive login
echo   - Manual: Use 'npm login' without environment variables
echo.
echo 🔄 Publishing Workflow:
echo   1. 📈 Bump version for all packages
echo   2. 🔄 Sync cross-package dependencies
echo   3. 🔨 Build each microfrontend
echo   4. 📦 Publish microfrontends to NPM registry
if "%ENVIRONMENT%"=="prod" (
    echo   5. 📦 Publish root app to NPM registry (prod only)
    echo   6. ✅ Verify successful publishing
) else (
    echo   5. ✅ Verify successful publishing
)
echo.

REM Centralized version management
echo 📈 Updating all package versions...
node scripts\version-manager.js bump %VERSION_TYPE%
if errorlevel 1 (
    echo ❌ Version update failed
    exit /b 1
)

REM Get the new version
for /f "delims=" %%i in ('node -e "console.log(require('./package.json').version)"') do set NEW_VERSION=%%i
echo 📋 New version: %NEW_VERSION%

REM Array of microfrontend directories (excluding root app)
set APPS=single-spa-auth-app single-spa-layout-app single-spa-home-app single-spa-angular-app single-spa-vue-app single-spa-react-app single-spa-vanilla-app single-spa-webcomponents-app single-spa-typescript-app single-spa-jquery-app single-spa-svelte-app

REM Main package (root app) - handled separately in prod mode
REM set MAIN_PACKAGE=single-spa-root

echo 🔍 Checking NPM authentication...
if defined NPM_TOKEN (
    echo 🔑 Using NPM_TOKEN for authentication
    echo //registry.npmjs.org/:_authToken=%NPM_TOKEN% > %USERPROFILE%\.npmrc
) else (
    npm whoami >nul 2>&1
    if errorlevel 1 (
        echo ❌ Not logged in to NPM. Please run 'npm login' first or set NPM_TOKEN environment variable.
        exit /b 1
    )
)

echo.
if "%ENVIRONMENT%"=="prod" (
    echo 📋 Packages to publish (12 packages):
    echo   📦 Microfrontend Applications (11):
    for %%a in (%APPS%) do (
        echo     - @cesarchamal/%%a
    )
    echo   📦 Root Application (1) - Main Package:
    echo     - @cesarchamal/single-spa-root
) else (
    echo 📋 Microfrontends to publish (11 packages):
    echo   📦 Microfrontend Applications:
    for %%a in (%APPS%) do (
        echo     - @cesarchamal/%%a
    )
    echo   📝 Note: Main package (root app) not published in dev mode
)
echo.
echo 🔄 Version Synchronization:
echo   - All packages will use the same version: %NEW_VERSION%
echo   - Cross-package dependencies will be updated
echo   - _trigger fields will be removed if present

echo.
REM Interactive prompt (commented out for automation)
REM set /p CONFIRM="Continue with publishing? (y/N): "
REM if /i not "%CONFIRM%"=="y" (
REM     echo ❌ Publishing cancelled.
REM     exit /b 1
REM )
echo 🚀 Proceeding with publishing automatically...

REM Build all apps first
echo.
echo 🔨 Building all apps...
npm run build

REM Publish each app
set FAILED_COUNT=0
set SUCCESS_COUNT=0

for %%a in (%APPS%) do (
    echo.
    echo 📦 Publishing %%a...
    
    cd %%a
    
    if not exist package.json (
        echo ❌ No package.json found in %%a
        cd ..
        set /a FAILED_COUNT+=1
        goto :continue
    )
    
    REM Build the app
    echo 🔨 Building %%a...
    npm run build:prod
    if errorlevel 1 (
        echo ❌ Build failed for %%a
        cd ..
        set /a FAILED_COUNT+=1
        goto :continue
    )
    
    REM Version is already updated by version-manager.js
    echo 📋 Using centrally managed version: %NEW_VERSION%
    
    REM Dry run first
    echo 🧪 Dry run for %%a...
    npm publish --dry-run
    if errorlevel 1 (
        echo ❌ Dry run failed for %%a
        cd ..
        set /a FAILED_COUNT+=1
        goto :continue
    )
    
    REM Setup authentication if needed
    if defined NPM_TOKEN (
        echo 🔑 Using NPM_TOKEN for %%a
        echo //registry.npmjs.org/:_authToken=%NPM_TOKEN% > %USERPROFILE%\.npmrc
    )
    
    REM Actual publish
    echo 🚀 Publishing %%a to NPM...
    if defined NPM_OTP (
        npm publish --otp="%NPM_OTP%"
    ) else (
        npm publish
    )
    if errorlevel 1 (
        echo ❌ Failed to publish %%a
        cd ..
        set /a FAILED_COUNT+=1
        goto :continue
    ) else (
        echo ✅ Successfully published %%a
        set /a SUCCESS_COUNT+=1
    )
    
    cd ..
    
    :continue
)

REM Publish root app in production mode
if "%ENVIRONMENT%"=="prod" (
    echo.
    echo 📦 Production mode: Publishing root app to NPM for public access
    cd single-spa-root
    echo 🔍 DEBUG: Publishing root app from %CD%
    
    REM Dry run first
    echo 🧪 Dry run for root app...
    npm publish --dry-run
    if errorlevel 1 (
        echo ❌ Root app dry run failed
        cd ..
        exit /b 1
    )
    
    REM Setup authentication if needed
    if defined NPM_TOKEN (
        echo 🔑 Using NPM_TOKEN for root app
        echo //registry.npmjs.org/:_authToken=%NPM_TOKEN% > %USERPROFILE%\.npmrc
    )
    
    REM Actual publish
    echo 🚀 Publishing root app to NPM...
    if defined NPM_OTP (
        npm publish --otp="%NPM_OTP%"
    ) else (
        npm publish
    )
    if errorlevel 1 (
        echo ❌ Failed to publish root app
        cd ..
        exit /b 1
    ) else (
        echo ✅ Successfully published root app
        echo 🌍 Public NPM Package: https://www.npmjs.com/package/@cesarchamal/single-spa-root
    )
    
    cd ..
)

REM Summary
echo.
echo 📊 Publishing Summary:
echo ✅ Successful: %SUCCESS_COUNT%
echo ❌ Failed: %FAILED_COUNT%

if %FAILED_COUNT% gtr 0 (
    exit /b 1
)

echo.
echo 🎉 All packages published successfully!
echo.
echo 📝 Next steps:
echo 1. Switch to NPM mode to test loading from NPM packages
echo 2. Use 'npm run mode:npm' to load microfrontends from registry
if "%ENVIRONMENT%"=="prod" (
    echo 3. Root app is now publicly available on NPM registry
)