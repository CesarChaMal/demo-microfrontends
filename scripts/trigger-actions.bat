@echo off
REM Trigger GitHub Actions for all microfrontend apps
REM This script makes dummy commits to each app directory to trigger their workflows

echo 🚀 Triggering GitHub Actions for all microfrontend apps...

REM Check if we're in a git repository
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Not in a git repository
    exit /b 1
)

REM Check if there are uncommitted changes
git diff-index --quiet HEAD --
if errorlevel 1 (
    echo ⚠️  Warning: You have uncommitted changes. Please commit or stash them first.
    echo Uncommitted files:
    git status --porcelain
    exit /b 1
)

REM List of all microfrontend directories
set APPS=single-spa-root single-spa-auth-app single-spa-layout-app single-spa-home-app single-spa-angular-app single-spa-vue-app single-spa-react-app single-spa-vanilla-app single-spa-webcomponents-app single-spa-typescript-app single-spa-jquery-app single-spa-svelte-app

REM Trigger actions for all apps
for %%a in (%APPS%) do (
    if exist "%%a" (
        echo 📦 Triggering action for %%a...
        
        REM Create or update a trigger file in the app directory
        echo # Trigger file for GitHub Actions - %date% %time% > "%%a\.github-trigger"
        
        REM Add and commit the trigger file
        git add "%%a\.github-trigger"
        git commit -m "trigger: Deploy %%a" --quiet 2>nul || echo No changes to commit for %%a
    ) else (
        echo ⚠️  Warning: Directory %%a not found, skipping...
    )
)

echo.
echo 🎯 Pushing all trigger commits...
git push origin main

echo.
echo ✅ All GitHub Actions triggered successfully!
echo 🔗 Check the Actions tab in your GitHub repository to see the workflows running.
echo.
echo Apps triggered:
for %%a in (%APPS%) do (
    if exist "%%a" (
        echo   - %%a
    )
)

pause