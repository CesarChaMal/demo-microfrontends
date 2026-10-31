@echo off
setlocal enabledelayedexpansion

REM Nexus Publishing Script for All Microfrontends (Windows)
REM Usage: publish-nexus.bat [version-type] [environment]
REM version-type: patch (default), minor, major
REM environment: dev (default), prod

set VERSION_TYPE=%1
if "%VERSION_TYPE%"=="" set VERSION_TYPE=patch
set ENVIRONMENT=%2
if "%ENVIRONMENT%"=="" set ENVIRONMENT=dev

echo 🔍 DEBUG: Called from run.bat: %FROM_RUN_SCRIPT%

REM Load environment variables from .env file
echo 🔍 DEBUG: Looking for .env file in current directory: %CD%
if exist ".env" (
    echo 📄 Loading environment variables from .env...
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%a:~0,1"=="#" set %%a=%%b
    )
    echo 🔍 DEBUG: Environment variables loaded from .env
) else if exist "../.env" (
    echo 📄 Loading environment variables from ../.env...
    for /f "usebackq tokens=1,2 delims==" %%a in ("../.env") do (
        if not "%%a"=="" if not "%%a:~0,1"=="#" set %%a=%%b
    )
    echo 🔍 DEBUG: Environment variables loaded from ../.env
) else (
    echo ⚠️ Warning: No .env file found, using environment variables only
)

REM Set Nexus configuration with fallback to environment variables
if "%NEXUS_USER%"=="" set NEXUS_USER=admin
if "%NEXUS_URL%"=="" set NEXUS_URL=http://localhost:8081
if "%NEXUS_REGISTRY%"=="" set NEXUS_REGISTRY=http://localhost:8081/repository/npm-group/
if "%NEXUS_PUBLISH_REGISTRY%"=="" set NEXUS_PUBLISH_REGISTRY=http://localhost:8081/repository/npm-hosted-releases/

echo 🔍 DEBUG: Nexus configuration - USER=%NEXUS_USER%, URL=%NEXUS_URL%
echo 🔍 DEBUG: Registry: %NEXUS_REGISTRY%
echo 🔍 DEBUG: Publish Registry: %NEXUS_PUBLISH_REGISTRY%

if "%NEXUS_PASS%"=="" (
    echo ❌ Error: NEXUS_PASS not set in .env file or environment variables
    echo 💡 Please set NEXUS_PASS in .env file or set NEXUS_PASS=your-password
    exit /b 1
)

REM Auto-switch to Nexus registry if not called from run.bat
if not "%FROM_RUN_SCRIPT%"=="true" (
    echo 🔄 Auto-switching to Nexus registry...
    if exist ".npmrc" copy ".npmrc" ".npmrc.backup" >nul
    if exist ".npmrc.nexus" (
        copy ".npmrc.nexus" ".npmrc" >nul
        echo 📝 Registry switched to Nexus
    ) else (
        echo ❌ Error: .npmrc.nexus not found. Please create it first.
        exit /b 1
    )
)

