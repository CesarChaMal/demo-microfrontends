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

REM 2. Check available versions in NPM (force NPM registry)
echo 🔍 Checking available versions in NPM...
for /f "tokens=*" %%i in ('npm view "@%ORG_NAME%/single-spa-auth-app" version --registry https://registry.npmjs.org/ 2^>nul') do set AVAILABLE_VERSION=%%i

if "%AVAILABLE_VERSION%"=="" (
    echo ❌ No packages found in NPM. Run: npm run publish:npm:prod
    exit /b 1
)

echo 📦 Latest available version: %AVAILABLE_VERSION%

REM 3. Update package.json dependencies and version
cd "%APP_DIR%"
echo 📝 Updating dependencies to version %AVAILABLE_VERSION%...

REM Update main package version to match NPM registry
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
    echo 🔄 Updating all app versions to match NPM registry (%AVAILABLE_VERSION%)...
    cd ..
    
    REM Update all app package.json versions
    for %%a in (single-spa-auth-app single-spa-layout-app single-spa-home-app single-spa-angular-app single-spa-vue-app single-spa-react-app single-spa-vanilla-app single-spa-webcomponents-app single-spa-typescript-app single-spa-jquery-app single-spa-svelte-app) do (
        if exist "%%a" (
            powershell -Command "(Get-Content %%a/package.json) -replace '\"version\": \"[^\"]*\"', '\"version\": \"%AVAILABLE_VERSION%\"' | Set-Content %%a/package.json"
            echo 📝 Updated %%a version to %AVAILABLE_VERSION%
        )
    )
    
    REM Update package-npm.json dependencies to match NPM registry
    if exist "package-npm.json" (
        echo 📝 Updating package-npm.json dependencies to %AVAILABLE_VERSION%...
        powershell -Command "(Get-Content package-npm.json) -replace '\"@%ORG_NAME%/single-spa-auth-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-auth-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-npm.json"
        powershell -Command "(Get-Content package-npm.json) -replace '\"@%ORG_NAME%/single-spa-layout-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-layout-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-npm.json"
        powershell -Command "(Get-Content package-npm.json) -replace '\"@%ORG_NAME%/single-spa-home-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-home-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-npm.json"
        powershell -Command "(Get-Content package-npm.json) -replace '\"@%ORG_NAME%/single-spa-angular-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-angular-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-npm.json"
        powershell -Command "(Get-Content package-npm.json) -replace '\"@%ORG_NAME%/single-spa-vue-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-vue-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-npm.json"
        powershell -Command "(Get-Content package-npm.json) -replace '\"@%ORG_NAME%/single-spa-react-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-react-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-npm.json"
        powershell -Command "(Get-Content package-npm.json) -replace '\"@%ORG_NAME%/single-spa-vanilla-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-vanilla-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-npm.json"
        powershell -Command "(Get-Content package-npm.json) -replace '\"@%ORG_NAME%/single-spa-webcomponents-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-webcomponents-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-npm.json"
        powershell -Command "(Get-Content package-npm.json) -replace '\"@%ORG_NAME%/single-spa-typescript-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-typescript-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-npm.json"
        powershell -Command "(Get-Content package-npm.json) -replace '\"@%ORG_NAME%/single-spa-jquery-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-jquery-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-npm.json"
        powershell -Command "(Get-Content package-npm.json) -replace '\"@%ORG_NAME%/single-spa-svelte-app\": \"[^\"]*\"', '\"@%ORG_NAME%/single-spa-svelte-app\": \"%AVAILABLE_VERSION%\"' | Set-Content package-npm.json"
        echo ✅ Updated package-npm.json dependencies
    )
    
    echo ⏭️ Skipping dependency installation (called from publishing workflow)
    echo ✅ All versions synchronized to %AVAILABLE_VERSION%
) else (
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
)