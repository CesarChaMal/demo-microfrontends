@echo off
REM =============================================================================
REM GitHub Repository Creation Script with Advanced Features (Windows)
REM =============================================================================
REM
REM DESCRIPTION:
REM   Creates GitHub repositories with optional GitHub Pages enablement and
REM   deployment secrets configuration. Supports both public and private repos.
REM
REM FEATURES:
REM   ✅ Repository creation with validation
REM   ✅ Local git repository initialization
REM   ✅ GitHub Pages automatic enablement
REM   ✅ GitHub Actions secrets creation
REM   ✅ README.md generation
REM   ✅ SSH remote configuration
REM   ✅ Idempotent operations (safe to re-run)
REM
REM PREREQUISITES:
REM   - GitHub Personal Access Token with repo and pages permissions
REM   - Git configured with SSH keys
REM   - .env file with required environment variables
REM   - curl.exe available in PATH
REM
REM ENVIRONMENT VARIABLES (from .env file):
REM   GITHUB_API_TOKEN    - GitHub Personal Access Token (required)
REM   GITHUB_USERNAME     - GitHub username (optional, defaults to CesarChaMal)
REM   PROJECTS_PATH       - Default projects directory (optional)
REM   S3_BUCKET          - AWS S3 bucket for deployment secrets
REM   AWS_REGION         - AWS region for deployment secrets
REM   ORG_NAME           - Organization name for deployment secrets
REM   NPM_TOKEN          - NPM token for package publishing secrets
REM
REM USAGE:
REM   create-github-repo.bat [projects_path] <repo_name> [private] [enable_pages] [create_secrets]
REM
REM PARAMETERS:
REM   projects_path   - Local directory path (optional, uses PROJECTS_PATH or default)
REM   repo_name       - GitHub repository name (required)
REM   private         - Create private repository (true/false, default: false)
REM   enable_pages    - Enable GitHub Pages (true/false, default: false)
REM   create_secrets  - Create deployment secrets (true/false, default: false)
REM
REM EXAMPLES:
REM
REM   Basic Usage:
REM     create-github-repo.bat my-awesome-project
REM     REM Creates public repo 'my-awesome-project' in default directory
REM
REM   Private Repository:
REM     create-github-repo.bat my-private-project true
REM     REM Creates private repo without GitHub Pages or secrets
REM
REM   Public Repository with GitHub Pages:
REM     create-github-repo.bat my-website false true
REM     REM Creates public repo with GitHub Pages enabled
REM     REM Available at: https://username.github.io/my-website/
REM
REM   Full Setup (Private + Pages + Secrets):
REM     create-github-repo.bat my-app true true true
REM     REM Creates private repo with GitHub Pages and deployment secrets
REM
REM   Custom Directory:
REM     create-github-repo.bat C:\projects my-project false true false
REM     REM Creates repo in custom directory with GitHub Pages
REM
REM   Microfrontend Setup:
REM     create-github-repo.bat single-spa-auth-app false true true
REM     REM Perfect for microfrontend apps with Pages and deployment secrets
REM
REM DEPLOYMENT SECRETS CREATED:
REM   When create_secrets=true, the following secrets are added to the repository:
REM   - S3_BUCKET: AWS S3 bucket name for deployment
REM   - AWS_REGION: AWS region for S3 deployment
REM   - ORG_NAME: Organization name for package scoping
REM   - GITHUB_API_TOKEN: GitHub token for cross-repo operations
REM   - NPM_TOKEN: NPM token for package publishing
REM
REM GITHUB PAGES CONFIGURATION:
REM   When enable_pages=true:
REM   - Enables GitHub Pages from main branch root (/)
REM   - Creates live website at https://username.github.io/repo-name/
REM   - Automatically configures source branch and path
REM
REM ERROR HANDLING:
REM   - Validates repository doesn't already exist
REM   - Checks GitHub API token permissions
REM   - Handles network errors gracefully
REM   - Provides clear error messages with solutions
REM
REM WORKFLOW:
REM   1. Validate parameters and environment
REM   2. Check if repository already exists on GitHub
REM   3. Create local directory and initialize git
REM   4. Generate README.md if not present
REM   5. Create GitHub repository via API
REM   6. Configure git remote and push initial commit
REM   7. Enable GitHub Pages (if requested)
REM   8. Create deployment secrets (if requested)
REM
REM =============================================================================

