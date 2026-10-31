@echo off
setlocal enabledelayedexpansion

REM GitHub Hot Sync Script for Windows
REM Usage: github-hot-sync.bat

echo 🔥 Starting GitHub Hot Sync for microfrontends...

REM Load environment variables from .env file
if exist ".env" (
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" (
            set "%%a=%%b"
        )
    )
)

if "%GITHUB_USERNAME%"=="" (
    echo ❌ Error: GITHUB_USERNAME not set
    exit /b 1
)

if "%GITHUB_API_TOKEN%"=="" (
    echo ❌ Error: GITHUB_API_TOKEN not set
    exit /b 1
)

echo 👤 GitHub User: %GITHUB_USERNAME%
echo 🔑 Token: %GITHUB_API_TOKEN:~0,8%...
echo.

REM List of applications and their repositories
set "APPS=single-spa-root single-spa-auth-app single-spa-layout-app single-spa-home-app single-spa-angular-app single-spa-vue-app single-spa-react-app single-spa-vanilla-app single-spa-webcomponents-app single-spa-typescript-app single-spa-jquery-app single-spa-svelte-app single-spa-solid-app"

REM Function to deploy a single app
:deploy_app
set "app=%~1"
set "repo=%~1"

if exist "%app%\dist" (
    echo 🔄 Deploying %app% to %GITHUB_USERNAME%/%repo%
    
    REM Use the existing deploy script
    call scripts\deploy-github.bat "%app%"
    if !errorlevel! equ 0 (
        echo ✅ Deployed %app%
    ) else (
        echo ❌ Failed to deploy %app%
    )
) else (
    echo ⚠️  No dist directory found for %app%
)
goto :eof

REM Initial deployment of all apps
echo 🚀 Performing initial deployment of all apps...
for %%a in (%APPS%) do (
    call :deploy_app "%%a"
)

echo.
echo 🎉 Initial deployment complete!
echo.

REM Windows polling method (no fswatch available)
echo 👀 Watching for file changes using polling method...
echo Press Ctrl+C to stop
echo.

:watch_loop
timeout /t 10 /nobreak >nul

REM Check if any dist directory has been modified recently
set "CHANGED=false"
for %%a in (%APPS%) do (
    if exist "%%a\dist" (
        REM Check for files modified in the last 15 seconds (approximate)
        for /f %%f in ('dir "%%a\dist" /s /b /od 2^>nul ^| tail -1 2^>nul') do (
            REM Simple time check - deploy if any files exist
            set "CHANGED=true"
            call :deploy_app "%%a"
        )
    )
)

if "%CHANGED%"=="true" (
    echo 🎉 Deployment complete at %date% %time%
    echo.
)

goto watch_loop