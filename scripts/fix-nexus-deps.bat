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

REM 2. Check available versions in Nexus (force Nexus registry)
echo 🔍 Checking available versions in Nexus...
REM Get Nexus registry URL from .npmrc.nexus
for /f "tokens=2 delims==" %%i in ('findstr "^registry=" .npmrc.nexus') do set NEXUS_REGISTRY=%%i
if "%NEXUS_REGISTRY%"=="" (
    echo ❌ No registry found in .npmrc.nexus
    exit /b 1
)
for /f "tokens=*" %%i in ('npm view "@%ORG_NAME%/single-spa-auth-app" version --registry "%NEXUS_REGISTRY%" 2^>nul') do set AVAILABLE_VERSION=%%i

if "%AVAILABLE_VERSION%"=="" (
    echo ❌ No packages found in Nexus. Run: npm run publish:nexus:prod
    exit /b 1
)

echo 📦 Latest available version: %AVAILABLE_VERSION%

REM 3. Update package.json dependencies and version
cd "%APP_DIR%"
echo 📝 Updating dependencies to version %AVAILABLE_VERSION%...

REM Update main package version to match Nexus registry
if "%APP_DIR%"=="single-spa-root" (
    powershell -Command "(Get-Content package.json) -replace '\"version\": \"[^\"]*\"', '\"version\": \"%AVAILABLE_VERSION%\"' | Set-Content package.json"
    echo 📝 Updated main package version to %AVAILABLE_VERSION%
    
    REM Also update root directory package.json
    cd ..
    powershell -Command "(Get-Content package.json) -replace '\"version\": \"[^\"]*\"', '\"version\": \"%AVAILABLE_VERSION%\"' | Set-Content package.json"
    echo 📝 Updated root package version to %AVAILABLE_VERSION%
    cd "%APP_DIR%"
)

REM Update all microfrontend dependencies
powershell -Command "(Get-Content package.json) -replace '\"@%ORG_NAME%/single-spa-auth-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-auth-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package.json"
powershell -Command "(Get-Content package.json) -replace '\"@%ORG_NAME%/single-spa-layout-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-layout-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package.json"
powershell -Command "(Get-Content package.json) -replace '\"@%ORG_NAME%/single-spa-home-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-home-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package.json"
powershell -Command "(Get-Content package.json) -replace '\"@%ORG_NAME%/single-spa-angular-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-angular-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package.json"
powershell -Command "(Get-Content package.json) -replace '\"@%ORG_NAME%/single-spa-vue-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-vue-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package.json"
powershell -Command "(Get-Content package.json) -replace '\"@%ORG_NAME%/single-spa-react-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-react-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package.json"
powershell -Command "(Get-Content package.json) -replace '\"@%ORG_NAME%/single-spa-vanilla-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-vanilla-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package.json"
powershell -Command "(Get-Content package.json) -replace '\"@%ORG_NAME%/single-spa-webcomponents-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-webcomponents-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package.json"
powershell -Command "(Get-Content package.json) -replace '\"@%ORG_NAME%/single-spa-typescript-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-typescript-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package.json"
powershell -Command "(Get-Content package.json) -replace '\"@%ORG_NAME%/single-spa-jquery-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-jquery-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package.json"
powershell -Command "(Get-Content package.json) -replace '\"@%ORG_NAME%/single-spa-svelte-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-svelte-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package.json"

echo ✅ Dependencies and version updated

REM 4. Update all app package versions and mode-specific files (if called from publishing)
if "%FROM_RUN_SCRIPT%"=="true" (
    echo 🔄 Updating all app versions to match Nexus registry (%AVAILABLE_VERSION%)...
    cd ..
    
    REM Update all app package.json versions
    for %%a in (single-spa-auth-app single-spa-layout-app single-spa-home-app single-spa-angular-app single-spa-vue-app single-spa-react-app single-spa-vanilla-app single-spa-webcomponents-app single-spa-typescript-app single-spa-jquery-app single-spa-svelte-app) do (
        if exist "%%a" (
            powershell -Command "(Get-Content %%a/package.json) -replace '\"version\": \"[^\"]*\"', '\"version\": \"%AVAILABLE_VERSION%\"' | Set-Content %%a/package.json"
            echo 📝 Updated %%a version to %AVAILABLE_VERSION%
        )
    )
    
    REM Update package-nexus.json dependencies to match Nexus registry
    if exist "package-nexus.json" (
        echo 📝 Updating package-nexus.json dependencies to %AVAILABLE_VERSION%...
        powershell -Command "(Get-Content package-nexus.json) -replace '\"@%ORG_NAME%/single-spa-auth-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-auth-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-nexus.json"
        powershell -Command "(Get-Content package-nexus.json) -replace '\"@%ORG_NAME%/single-spa-layout-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-layout-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-nexus.json"
        powershell -Command "(Get-Content package-nexus.json) -replace '\"@%ORG_NAME%/single-spa-home-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-home-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-nexus.json"
        powershell -Command "(Get-Content package-nexus.json) -replace '\"@%ORG_NAME%/single-spa-angular-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-angular-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-nexus.json"
        powershell -Command "(Get-Content package-nexus.json) -replace '\"@%ORG_NAME%/single-spa-vue-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-vue-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-nexus.json"
        powershell -Command "(Get-Content package-nexus.json) -replace '\"@%ORG_NAME%/single-spa-react-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-react-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-nexus.json"
        powershell -Command "(Get-Content package-nexus.json) -replace '\"@%ORG_NAME%/single-spa-vanilla-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-vanilla-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-nexus.json"
        powershell -Command "(Get-Content package-nexus.json) -replace '\"@%ORG_NAME%/single-spa-webcomponents-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-webcomponents-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-nexus.json"
        powershell -Command "(Get-Content package-nexus.json) -replace '\"@%ORG_NAME%/single-spa-typescript-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-typescript-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-nexus.json"
        powershell -Command "(Get-Content package-nexus.json) -replace '\"@%ORG_NAME%/single-spa-jquery-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-jquery-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-nexus.json"
        powershell -Command "(Get-Content package-nexus.json) -replace '\"@%ORG_NAME%/single-spa-svelte-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-svelte-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-nexus.json"
        echo ✅ Updated package-nexus.json dependencies
    )
    
    echo ⏭️ Skipping dependency installation (called from publishing workflow)
    echo ✅ All versions synchronized to %AVAILABLE_VERSION%
) else (
    echo 📦 Installing dependencies...
    npm install
    
    if errorlevel 1 (
        echo ❌ Installation failed
        exit /b 1
    ) else (
        echo 🎉 Dependencies installed successfully!
    )
)