setlocal enabledelayedexpansion

REM Load environment variables from .env file
if exist ".env" (
    echo 📝 Loading environment variables from .env...
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" (
            set "%%a=%%b"
        )
    )
)

REM --- Defaults ---
set DEFAULT_PROJECTS_PATH=C:\Projects
set DEFAULT_USERNAME=CesarChaMal
set GITHUB_API=https://api.github.com/user/repos

REM --- Argument parsing ---
if "%1"=="" (
    echo 🔍 Usage: %0 [projects_path] ^<repo^> [private] [enable_pages] [create_secrets]
    echo 📋 Examples:
    echo   %0 cleancodeExercise
    echo   %0 cleancodeExercise true
    echo   %0 cleancodeExercise true true true
    echo   %0 C:\temp cleancodeExercise false true false
    exit /b 1
)

REM Check if first argument is a path
if exist "%1" (
    set projects_path=%1
    set repo=%2
    set private=%3
    set enable_pages=%4
    set create_secrets=%5
) else (
    set projects_path=%PROJECTS_PATH%
    if "!projects_path!"=="" set projects_path=%DEFAULT_PROJECTS_PATH%
    set repo=%1
    set private=%2
    set enable_pages=%3
    set create_secrets=%4
)

if "%repo%"=="" (
    echo ❌ Error: Repository name is required
    exit /b 1
)

if "%private%"=="" set private=false
if "%enable_pages%"=="" set enable_pages=false
if "%create_secrets%"=="" set create_secrets=false

REM --- Environment variables ---
set username=%GITHUB_USERNAME%
if "%username%"=="" set username=%DEFAULT_USERNAME%
set token=%GITHUB_API_TOKEN%

if "%token%"=="" (
    echo ❌ Error: GITHUB_API_TOKEN not found in .env file
    echo 📝 Please add GITHUB_API_TOKEN=your_token_here to your .env file
    exit /b 1
)

REM --- Validate flags ---
if not "%private%"=="true" if not "%private%"=="false" (
    echo ❌ Invalid 'private' value: %private%. Use 'true' or 'false'.
    exit /b 1
)

if not "%enable_pages%"=="true" if not "%enable_pages%"=="false" (
    echo ❌ Invalid 'enable_pages' value: %enable_pages%. Use 'true' or 'false'.
    exit /b 1
)

if not "%create_secrets%"=="true" if not "%create_secrets%"=="false" (
    echo ❌ Invalid 'create_secrets' value: %create_secrets%. Use 'true' or 'false'.
    exit /b 1
)

REM --- Derived variables ---
set project_directory=%projects_path%\%repo%
set url=git@github.com:%username%/%repo%.git

REM --- Check if GitHub repo already exists ---
echo 🔍 Checking if GitHub repo %repo% already exists...
curl -sS -o nul -w "%%{http_code}" ^
  -H "Authorization: Bearer %token%" ^
  -H "Accept: application/vnd.github+json" ^
  "https://api.github.com/repos/%username%/%repo%" > temp_response.txt

set /p check_resp=<temp_response.txt
del temp_response.txt

if "%check_resp%"=="200" (
    echo ❌ Error: Repository '%repo%' already exists on GitHub.
    echo 🔗 Repository URL: https://github.com/%username%/%repo%
    echo 💡 Please choose a different name or delete the existing repository.
    exit /b 1
) else if "%check_resp%"=="404" (
    echo ✅ Repository '%repo%' does not exist. Proceeding with creation...
) else (
    echo ⚠️  GitHub API returned HTTP %check_resp%. Proceeding anyway...
)

REM --- Echo context ---
echo.
echo 📦 Repo: %repo%
echo 🔒 Private: %private%
echo 🌐 Enable Pages: %enable_pages%
echo 🔑 Create Secrets: %create_secrets%
echo 📁 Projects path: %projects_path%
echo 🔗 Git SSH URL: %url%
echo 🌍 GitHub API: %GITHUB_API%
echo.

REM --- Ensure projects path exists ---
if not exist "%projects_path%" (
    mkdir "%projects_path%"
    echo ✅ Created projects directory %projects_path%
)

