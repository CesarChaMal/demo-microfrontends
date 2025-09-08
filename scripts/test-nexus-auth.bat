@echo off
setlocal enabledelayedexpansion

REM Test Nexus Authentication Script (Windows)
REM Usage: test-nexus-auth.bat

echo 🧪 Testing Nexus Authentication...
echo 🔍 Current directory: %CD%

REM Load environment variables from .env file
echo 🔍 DEBUG: Looking for .env file in current directory: %CD%
if exist ".env" (
    echo 📄 Loading environment variables from .env...
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%a:~0,1"=="#" set %%a=%%b
    )
    echo 🔍 DEBUG: Environment variables loaded from .env
) else if exist "../.env" (
    echo 📄 Loading environment variables from ../.env...
    for /f "usebackq tokens=1,2 delims==" %%a in ("../.env") do (
        if not "%%a"=="" if not "%%a:~0,1"=="#" set %%a=%%b
    )
    echo 🔍 DEBUG: Environment variables loaded from ../.env
) else (
    echo ⚠️ Warning: No .env file found, using environment variables only
)

REM Set Nexus configuration with fallback to environment variables
if "%NEXUS_USER%"=="" set NEXUS_USER=admin
if "%NEXUS_URL%"=="" set NEXUS_URL=http://localhost:8081
if "%NEXUS_REGISTRY%"=="" set NEXUS_REGISTRY=http://localhost:8081/repository/npm-group/
if "%NEXUS_PUBLISH_REGISTRY%"=="" set NEXUS_PUBLISH_REGISTRY=http://localhost:8081/repository/npm-hosted-releases/

echo 🔍 DEBUG: Nexus configuration - USER=%NEXUS_USER%, URL=%NEXUS_URL%
echo 🔍 DEBUG: Registry: %NEXUS_REGISTRY%
echo 🔍 DEBUG: Publish Registry: %NEXUS_PUBLISH_REGISTRY%

if "%NEXUS_PASS%"=="" (
    echo ❌ Error: NEXUS_PASS not set in .env file or environment variables
    echo 💡 Please set NEXUS_PASS in .env file or set NEXUS_PASS=your-password
    exit /b 1
)

REM Check if .npmrc.nexus exists or create from environment variables
if exist ".npmrc.nexus" (
    echo ✅ .npmrc.nexus found
    REM Switch to Nexus registry
    echo 🔄 Switching to Nexus registry...
    if exist ".npmrc" copy ".npmrc" ".npmrc.backup" >nul
    copy ".npmrc.nexus" ".npmrc" >nul
) else (
    echo 📋 .npmrc.nexus not found, generating from environment variables...
    REM Backup existing .npmrc
    if exist ".npmrc" copy ".npmrc" ".npmrc.backup" >nul
    REM Generate .npmrc from environment variables
    powershell -Command "[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('%NEXUS_USER%:%NEXUS_PASS%'))" > temp_auth.txt
    set /p AUTH_TOKEN=<temp_auth.txt
    del temp_auth.txt
    (
        echo registry=%NEXUS_REGISTRY%
        echo //localhost:8081/repository/npm-group/:_auth=!AUTH_TOKEN!
        echo //localhost:8081/repository/npm-hosted-releases/:_auth=!AUTH_TOKEN!
        echo //localhost:8081/repository/npm-group/:always-auth=true
        echo //localhost:8081/repository/npm-hosted-releases/:always-auth=true
    ) > .npmrc
    echo ✅ Generated .npmrc from NEXUS_USER and NEXUS_PASS
)

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