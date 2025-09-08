@echo off
REM Load environment variables from .env file
for /f "usebackq tokens=1,2 delims==" %%i in (".env") do (
    if not "%%i"=="" if not "%%i:~0,1"=="#" set %%i=%%j
)

REM Set default CORS proxy port if not set
if "%NEXUS_CORS_PROXY_PORT%"=="" set NEXUS_CORS_PROXY_PORT=8082

echo Stopping Demo Microfrontends Applications...
echo Using CORS proxy port: %NEXUS_CORS_PROXY_PORT%

echo Killing processes on ports 8080, 4201-4211, %NEXUS_CORS_PROXY_PORT%...

for %%p in (8080 4201 4202 4203 4204 4205 4206 4207 4208 4209 4210 4211 %NEXUS_CORS_PROXY_PORT%) do (
    for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%%p') do (
        if not "%%a"=="" (
            echo Killing process %%a on port %%p
            taskkill /f /pid %%a >nul 2>&1
        )
    )
)

REM Stop CORS proxy specifically
echo Stopping CORS proxy...
taskkill /f /im node.exe /fi "WINDOWTITLE eq cors-proxy*" >nul 2>&1
taskkill /f /im node.exe /fi "COMMANDLINE eq *cors-proxy*" >nul 2>&1

REM Clean up CORS proxy files
if exist "cors-proxy.pid" del cors-proxy.pid >nul 2>&1
if exist "scripts\cors-proxy.pid" del scripts\cors-proxy.pid >nul 2>&1

echo All microfrontend applications and CORS proxy stopped
pause