echo 🚀 Publishing to Nexus...
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
echo   4. 📦 Publish microfrontends to Nexus registry
if "%ENVIRONMENT%"=="prod" (
    echo   5. 📦 Publish root app to Nexus registry (prod only)
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

REM Define packages based on environment
if "%ENVIRONMENT%"=="prod" (
    REM Production: publish all 13 packages including root
    set APPS=single-spa-auth-app single-spa-layout-app single-spa-home-app single-spa-angular-app single-spa-vue-app single-spa-react-app single-spa-vanilla-app single-spa-webcomponents-app single-spa-typescript-app single-spa-jquery-app single-spa-svelte-app single-spa-solid-app single-spa-root
) else (
    REM Development: publish nothing
    set APPS=
)

echo 🔍 Checking Nexus authentication...
echo 📝 Using .npmrc.nexus configuration for authentication
npm whoami >nul 2>&1
if errorlevel 1 (
    echo ❌ Nexus authentication failed. Please check .npmrc.nexus configuration.
    for /f "tokens=*" %%i in ('npm config get registry') do echo 💡 Current registry: %%i
    echo 💡 Make sure .npmrc.nexus contains proper authentication:
    echo    - registry=http://localhost:8081/repository/npm-group/
    echo    - //localhost:8081/repository/npm-group/:_auth=^<base64-user:pass^>
    echo    - //localhost:8081/repository/npm-group/:always-auth=true
    exit /b 1
)

echo.
if "%ENVIRONMENT%"=="prod" (
    echo 📋 Packages to publish (13 packages):
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
    
    REM Create .npmrc with Nexus authentication
    if exist "..\.npmrc.nexus" (
        copy "..\.npmrc.nexus" ".npmrc" >nul
        echo    📋 Copied .npmrc.nexus to app directory
    ) else (
        REM Generate .npmrc from environment variables
        echo    📋 Generating .npmrc from environment variables
        powershell -Command "[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('%NEXUS_USER%:%NEXUS_PASS%'))" > temp_auth.txt
        set /p AUTH_TOKEN=<temp_auth.txt
        del temp_auth.txt
        (
            echo registry=%NEXUS_REGISTRY%
            echo //localhost:8081/repository/npm-group/:_auth=!AUTH_TOKEN!
            echo //localhost:8081/repository/npm-hosted-releases/:_auth=!AUTH_TOKEN!
            echo //localhost:8081/repository/npm-group/:always-auth=true
            echo //localhost:8081/repository/npm-hosted-releases/:always-auth=true
        ) > .npmrc
    )
    
    REM Dry run first
    echo 🧪 Dry run for %%a...
    npm publish --dry-run --registry=%NEXUS_PUBLISH_REGISTRY%
    if errorlevel 1 (
        echo ❌ Dry run failed for %%a
        cd ..
        set /a FAILED_COUNT+=1
        goto :continue
    )
    
    REM Actual publish to Nexus hosted repository
    echo 🚀 Publishing %%a to Nexus...
    if defined NPM_OTP (
        npm publish --otp="%NPM_OTP%" --registry=%NEXUS_PUBLISH_REGISTRY%
    ) else (
        npm publish --registry=%NEXUS_PUBLISH_REGISTRY%
    )
    
    REM Clean up .npmrc from app directory
    del ".npmrc" >nul 2>&1
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
    echo 📦 Production mode: Publishing root app to Nexus for public access
    cd single-spa-root
    echo 🔍 DEBUG: Publishing root app from %CD%
    
    REM Dry run first
    echo 🧪 Dry run for root app...
    npm publish --dry-run --registry=%NEXUS_PUBLISH_REGISTRY%
    if errorlevel 1 (
        echo ❌ Root app dry run failed
        cd ..
        exit /b 1
    )
    
    REM Create .npmrc with Nexus authentication
    if exist "..\.npmrc.nexus" (
        copy "..\.npmrc.nexus" ".npmrc" >nul
        echo    📋 Copied .npmrc.nexus to root directory
    ) else (
        REM Generate .npmrc from environment variables
        echo    📋 Generating .npmrc from environment variables
        powershell -Command "[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('%NEXUS_USER%:%NEXUS_PASS%'))" > temp_auth.txt
        set /p AUTH_TOKEN=<temp_auth.txt
        del temp_auth.txt
        (
            echo registry=%NEXUS_REGISTRY%
            echo //localhost:8081/repository/npm-group/:_auth=!AUTH_TOKEN!
            echo //localhost:8081/repository/npm-hosted-releases/:_auth=!AUTH_TOKEN!
            echo //localhost:8081/repository/npm-group/:always-auth=true
            echo //localhost:8081/repository/npm-hosted-releases/:always-auth=true
        ) > .npmrc
    )
    
    REM Actual publish
    echo 🚀 Publishing root app to Nexus...
    if defined NPM_OTP (
        npm publish --otp="%NPM_OTP%" --registry=%NEXUS_PUBLISH_REGISTRY%
    ) else (
        npm publish --registry=%NEXUS_PUBLISH_REGISTRY%
    )
    
    REM Clean up .npmrc from root directory
    del ".npmrc" >nul 2>&1
    if errorlevel 1 (
        echo ❌ Failed to publish root app
        cd ..
        exit /b 1
    ) else (
        echo ✅ Successfully published root app
        echo 🌍 Public Nexus Package: Available on Nexus registry
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
echo 1. Switch to Nexus mode to test loading from Nexus packages
echo 2. Use 'npm run mode:nexus' to load microfrontends from registry
if "%ENVIRONMENT%"=="prod" (
    echo 3. Root app is now publicly available on Nexus registry
)