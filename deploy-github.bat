@echo off
REM Deploy individual microfrontend to GitHub Pages
REM Usage: deploy-github.bat [app-name|root]

setlocal enabledelayedexpansion

set APP_NAME=%1

if "%APP_NAME%"=="" (
    echo ❌ Error: App name is required
    echo Usage: deploy-github.bat [app-name^|root]
    exit /b 1
)

REM Load environment variables from .env file
if exist ".env" (
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" (
            set "%%a=%%b"
        )
    )
)

if "%GITHUB_USERNAME%"=="" set GITHUB_USERNAME=cesarchamal

set GITHUB_TOKEN=%GITHUB_API_TOKEN%
if "%GITHUB_TOKEN%"=="" set GITHUB_TOKEN=%GITHUB_TOKEN%

if "%GITHUB_TOKEN%"=="" (
    echo ❌ Error: GITHUB_API_TOKEN or GITHUB_TOKEN not set
    echo 📝 Note: Use GH_API_TOKEN secret in GitHub Actions
    exit /b 1
)

REM Configure git user globally first
git config --global user.name "Cesar Francisco Chavez Maldonado - GitHub Actions"
git config --global user.email "cesarchamal@gmail.com"

echo 🚀 Deploying %APP_NAME% to GitHub Pages...

REM Handle root app deployment
if "%APP_NAME%"=="root" (
    set APP_DIR=single-spa-root
    set REPO_NAME=demo-microfrontends
) else (
    set APP_DIR=%APP_NAME%
    set REPO_NAME=%APP_NAME%
)

REM Check if app directory exists
if not exist "%APP_DIR%" (
    echo ❌ Error: Directory %APP_DIR% not found
    exit /b 1
)

cd "%APP_DIR%"

REM Configure git user
git config user.name "Cesar Francisco Chavez Maldonado - GitHub Actions"
git config user.email "cesarchamal@gmail.com"

REM Build the application
echo 🔨 Building %APP_NAME%...
if exist "package.json" (
    call npm install
    call npm run build
) else (
    echo ❌ Error: package.json not found in %APP_NAME%
    exit /b 1
)

REM Check if dist directory exists
if not exist "dist" (
    echo ❌ Error: dist directory not found after build
    exit /b 1
)

REM Create GitHub repository if it doesn't exist
echo 🔧 Creating GitHub repository if needed...
curl -s -X POST -H "Authorization: token %GITHUB_TOKEN%" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/user/repos" -d "{\"name\":\"%REPO_NAME%\",\"description\":\"%REPO_NAME%\",\"private\":false}" > repo_response.json 2>nul

findstr /C:"Resource not accessible" repo_response.json >nul
if !errorlevel! equ 0 (
    echo ⚠️  Warning: GitHub token lacks repository creation permissions
    echo 📝 Please create repository manually: https://github.com/new
    echo    Repository name: %REPO_NAME%
    echo    Make it public and continue...
    pause
) else (
    findstr /C:"already exists" repo_response.json >nul
    if !errorlevel! equ 0 (
        echo ✅ Repository %REPO_NAME% already exists
    ) else (
        echo ✅ Repository %REPO_NAME% created successfully
        echo ⏳ Waiting for repository to be ready...
        timeout /t 5 /nobreak >nul
    )
)
del repo_response.json 2>nul

REM Initialize git if not already initialized
if not exist ".git" (
    echo 📦 Initializing git repository...
    git init
    git branch -M main
)

REM Configure git with token authentication
git remote remove origin 2>nul || echo >nul
git remote add origin "https://x-access-token:%GITHUB_TOKEN%@github.com/%GITHUB_USERNAME%/%REPO_NAME%.git"

REM Verify repository exists before proceeding
echo 🔍 Verifying repository exists...
curl -s -H "Authorization: token %GITHUB_TOKEN%" "https://api.github.com/repos/%GITHUB_USERNAME%/%REPO_NAME%" > repo_check.json
findstr /C:"Not Found" repo_check.json >nul
if !errorlevel! equ 0 (
    echo ❌ Error: Repository %REPO_NAME% not found after creation
    echo 📝 Please create repository manually: https://github.com/new
    echo    Repository name: %REPO_NAME%
    del repo_check.json 2>nul
    exit /b 1
) else (
    echo ✅ Repository verified: %REPO_NAME%
)
del repo_check.json 2>nul

REM Copy dist contents to root for GitHub Pages
echo 📁 Preparing files for GitHub Pages...
xcopy /E /Y dist\* . >nul

REM Only commit if there are changes
git status --porcelain >temp_status.txt
for %%A in (temp_status.txt) do set size=%%~zA
if !size! gtr 0 (
    git add .
    git commit -m "Deploy to GitHub Pages"
    echo 📤 Pushing to GitHub...
    git push -u origin main --force
    if !errorlevel! neq 0 (
        echo ❌ Error: Failed to push to GitHub
        echo 📝 Make sure the repository exists: https://github.com/%GITHUB_USERNAME%/%REPO_NAME%
        echo 🔑 Check that your GitHub token has push permissions
        exit /b 1
    )
) else (
    echo 📝 No changes to deploy
)
del temp_status.txt

REM Enable GitHub Pages via API
echo 🌐 Enabling GitHub Pages...
curl -X POST -H "Authorization: token %GITHUB_TOKEN%" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/%GITHUB_USERNAME%/%REPO_NAME%/pages" -d "{\"source\":{\"branch\":\"main\",\"path\":\"/\"}}" 2>nul || echo GitHub Pages may already be enabled

cd ..

echo ✅ %APP_NAME% deployed to https://%GITHUB_USERNAME%.github.io/%REPO_NAME%/
echo ⏳ GitHub Pages may take a few minutes to become available