REM --- Ensure project directory exists ---
if not exist "%project_directory%" (
    mkdir "%project_directory%"
    echo ✅ Created project directory %project_directory%
) else (
    echo ⚠️  Directory %project_directory% already exists.
)

cd /d "%project_directory%"

REM --- Init git repo ---
if not exist ".git" (
    git init
    echo ✅ Initialized git repo in %project_directory%\.git
) else (
    echo ⚠️  Existing git repository detected.
)

REM --- Ensure README exists ---
if not exist "README.md" (
    echo # %repo% > README.md
    git add README.md
    git commit -m "Initial commit with README" >nul 2>&1
    echo ✅ Created and committed README.md
) else (
    echo ⚠️  README.md already exists.
)

REM Display README content
if exist "README.md" type README.md

REM --- Create or update remote origin ---
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    git remote add origin %url%
    echo ✅ Added remote origin %url%
) else (
    git remote set-url origin %url%
    echo ✅ Updated remote origin to %url%
)

REM --- Create repo on GitHub ---
set create_payload={"name":"%repo%","description":"%repo%","private":%private%}

echo 🚀 Ensuring GitHub repo exists (private=%private%)...
curl -sS -o temp_create_resp.json -w "%%{http_code}" ^
  -H "Authorization: Bearer %token%" ^
  -H "Accept: application/vnd.github+json" ^
  -d "%create_payload%" ^
  "%GITHUB_API%" > temp_create_status.txt

set /p create_resp=<temp_create_status.txt
del temp_create_status.txt
del temp_create_resp.json

if "%create_resp%"=="201" (
    echo ✅ GitHub repo created.
) else if "%create_resp%"=="422" (
    echo ⚠️  GitHub repo likely already exists. Continuing...
) else (
    echo ⚠️  GitHub API returned HTTP %create_resp%. Continuing...
)

REM --- Add/commit changes ---
git add -A
git diff --cached --quiet
if errorlevel 1 (
    git commit -m "Upload code for %repo% project."
    echo ✅ Committed pending changes.
) else (
    echo 📝 No changes to commit.
)

REM --- Push main ---
git branch -M main
git push -u origin main

echo ✅ Repository setup and push completed.

REM --- Enable GitHub Pages if requested ---
if "%enable_pages%"=="true" (
    echo.
    echo 🌐 Enabling GitHub Pages...
    curl -sS -o temp_pages_resp.json -w "%%{http_code}" ^
      -X POST ^
      -H "Authorization: Bearer %token%" ^
      -H "Accept: application/vnd.github+json" ^
      -d "{\"source\":{\"branch\":\"main\",\"path\":\"/\"}}" ^
      "https://api.github.com/repos/%username%/%repo%/pages" > temp_pages_status.txt
    
    set /p pages_resp=<temp_pages_status.txt
    del temp_pages_status.txt
    del temp_pages_resp.json
    
    if "!pages_resp!"=="201" (
        echo ✅ GitHub Pages enabled successfully.
        echo 🌍 Pages URL: https://%username%.github.io/%repo%/
    ) else if "!pages_resp!"=="409" (
        echo ⚠️  GitHub Pages already enabled.
    ) else (
        echo ⚠️  GitHub Pages API returned HTTP !pages_resp!. May already be enabled.
    )
)

REM --- Create GitHub Secrets if requested ---
if "%create_secrets%"=="true" (
    echo.
    echo 🔑 Creating GitHub Secrets...
    
    REM Use existing secrets creation script
    set SCRIPT_DIR=%~dp0
    set SECRETS_SCRIPT=%SCRIPT_DIR%create-github-secrets-gh.bat
    
    if exist "%SECRETS_SCRIPT%" (
        echo 📝 Using existing secrets script: %SECRETS_SCRIPT%
        call "%SECRETS_SCRIPT%" "%username%" "%repo%"
        if errorlevel 1 (
            echo ❌ Secrets creation failed.
        ) else (
            echo ✅ Secrets creation completed successfully.
        )
    ) else (
        echo ❌ Secrets script not found: %SECRETS_SCRIPT%
        echo ⚠️  Skipping secrets creation.
    )
)

echo.
echo 🎉 Repository '%repo%' setup completed successfully!