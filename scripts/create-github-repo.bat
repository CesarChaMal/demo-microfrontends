@echo off
REM GitHub Repository Creator for Windows
REM Usage: create-github-repo.bat [projects_path] <repo> [private=true|false]

setlocal enabledelayedexpansion

REM Load environment variables from .env file
if exist ".env" (
    echo Loading environment variables from .env...
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
    echo Usage: %0 [projects_path] ^<repo^> [private=true^|false]
    echo Examples:
    echo   %0 cleancodeExercise
    echo   %0 cleancodeExercise true
    echo   %0 C:\temp cleancodeExercise
    echo   %0 C:\temp cleancodeExercise true
    exit /b 1
)

REM Check if first argument is a path
if exist "%1" (
    set projects_path=%1
    set repo=%2
    set private=%3
) else (
    set projects_path=%PROJECTS_PATH%
    if "!projects_path!"=="" set projects_path=%DEFAULT_PROJECTS_PATH%
    set repo=%1
    set private=%2
)

if "%repo%"=="" (
    echo Error: Repository name is required
    exit /b 1
)

if "%private%"=="" set private=false

REM --- Environment variables ---
set username=%GITHUB_USERNAME%
if "%username%"=="" set username=%DEFAULT_USERNAME%
set token=%GITHUB_API_TOKEN%

if "%token%"=="" (
    echo Error: GITHUB_API_TOKEN not found in .env file
    echo Please add GITHUB_API_TOKEN=your_token_here to your .env file
    exit /b 1
)

REM --- Validate private flag ---
if not "%private%"=="true" if not "%private%"=="false" (
    echo Invalid 'private' value: %private%. Use 'true' or 'false'.
    exit /b 1
)

REM --- Derived variables ---
set project_directory=%projects_path%\%repo%
set url=git@github.com:%username%/%repo%.git

REM --- Check if GitHub repo already exists ---
echo Checking if GitHub repo %repo% already exists...
curl -sS -o nul -w "%%{http_code}" ^
  -H "Authorization: Bearer %token%" ^
  -H "Accept: application/vnd.github+json" ^
  "https://api.github.com/repos/%username%/%repo%" > temp_response.txt

set /p check_resp=<temp_response.txt
del temp_response.txt

if "%check_resp%"=="200" (
    echo Error: Repository '%repo%' already exists on GitHub.
    echo Repository URL: https://github.com/%username%/%repo%
    echo Please choose a different name or delete the existing repository.
    exit /b 1
) else if "%check_resp%"=="404" (
    echo Repository '%repo%' does not exist. Proceeding with creation...
) else (
    echo GitHub API returned HTTP %check_resp%. Proceeding anyway...
)

REM --- Echo context ---
echo.
echo Repo: %repo%
echo Private: %private%
echo Projects path: %projects_path%
echo Git SSH URL: %url%
echo GitHub API: %GITHUB_API%
echo.

REM --- Ensure directory ---
if not exist "%project_directory%" (
    mkdir "%project_directory%"
    echo Created directory %project_directory%
) else (
    echo Directory %project_directory% already exists.
)

cd /d "%project_directory%"

REM --- Init git repo ---
if not exist ".git" (
    git init
    echo Initialized git repo in %project_directory%\.git
) else (
    echo Existing git repository detected.
)

REM --- Ensure README exists ---
if not exist "README.md" (
    echo # %repo% > README.md
    git add README.md
    git commit -m "Initial commit with README" >nul 2>&1
    echo Created and committed README.md
) else (
    echo README.md already exists.
)

REM Display README content
if exist "README.md" type README.md

REM --- Create or update remote origin ---
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    git remote add origin %url%
    echo Added remote origin %url%
) else (
    git remote set-url origin %url%
    echo Updated remote origin to %url%
)

REM --- Create repo on GitHub ---
set create_payload={"name":"%repo%","description":"%repo%","private":%private%}

echo Ensuring GitHub repo exists (private=%private%)...
curl -sS -o temp_create_resp.json -w "%%{http_code}" ^
  -H "Authorization: Bearer %token%" ^
  -H "Accept: application/vnd.github+json" ^
  -d "%create_payload%" ^
  "%GITHUB_API%" > temp_create_status.txt

set /p create_resp=<temp_create_status.txt
del temp_create_status.txt
del temp_create_resp.json

if "%create_resp%"=="201" (
    echo GitHub repo created.
) else if "%create_resp%"=="422" (
    echo GitHub repo likely already exists. Continuing...
) else (
    echo GitHub API returned HTTP %create_resp%. Continuing...
)

REM --- Add/commit changes ---
git add -A
git diff --cached --quiet
if errorlevel 1 (
    git commit -m "Upload code for %repo% project."
    echo Committed pending changes.
) else (
    echo No changes to commit.
)

REM --- Push main ---
git branch -M main
git push -u origin main

echo Repository setup and push completed.