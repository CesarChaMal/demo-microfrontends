@echo off
setlocal enabledelayedexpansion

REM Auto-Fix Mode Dependencies Script (Windows)
REM Usage: auto-fix-mode.bat [mode]

set MODE=%1
if "%MODE%"=="" set MODE=auto
set ORG_NAME=%ORG_NAME%
if "%ORG_NAME%"=="" set ORG_NAME=cesarchamal

echo 🔧 Auto-fixing dependencies for mode: %MODE%

REM Auto-detect mode if not specified
if "%MODE%"=="auto" (
    REM Check current registry
    for /f "tokens=*" %%i in ('npm config get registry') do set CURRENT_REGISTRY=%%i
    
    echo !CURRENT_REGISTRY! | findstr "localhost:8081" >nul
    if !errorlevel! equ 0 (
        set MODE=nexus
        echo 🔍 Auto-detected mode: nexus (from registry)
    ) else (
        echo !CURRENT_REGISTRY! | findstr "npmjs.org" >nul
        if !errorlevel! equ 0 (
            set MODE=npm
            echo 🔍 Auto-detected mode: npm (from registry)
        ) else (
            REM Check root .npmrc
            if exist "single-spa-root\.npmrc" (
                findstr "localhost:8081" "single-spa-root\.npmrc" >nul
                if !errorlevel! equ 0 (
                    set MODE=nexus
                    echo 🔍 Auto-detected mode: nexus (from root .npmrc)
                ) else (
                    set MODE=npm
                    echo 🔍 Auto-detected mode: npm (from root .npmrc)
                )
            ) else (
                set MODE=npm
                echo 🔍 Defaulting to mode: npm
            )
        )
    )
)

echo 🎯 Target mode: %MODE%
echo.

echo 🔍 Step 1: Checking if packages exist in %MODE% registry...

REM Check if packages exist
if "%MODE%"=="nexus" (
    if exist ".npmrc.nexus" (
        copy ".npmrc.nexus" ".npmrc.temp" >nul
        for /f "tokens=*" %%i in ('npm view "@%ORG_NAME%/single-spa-auth-app" version 2^>nul') do set AVAILABLE_VERSION=%%i
        del ".npmrc.temp" >nul 2>&1
    ) else (
        echo ❌ .npmrc.nexus not found
        exit /b 1
    )
) else (
    for /f "tokens=*" %%i in ('npm view "@%ORG_NAME%/single-spa-auth-app" version 2^>nul') do set AVAILABLE_VERSION=%%i
)

if not "%AVAILABLE_VERSION%"=="" (
    echo 📦 Found packages in %MODE% registry: %AVAILABLE_VERSION%
    echo ✅ Packages found, proceeding with dependency fix...
    goto :fix_deps
) else (
    echo ❌ No packages found in %MODE% registry
    echo.
    echo 🔍 Step 2: Checking current local version...
    for /f "tokens=*" %%i in ('node -e "console.log(require('./package.json').version)" 2^>nul') do set CURRENT_VERSION=%%i
    echo 📋 Current local version: %CURRENT_VERSION%
    echo.
    echo 📤 Step 3: Publishing current version to %MODE% registry...
    
    if "%MODE%"=="nexus" (
        call npm run publish:nexus:nobump
    ) else (
        call npm run publish:npm:nobump
    )
    
    if errorlevel 1 (
        echo ❌ Auto-fix failed. Manual intervention required.
        echo.
        echo 💡 Manual steps:
        echo 1. Check registry authentication: npm run test:%MODE%:auth
        echo 2. Manually publish: npm run publish:%MODE%:nobump
        echo 3. Fix dependencies: npm run fix:%MODE%:deps:root
        exit /b 1
    )
    
    echo ✅ Successfully published to %MODE%
    echo.
    echo 🔧 Step 4: Fixing dependencies...
)

:fix_deps
if "%MODE%"=="nexus" (
    call scripts\fix-nexus-deps.bat single-spa-root
) else (
    call scripts\fix-npm-deps.bat single-spa-root
)

if errorlevel 1 (
    echo ❌ Failed to fix dependencies for %MODE% mode
    exit /b 1
)

echo ✅ Dependencies fixed for %MODE% mode
echo.
echo 🎉 Auto-fix completed for %MODE% mode!
echo.
echo 📝 Next steps:
echo 1. Run your desired mode: run.bat %MODE% dev
echo 2. Or check status: npm run check:%MODE%