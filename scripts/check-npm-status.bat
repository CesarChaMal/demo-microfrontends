@echo off
setlocal enabledelayedexpansion

REM NPM Registry Status Checker
REM Usage: check-npm-status.bat

echo 🔍 Checking NPM registry status for microfrontends...

REM Load environment variables from .env file
if exist ".env" (
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" (
            set "%%a=%%b"
        )
    )
)

REM Set defaults
if "%ORG_NAME%"=="" set "ORG_NAME=cesarchamal"

echo 🏢 Organization: @%ORG_NAME%
echo.

REM Check current NPM registry
for /f "tokens=*" %%r in ('npm config get registry 2^>nul') do set "CURRENT_REGISTRY=%%r"
echo 📦 Current NPM registry: %CURRENT_REGISTRY%
echo.

REM Define packages and expected files
set "packages[0]=@%ORG_NAME%/single-spa-auth-app:single-spa-auth-app.umd.js"
set "packages[1]=@%ORG_NAME%/single-spa-layout-app:single-spa-layout-app.umd.js"
set "packages[2]=@%ORG_NAME%/single-spa-home-app:single-spa-home-app.js"
set "packages[3]=@%ORG_NAME%/single-spa-angular-app:single-spa-angular-app.js"
set "packages[4]=@%ORG_NAME%/single-spa-vue-app:single-spa-vue-app.umd.js"
set "packages[5]=@%ORG_NAME%/single-spa-react-app:single-spa-react-app.js"
set "packages[6]=@%ORG_NAME%/single-spa-vanilla-app:single-spa-vanilla-app.js"
set "packages[7]=@%ORG_NAME%/single-spa-webcomponents-app:single-spa-webcomponents-app.js"
set "packages[8]=@%ORG_NAME%/single-spa-typescript-app:single-spa-typescript-app.js"
set "packages[9]=@%ORG_NAME%/single-spa-jquery-app:single-spa-jquery-app.js"
set "packages[10]=@%ORG_NAME%/single-spa-svelte-app:single-spa-svelte-app.js"
set "packages[11]=@%ORG_NAME%/single-spa-solid-app:single-spa-solid-app.js"
set "packages[12]=@%ORG_NAME%/single-spa-root:root-application.js"

echo 📋 Checking package availability...

for /l %%i in (0,1,12) do (
    for /f "tokens=1,2 delims=:" %%a in ("!packages[%%i]!") do (
        set "package=%%a"
        set "expected_file=%%b"
        
        echo 📦 Checking package: !package!
        echo    🎯 Expected file: !expected_file!
        
        REM Check if package exists in registry
        npm view "!package!" version >temp_npm_info.txt 2>nul
        
        if exist temp_npm_info.txt (
            for /f "tokens=*" %%v in (temp_npm_info.txt) do set "version=%%v"
            if not "!version!"=="" (
                echo    ✅ Package exists - Version: !version!
                
                REM Test unpkg CDN URL
                set "unpkg_url=https://unpkg.com/!package!@latest/dist/!expected_file!"
                echo    🌐 Testing unpkg CDN: !unpkg_url!
                
                for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!unpkg_url!" 2^>nul') do set "unpkg_status=%%c"
                
                if "!unpkg_status!"=="200" (
                    echo    ✅ unpkg CDN file accessible ^(HTTP !unpkg_status!^)
                ) else if "!unpkg_status!"=="404" (
                    echo    ❌ unpkg CDN file not found ^(HTTP !unpkg_status!^)
                ) else (
                    echo    ⚠️  unpkg CDN unexpected status ^(HTTP !unpkg_status!^)
                )
                
                REM Test jsdelivr CDN URL
                set "jsdelivr_url=https://cdn.jsdelivr.net/npm/!package!@latest/dist/!expected_file!"
                echo    🌐 Testing jsdelivr CDN: !jsdelivr_url!
                
                for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!jsdelivr_url!" 2^>nul') do set "jsdelivr_status=%%c"
                
                if "!jsdelivr_status!"=="200" (
                    echo    ✅ jsdelivr CDN file accessible ^(HTTP !jsdelivr_status!^)
                ) else if "!jsdelivr_status!"=="404" (
                    echo    ❌ jsdelivr CDN file not found ^(HTTP !jsdelivr_status!^)
                ) else (
                    echo    ⚠️  jsdelivr CDN unexpected status ^(HTTP !jsdelivr_status!^)
                )
            ) else (
                echo    ❌ Package not found in registry
            )
        ) else (
            echo    ❌ Package not found in registry
        )
        
        echo.
    )
)

REM Summary table
echo 📊 Summary of all NPM packages:
echo.
echo Package                             Version    unpkg CDN       jsdelivr CDN
echo -------                             -------    ---------       -----------

for /l %%i in (0,1,12) do (
    for /f "tokens=1,2 delims=:" %%a in ("!packages[%%i]!") do (
        set "package=%%a"
        set "expected_file=%%b"
        
        REM Get package info
        npm view "!package!" version >temp_npm_info.txt 2>nul
        
        if exist temp_npm_info.txt (
            for /f "tokens=*" %%v in (temp_npm_info.txt) do set "version=%%v"
            if not "!version!"=="" (
                REM Test unpkg CDN
                set "unpkg_url=https://unpkg.com/!package!@latest/dist/!expected_file!"
                for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!unpkg_url!" 2^>nul') do set "unpkg_status=%%c"
                
                if "!unpkg_status!"=="200" (
                    set "unpkg_result=✅ !unpkg_status!"
                ) else (
                    set "unpkg_result=❌ !unpkg_status!"
                )
                
                REM Test jsdelivr CDN
                set "jsdelivr_url=https://cdn.jsdelivr.net/npm/!package!@latest/dist/!expected_file!"
                for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!jsdelivr_url!" 2^>nul') do set "jsdelivr_status=%%c"
                
                if "!jsdelivr_status!"=="200" (
                    set "jsdelivr_result=✅ !jsdelivr_status!"
                ) else (
                    set "jsdelivr_result=❌ !jsdelivr_status!"
                )
            ) else (
                set "version=N/A"
                set "unpkg_result=❌ N/A"
                set "jsdelivr_result=❌ N/A"
            )
        ) else (
            set "version=N/A"
            set "unpkg_result=❌ N/A"
            set "jsdelivr_result=❌ N/A"
        )
        
        REM Format output with padding
        set "package_padded=!package!                                   "
        set "package_padded=!package_padded:~0,35!"
        set "version_padded=!version!          "
        set "version_padded=!version_padded:~0,10!"
        set "unpkg_padded=!unpkg_result!               "
        set "unpkg_padded=!unpkg_padded:~0,15!"
        
        echo !package_padded! !version_padded! !unpkg_padded! !jsdelivr_result!
    )
)

REM Cleanup temp files
del temp_npm_info.txt 2>nul

echo.
echo 🔧 Recommendations:
echo 1. If packages don't exist, run: npm run publish:npm
echo 2. If CDN files return 404, check dist/ folder structure in packages
echo 3. unpkg and jsdelivr CDNs may take time to sync after publishing
echo 4. Verify package.json 'files' field includes dist/ directory
echo 5. Check that build process creates expected bundle files

endlocal