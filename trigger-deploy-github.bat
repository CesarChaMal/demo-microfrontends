@echo off
REM Trigger both GitHub deployment workflows
REM Usage: trigger-deploy-github.bat [commit-message]

setlocal enabledelayedexpansion

set "COMMIT_MSG=%~1"
if "%COMMIT_MSG%"=="" set "COMMIT_MSG=Deploy all microfrontends to GitHub Pages"

echo 🚀 Triggering GitHub Pages deployments...

REM Check if GitHub CLI is installed
gh --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: GitHub CLI (gh) is not installed
    echo Install it from: https://cli.github.com/
    exit /b 1
)

REM Check if user is authenticated
gh auth status >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Not authenticated with GitHub CLI
    echo Run: gh auth login
    exit /b 1
)

echo 📝 Commit message: %COMMIT_MSG%

REM Add all changes
echo 📦 Adding changes...
git add .

REM Commit changes
echo 💾 Committing changes...
git commit -m "%COMMIT_MSG%" || echo No changes to commit

REM Push to main (triggers automatic workflow)
echo 📤 Pushing to main branch (triggers automatic deployment)...
git push origin main

REM Wait a moment for the push to register
timeout /t 2 /nobreak >nul

REM Trigger manual workflow
echo 🔧 Triggering manual deployment workflow...
gh workflow run "Deploy to GitHub Pages (Manual)"

echo.
echo ✅ Both GitHub deployments triggered!
echo 📊 Check progress in GitHub Actions tab
echo.
echo 🌐 Automatic deployment: Simple workflow (uses deploy-github.sh)
echo 🔧 Manual deployment: Complex workflow (matrix + import map)
echo.
echo 🌍 After deployment, your apps will be live at GitHub Pages