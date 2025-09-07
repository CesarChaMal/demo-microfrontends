@echo off
setlocal enabledelayedexpansion

REM Local Development Status Checker
REM Usage: check-local-status.bat

echo 🔍 Checking local development status for microfrontends...
echo.

REM Define applications, ports, and bundle files
set "apps[0]=single-spa-root:8080:root-application.js"
set "apps[1]=single-spa-auth-app:4201:single-spa-auth-app.umd.js"
set "apps[2]=single-spa-layout-app:4202:single-spa-layout-app.umd.js"
set "apps[3]=single-spa-home-app:4203:single-spa-home-app.js"
set "apps[4]=single-spa-angular-app:4204:single-spa-angular-app.js"
set "apps[5]=single-spa-vue-app:4205:single-spa-vue-app.umd.js"
set "apps[6]=single-spa-react-app:4206:single-spa-react-app.js"
set "apps[7]=single-spa-vanilla-app:4207:single-spa-vanilla-app.js"
set "apps[8]=single-spa-webcomponents-app:4208:single-spa-webcomponents-app.js"
set "apps[9]=single-spa-typescript-app:4209:single-spa-typescript-app.js"
set "apps[10]=single-spa-jquery-app:4210:single-spa-jquery-app.js"
set "apps[11]=single-spa-svelte-app:4211:single-spa-svelte-app.js"

echo 🏠 Checking local development servers...

for /l %%i in (0,1,11) do (
    for /f "tokens=1,2,3 delims=:" %%a in ("!apps[%%i]!") do (
        set "app=%%a"
        set "port=%%b"
        set "bundle_file=%%c"
        
        echo 📦 Checking app: !app!
        echo    🎯 Port: !port!
        echo    📄 Bundle file: !bundle_file!
        
        REM Check if port is in use
        netstat -an | findstr ":!port! " | findstr "LISTENING" >nul 2>&1
        if !errorlevel! equ 0 (
            echo    ✅ Port !port! is listening
        ) else (
            echo    ❌ Port !port! is not listening
        )
        
        REM Test HTTP endpoint
        set "local_url=http://localhost:!port!"
        echo    🌐 Testing local server: !local_url!
        
        for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!local_url!" --connect-timeout 5 2^>nul ^|^| echo 000') do set "server_status=%%c"
        
        if "!server_status!"=="200" (
            echo    ✅ Local server accessible ^(HTTP !server_status!^)
        ) else if "!server_status!"=="000" (
            echo    ❌ Local server not reachable ^(connection failed^)
        ) else (
            echo    ⚠️  Local server unexpected status ^(HTTP !server_status!^)
        )
        
        REM Test bundle file endpoint
        set "bundle_url=http://localhost:!port!/!bundle_file!"
        echo    📄 Testing bundle file: !bundle_url!
        
        for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!bundle_url!" --connect-timeout 5 2^>nul ^|^| echo 000') do set "bundle_status=%%c"
        
        if "!bundle_status!"=="200" (
            echo    ✅ Bundle file accessible ^(HTTP !bundle_status!^)
        ) else if "!bundle_status!"=="404" (
            echo    ❌ Bundle file not found ^(HTTP !bundle_status!^)
        ) else if "!bundle_status!"=="000" (
            echo    ❌ Bundle file not reachable ^(connection failed^)
        ) else (
            echo    ⚠️  Bundle file unexpected status ^(HTTP !bundle_status!^)
        )
        
        echo.
    )
)

echo 📁 Checking built files in dist directories...

for /l %%i in (0,1,11) do (
    for /f "tokens=1,2,3 delims=:" %%a in ("!apps[%%i]!") do (
        set "app=%%a"
        set "port=%%b"
        set "bundle_file=%%c"
        
        echo 📦 Checking built files for: !app!
        
        REM Check if app directory exists
        if exist "!app!" (
            echo    ✅ Directory exists: !app!\
            
            REM Check for dist directory
            if exist "!app!\dist" (
                echo    ✅ Dist directory exists: !app!\dist\
                
                REM Check for bundle file
                if exist "!app!\dist\!bundle_file!" (
                    echo    ✅ Bundle file exists: !app!\dist\!bundle_file!
                    
                    REM Get file size
                    for %%f in ("!app!\dist\!bundle_file!") do set "file_size=%%~zf"
                    echo    📊 File size: !file_size! bytes
                ) else (
                    echo    ❌ Bundle file missing: !app!\dist\!bundle_file!
                )
                
                REM List other files in dist
                echo    📁 Other files in dist:
                if exist "!app!\dist\*" (
                    for %%f in ("!app!\dist\*") do echo       %%~nxf
                ) else (
                    echo       ^(none^)
                )
            ) else (
                echo    ❌ Dist directory missing: !app!\dist\
            )
        ) else (
            echo    ❌ Directory missing: !app!\
        )
        
        echo.
    )
)

REM Summary table
echo 📊 Summary of local development status:
echo.
echo Application               Port   Server          Bundle URL      Built File
echo -----------               ----   ------          ----------      ----------

for /l %%i in (0,1,11) do (
    for /f "tokens=1,2,3 delims=:" %%a in ("!apps[%%i]!") do (
        set "app=%%a"
        set "port=%%b"
        set "bundle_file=%%c"
        
        REM Test server
        set "local_url=http://localhost:!port!"
        for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!local_url!" --connect-timeout 5 2^>nul ^|^| echo 000') do set "server_status=%%c"
        
        if "!server_status!"=="200" (
            set "server_result=✅ !server_status!"
        ) else (
            set "server_result=❌ !server_status!"
        )
        
        REM Test bundle URL
        set "bundle_url=http://localhost:!port!/!bundle_file!"
        for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!bundle_url!" --connect-timeout 5 2^>nul ^|^| echo 000') do set "bundle_status=%%c"
        
        if "!bundle_status!"=="200" (
            set "bundle_result=✅ !bundle_status!"
        ) else (
            set "bundle_result=❌ !bundle_status!"
        )
        
        REM Check built file
        if exist "!app!\dist\!bundle_file!" (
            set "built_result=✅ Exists"
        ) else (
            set "built_result=❌ Missing"
        )
        
        REM Format output with padding
        set "app_padded=!app!                         "
        set "app_padded=!app_padded:~0,25!"
        set "port_padded=!port!      "
        set "port_padded=!port_padded:~0,6!"
        set "server_padded=!server_result!               "
        set "server_padded=!server_padded:~0,15!"
        set "bundle_padded=!bundle_result!               "
        set "bundle_padded=!bundle_padded:~0,15!"
        
        echo !app_padded! !port_padded! !server_padded! !bundle_padded! !built_result!
    )
)

echo.
echo 🔧 Recommendations:
echo 1. If servers are not running, start them with: run.bat local dev
echo 2. If bundle files are missing, build them with: npm run build:dev
echo 3. If ports are in use by other processes, stop them or change ports
echo 4. For production builds, use: npm run build:prod
echo 5. Check individual app logs if servers fail to start
echo 6. Ensure all dependencies are installed: npm run install:all

endlocal