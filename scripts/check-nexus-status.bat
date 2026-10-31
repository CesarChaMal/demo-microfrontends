@echo off
setlocal enabledelayedexpansion

REM Nexus Registry Status Checker
REM Usage: check-nexus-status.bat

echo 🔍 Checking Nexus registry status for microfrontends...

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
if "%NEXUS_URL%"=="" set "NEXUS_URL=http://localhost:8081"
if "%NEXUS_REGISTRY%"=="" set "NEXUS_REGISTRY=%NEXUS_URL%/repository/npm-group/"

echo 🏢 Organization: @%ORG_NAME%
echo 🏭 Nexus URL: %NEXUS_URL%
echo 📦 Nexus Registry: %NEXUS_REGISTRY%
echo.

REM Check current NPM registry
for /f "tokens=*" %%r in ('npm config get registry 2^>nul') do set "CURRENT_REGISTRY=%%r"
echo 📦 Current NPM registry: %CURRENT_REGISTRY%

echo %CURRENT_REGISTRY% | findstr "localhost:8081" >nul
if !errorlevel! equ 0 (
    echo ✅ Currently using Nexus registry
) else (
    echo ⚠️  Not using Nexus registry - switch with: npm run registry:nexus
)
echo.

REM Test Nexus connectivity
echo 🔗 Testing Nexus connectivity...
for /f %%c in ('curl -s -o nul -w "%%{http_code}" "%NEXUS_URL%" 2^>nul') do set "nexus_status=%%c"

if "!nexus_status!"=="200" (
    echo ✅ Nexus server accessible ^(HTTP !nexus_status!^)
) else (
    echo ❌ Nexus server not accessible ^(HTTP !nexus_status!^)
    echo    Make sure Nexus is running on %NEXUS_URL%
)
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

echo 📋 Checking package availability in Nexus...

for /l %%i in (0,1,12) do (
    for /f "tokens=1,2 delims=:" %%a in ("!packages[%%i]!") do (
        set "package=%%a"
        set "expected_file=%%b"
        
        echo 📦 Checking package: !package!
        echo    🎯 Expected file: !expected_file!
        
        REM Check if package exists in Nexus registry
        npm view "!package!" version >temp_nexus_info.txt 2>nul
        
        if exist temp_nexus_info.txt (
            for /f "tokens=*" %%v in (temp_nexus_info.txt) do set "version=%%v"
            if not "!version!"=="" (
                echo    ✅ Package exists in Nexus - Version: !version!
                
                REM Test direct Nexus URL for package tarball
                REM Convert @org/package to org/package for URL
                set "package_path=!package:@=!"
                
                REM Extract package name after last /
                for %%p in (!package!) do set "package_name=%%~nxp"
                set "package_name=!package_name:@%ORG_NAME%/=!"
                
                set "nexus_package_url=%NEXUS_REGISTRY%!package_path!/-/!package_name!-!version!.tgz"
                echo    📦 Testing Nexus tarball: !nexus_package_url!
                
                for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!nexus_package_url!" 2^>nul') do set "tarball_status=%%c"
                
                if "!tarball_status!"=="200" (
                    echo    ✅ Nexus tarball accessible ^(HTTP !tarball_status!^)
                ) else if "!tarball_status!"=="404" (
                    echo    ❌ Nexus tarball not found ^(HTTP !tarball_status!^)
                ) else if "!tarball_status!"=="401" (
                    echo    ⚠️  Nexus tarball requires authentication ^(HTTP !tarball_status!^)
                ) else if "!tarball_status!"=="403" (
                    echo    ⚠️  Nexus tarball requires authentication ^(HTTP !tarball_status!^)
                ) else (
                    echo    ⚠️  Nexus tarball unexpected status ^(HTTP !tarball_status!^)
                )
                
                REM Test Nexus package metadata
                set "nexus_metadata_url=%NEXUS_REGISTRY%!package_path!"
                echo    📋 Testing Nexus metadata: !nexus_metadata_url!
                
                for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!nexus_metadata_url!" 2^>nul') do set "metadata_status=%%c"
                
                if "!metadata_status!"=="200" (
                    echo    ✅ Nexus metadata accessible ^(HTTP !metadata_status!^)
                ) else if "!metadata_status!"=="404" (
                    echo    ❌ Nexus metadata not found ^(HTTP !metadata_status!^)
                ) else if "!metadata_status!"=="401" (
                    echo    ⚠️  Nexus metadata requires authentication ^(HTTP !metadata_status!^)
                ) else if "!metadata_status!"=="403" (
                    echo    ⚠️  Nexus metadata requires authentication ^(HTTP !metadata_status!^)
                ) else (
                    echo    ⚠️  Nexus metadata unexpected status ^(HTTP !metadata_status!^)
                )
            ) else (
                echo    ❌ Package not found in Nexus registry
                
                REM Check if it might be available in NPM proxy
                echo    🔍 Checking NPM proxy in Nexus...
                curl -s "%NEXUS_REGISTRY%!package!" >temp_proxy_check.txt 2>nul
                
                findstr /c:"name" temp_proxy_check.txt >nul 2>&1
                if !errorlevel! equ 0 (
                    echo    ✅ Package available via NPM proxy in Nexus
                ) else (
                    echo    ❌ Package not available via NPM proxy either
                )
                
                del temp_proxy_check.txt 2>nul
            )
        ) else (
            echo    ❌ Package not found in Nexus registry
        )
        
        echo.
    )
)

