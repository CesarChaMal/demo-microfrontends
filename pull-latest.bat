@echo off

REM Use provided folder or current directory
set FOLDER=%1
if "%FOLDER%"=="" set FOLDER=.

echo Fetching and pulling latest changes...
echo Folder: %FOLDER%
echo.

cd /d "%FOLDER%"
git fetch --all

REM Check if main branch exists, otherwise use master
git show-ref --verify --quiet refs/heads/main >nul 2>&1
if %errorlevel%==0 (
    set BRANCH=main
) else (
    git show-ref --verify --quiet refs/heads/master >nul 2>&1
    if %errorlevel%==0 (
        set BRANCH=master
    ) else (
        echo Neither main nor master branch found!
        exit /b 1
    )
)

echo Switching to %BRANCH% branch...
git checkout %BRANCH%

echo Pulling latest changes from origin/%BRANCH%...
git pull origin %BRANCH%

echo.
echo Done!