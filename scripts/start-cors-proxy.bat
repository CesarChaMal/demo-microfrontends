@echo off
REM Load environment variables from .env file
for /f "usebackq tokens=1,2 delims==" %%i in ("..\.env") do (
    if not "%%i"=="" if not "%%i:~0,1"=="#" set %%i=%%j
)

REM Use environment variables with defaults
if "%NEXUS_CORS_PROXY_PORT%"=="" set NEXUS_CORS_PROXY_PORT=8082
if "%NEXUS_URL%"=="" set NEXUS_URL=http://localhost:8081
if "%NEXUS_CORS_PROXY_ENABLED%"=="" set NEXUS_CORS_PROXY_ENABLED=true

echo 🔧 Starting Node.js CORS proxy for Nexus...
echo 📋 Configuration:
echo    - Proxy port: %NEXUS_CORS_PROXY_PORT%
echo    - Nexus URL: %NEXUS_URL%
echo    - Enabled: %NEXUS_CORS_PROXY_ENABLED%

REM Check if CORS proxy is enabled
if not "%NEXUS_CORS_PROXY_ENABLED%"=="true" (
    echo ⚠️ CORS proxy is disabled in configuration
    exit /b 0
)

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js not found. Please install Node.js from https://nodejs.org
    exit /b 1
)

REM Check if dependencies are installed
if not exist "..\node_modules" (
    echo 📦 Installing dependencies...
    cd ..
    call npm install express http-proxy-middleware dotenv
    cd scripts
)

REM Test Nexus connectivity
echo 🔍 Testing Nexus connectivity...
curl -s "%NEXUS_URL%" >nul 2>&1
if errorlevel 1 (
    echo ❌ Nexus not accessible on %NEXUS_URL%. Please start Nexus first.
    exit /b 1
)

REM Check if port is available
netstat -an | findstr ":%NEXUS_CORS_PROXY_PORT% " >nul 2>&1
if not errorlevel 1 (
    echo ❌ Port %NEXUS_CORS_PROXY_PORT% is already in use. Please stop the service using this port.
    exit /b 1
)

echo 🚀 Starting CORS proxy on port %NEXUS_CORS_PROXY_PORT%...
node cors-proxy.js