REM Summary table
echo 📊 Summary of all Nexus packages:
echo.
echo Package                             Version    Nexus Direct    NPM Proxy
echo -------                             -------    ------------    ---------

for /l %%i in (0,1,12) do (
    for /f "tokens=1,2 delims=:" %%a in ("!packages[%%i]!") do (
        set "package=%%a"
        set "expected_file=%%b"
        
        REM Get package info from current registry
        npm view "!package!" version >temp_nexus_info.txt 2>nul
        
        if exist temp_nexus_info.txt (
            for /f "tokens=*" %%v in (temp_nexus_info.txt) do set "version=%%v"
            if not "!version!"=="" (
                REM Test Nexus direct access
                set "package_path=!package:@=!"
                for %%p in (!package!) do set "package_name=%%~nxp"
                set "package_name=!package_name:@%ORG_NAME%/=!"
                set "nexus_package_url=%NEXUS_REGISTRY%!package_path!/-/!package_name!-!version!.tgz"
                
                for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!nexus_package_url!" 2^>nul') do set "nexus_status=%%c"
                
                if "!nexus_status!"=="200" (
                    set "nexus_result=✅ !nexus_status!"
                ) else if "!nexus_status!"=="401" (
                    set "nexus_result=⚠️ !nexus_status!"
                ) else if "!nexus_status!"=="403" (
                    set "nexus_result=⚠️ !nexus_status!"
                ) else (
                    set "nexus_result=❌ !nexus_status!"
                )
                
                REM Test NPM proxy
                curl -s "%NEXUS_REGISTRY%!package!" >temp_proxy_check.txt 2>nul
                findstr /c:"name" temp_proxy_check.txt >nul 2>&1
                if !errorlevel! equ 0 (
                    set "proxy_result=✅ Available"
                ) else (
                    set "proxy_result=❌ N/A"
                )
                del temp_proxy_check.txt 2>nul
            ) else (
                set "version=N/A"
                set "nexus_result=❌ N/A"
                set "proxy_result=❌ N/A"
            )
        ) else (
            set "version=N/A"
            set "nexus_result=❌ N/A"
            set "proxy_result=❌ N/A"
        )
        
        REM Format output with padding
        set "package_padded=!package!                                   "
        set "package_padded=!package_padded:~0,35!"
        set "version_padded=!version!          "
        set "version_padded=!version_padded:~0,10!"
        set "nexus_padded=!nexus_result!               "
        set "nexus_padded=!nexus_padded:~0,15!"
        
        echo !package_padded! !version_padded! !nexus_padded! !proxy_result!
    )
)

REM Cleanup temp files
del temp_nexus_info.txt 2>nul

echo.
echo 🔧 Recommendations:
echo 1. If packages don't exist in Nexus, run: npm run publish:nexus
echo 2. If Nexus server not accessible, start Nexus: docker run -d -p 8081:8081 sonatype/nexus3
echo 3. If authentication required, check Nexus credentials in .env file
echo 4. Switch to Nexus registry with: npm run registry:nexus
echo 5. Packages may be available via NPM proxy even if not published directly
echo 6. Check Nexus repository configuration for npm-group, npm-hosted, npm-proxy

endlocal