@echo off
setlocal enabledelayedexpansion

REM NPM Publishing Script for All Microfrontends (Windows)
REM Usage: publish-all.bat [version-type]
REM version-type: patch (default), minor, major

set VERSION_TYPE=%1
if "%VERSION_TYPE%"=="" set VERSION_TYPE=patch

echo 🚀 Publishing all microfrontends to NPM...
echo 📦 Version bump type: %VERSION_TYPE%
echo.
echo 🔄 Publishing Workflow:
echo   1. 📈 Bump version for all 13 packages
echo   2. 🔄 Sync cross-package dependencies
echo   3. 🔨 Build each microfrontend
echo   4. 📦 Publish to NPM registry
echo   5. ✅ Verify successful publishing
echo.

REM Centralized version management
echo 📈 Updating all package versions...
node version-manager.js bump %VERSION_TYPE%
if errorlevel 1 (
    echo ❌ Version update failed
    exit /b 1
)

REM Get the new version
for /f "delims=" %%i in ('node -e "console.log(require('./package.json').version)"') do set NEW_VERSION=%%i
echo 📋 New version: %NEW_VERSION%

REM Array of all microfrontend directories
set APPS=single-spa-auth-app single-spa-layout-app single-spa-home-app single-spa-angular-app single-spa-vue-app single-spa-react-app single-spa-vanilla-app single-spa-webcomponents-app single-spa-typescript-app single-spa-jquery-app single-spa-svelte-app single-spa-root

REM Main package (commented out for now)
REM set MAIN_PACKAGE=.

echo 🔍 Checking NPM authentication...
npm whoami >nul 2>&1
if errorlevel 1 (
    echo ❌ Not logged in to NPM. Please run 'npm login' first.
    exit /b 1
)

echo.
echo 📋 Apps to publish (13 packages):
echo   📦 Main Package:
echo     - demo-microfrontends (main package - commented out)
echo   🏠 Root Application:
echo     - @cesarchamal/single-spa-root
echo   📦 Microfrontend Applications:
for %%a in (%APPS%) do (
    if not "%%a"=="single-spa-root" (
        echo     - @cesarchamal/%%a
    )
)
echo.
echo 🔄 Version Synchronization:
echo   - All packages will use the same version: %NEW_VERSION%
echo   - Cross-package dependencies will be updated
echo   - _trigger fields will be removed if present

echo.
set /p CONFIRM="Continue with publishing? (y/N): "
if /i not "%CONFIRM%"=="y" (
    echo ❌ Publishing cancelled.
    exit /b 1
)

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
    
    REM Actual publish
    echo 🚀 Publishing %%a to NPM...
    npm publish
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

REM Summary
echo.
echo 📊 Publishing Summary:
echo ✅ Successful: %SUCCESS_COUNT%
echo ❌ Failed: %FAILED_COUNT%

if %FAILED_COUNT% gtr 0 (
    exit /b 1
) else (
    echo.
    echo 🎉 All packages published successfully!
    echo.
    echo 📝 Next steps:
    echo 1. Update root application to use NPM mode
    echo 2. Test loading from NPM packages
    echo 3. Update documentation
)