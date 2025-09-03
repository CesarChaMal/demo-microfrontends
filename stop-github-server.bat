@echo off
REM Stop GitHub repository creation server

echo 🛑 Stopping GitHub repository creation server...

REM Find and kill Node.js processes on port 3001
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :3001') do (
    echo 🔍 Found process on port 3001: %%a
    taskkill /f /pid %%a >nul 2>&1
    if not errorlevel 1 (
        echo ✅ Process on port 3001 stopped
    )
)

REM Also kill any github-repo-server.js processes
for /f "tokens=2" %%a in ('tasklist /fi "imagename eq node.exe" /fo table /nh ^| findstr github-repo-server') do (
    echo 🔍 Found GitHub server process: %%a
    taskkill /f /pid %%a >nul 2>&1
    if not errorlevel 1 (
        echo ✅ GitHub server stopped
    )
)

echo 🏁 GitHub server cleanup complete