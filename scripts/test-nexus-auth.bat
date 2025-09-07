@echo off
setlocal enabledelayedexpansion

REM Test Nexus Authentication Script (Windows)
REM Usage: test-nexus-auth.bat

echo 🧪 Testing Nexus Authentication...
echo 🔍 Current directory: %CD%

REM Check if .npmrc.nexus exists
if not exist ".npmrc.nexus" (
    echo ❌ .npmrc.nexus not found. Please create it first.
    exit /b 1
)

echo ✅ .npmrc.nexus found

REM Switch to Nexus registry
echo 🔄 Switching to Nexus registry...
if exist ".npmrc" copy ".npmrc" ".npmrc.backup" >nul
copy ".npmrc.nexus" ".npmrc" >nul

for /f "tokens=*" %%i in ('npm config get registry') do echo 📝 Registry switched to: %%i

REM Test npm whoami
echo 🔍 Testing npm whoami...
npm whoami >nul 2>&1
if errorlevel 1 (
    echo ❌ Nexus authentication failed
    echo 💡 Check .npmrc.nexus configuration:
    echo    - registry=http://localhost:8081/repository/npm-group/
    echo    - //localhost:8081/repository/npm-group/:_auth=^<base64-user:pass^>
    echo    - //localhost:8081/repository/npm-group/:always-auth=true
    exit /b 1
) else (
    echo ✅ Nexus authentication successful!
)

REM Test dry run publish on auth app
echo 🧪 Testing dry run publish on single-spa-auth-app...
cd single-spa-auth-app

REM Check if built
if not exist "dist\single-spa-auth-app.umd.js" (
    echo 📦 Building auth app first...
    npm run build:prod
)

echo 🧪 Running npm publish --dry-run...
npm publish --dry-run >nul 2>&1

if errorlevel 1 (
    echo ❌ Dry run failed. Check Nexus configuration.
    cd ..
    exit /b 1
) else (
    echo ✅ Dry run successful! Nexus authentication is working.
)

cd ..

REM Restore original .npmrc
if exist ".npmrc.backup" (
    echo 🔄 Restoring original .npmrc...
    copy ".npmrc.backup" ".npmrc" >nul
    del ".npmrc.backup" >nul
)

echo 🎉 Nexus authentication test completed successfully!