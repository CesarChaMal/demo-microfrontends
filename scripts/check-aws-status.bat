@echo off
setlocal enabledelayedexpansion

REM AWS S3 Status Checker
REM Usage: check-aws-status.bat

echo 🔍 Checking AWS S3 status for microfrontends...

REM Load environment variables from .env file
if exist ".env" (
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" (
            set "%%a=%%b"
        )
    )
)

REM Set defaults
if "%AWS_REGION%"=="" set "AWS_REGION=us-east-1"
if "%ORG_NAME%"=="" set "ORG_NAME=cesarchamal"

if "%S3_BUCKET%"=="" (
    echo ❌ Error: S3_BUCKET not set
    exit /b 1
)

echo 🪣 Bucket: %S3_BUCKET%
echo 🌍 Region: %AWS_REGION%
echo 🏢 Organization: %ORG_NAME%
echo.

REM S3 URL formats
set "S3_WEBSITE_URL=http://%S3_BUCKET%.s3-website.%AWS_REGION%.amazonaws.com"
set "S3_API_URL=https://%S3_BUCKET%.s3.%AWS_REGION%.amazonaws.com"

echo 🌐 S3 Website URL: %S3_WEBSITE_URL%
echo 📡 S3 API URL: %S3_API_URL%
echo.

REM Define microfrontends and expected files
set "apps[0]=auth-app:single-spa-auth-app.umd.js"
set "apps[1]=layout-app:single-spa-layout-app.umd.js"
set "apps[2]=home-app:single-spa-home-app.js"
set "apps[3]=angular-app:single-spa-angular-app.js"
set "apps[4]=vue-app:single-spa-vue-app.umd.js"
set "apps[5]=react-app:single-spa-react-app.js"
set "apps[6]=vanilla-app:single-spa-vanilla-app.js"
set "apps[7]=webcomponents-app:single-spa-webcomponents-app.js"
set "apps[8]=typescript-app:single-spa-typescript-app.js"
set "apps[9]=jquery-app:single-spa-jquery-app.js"
set "apps[10]=svelte-app:single-spa-svelte-app.js"
set "apps[11]=solid-app:single-spa-solid-app.js"

REM Check root application files
echo 🏠 Checking root application files...

set "root_files[0]=index.html"
set "root_files[1]=root-application.js"

for /l %%i in (0,1,1) do (
    set "file=!root_files[%%i]!"
    echo 📄 Testing root file: !file!
    
    REM Test S3 website URL
    set "website_url=%S3_WEBSITE_URL%/!file!"
    for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!website_url!" 2^>nul') do set "website_status=%%c"
    
    if "!website_status!"=="200" (
        echo    ✅ S3 Website accessible ^(HTTP !website_status!^): !website_url!
    ) else if "!website_status!"=="404" (
        echo    ❌ S3 Website file not found ^(HTTP !website_status!^): !website_url!
    ) else (
        echo    ⚠️  S3 Website unexpected status ^(HTTP !website_status!^): !website_url!
    )
    
    REM Test S3 API URL
    set "api_url=%S3_API_URL%/!file!"
    for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!api_url!" 2^>nul') do set "api_status=%%c"
    
    if "!api_status!"=="200" (
        echo    ✅ S3 API accessible ^(HTTP !api_status!^): !api_url!
    ) else if "!api_status!"=="403" (
        echo    ⚠️  S3 API forbidden ^(HTTP !api_status!^): !api_url!
    ) else if "!api_status!"=="404" (
        echo    ❌ S3 API file not found ^(HTTP !api_status!^): !api_url!
    ) else (
        echo    ⚠️  S3 API unexpected status ^(HTTP !api_status!^): !api_url!
    )
)

echo.

REM Check import map
echo 📋 Checking import map...
set "importmap_path=@%ORG_NAME%/importmap.json"
set "website_importmap_url=%S3_WEBSITE_URL%/%importmap_path%"

echo 📄 Testing import map: %importmap_path%

for /f %%c in ('curl -s -o nul -w "%%{http_code}" "%website_importmap_url%" 2^>nul') do set "importmap_status=%%c"

if "!importmap_status!"=="200" (
    echo    ✅ Import map accessible ^(HTTP !importmap_status!^): %website_importmap_url%
    echo    📋 Import map content:
    curl -s "%website_importmap_url%" 2>nul
) else if "!importmap_status!"=="404" (
    echo    ❌ Import map not found ^(HTTP !importmap_status!^): %website_importmap_url%
) else (
    echo    ⚠️  Import map unexpected status ^(HTTP !importmap_status!^): %website_importmap_url%
)

echo.

REM Check each microfrontend
echo 🧩 Checking microfrontend files...

for /l %%i in (0,1,11) do (
    for /f "tokens=1,2 delims=:" %%a in ("!apps[%%i]!") do (
        set "app=%%a"
        set "expected_file=%%b"
        set "app_path=@%ORG_NAME%/!app!/!expected_file!"
        
        echo 📦 Checking app: !app!
        echo    🎯 Expected file: !expected_file!
        echo    📁 S3 path: !app_path!
        
        REM Test S3 website URL
        set "website_url=%S3_WEBSITE_URL%/!app_path!"
        echo    🌐 Testing S3 Website: !website_url!
        
        for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!website_url!" 2^>nul') do set "website_status=%%c"
        
        if "!website_status!"=="200" (
            echo    ✅ S3 Website file accessible ^(HTTP !website_status!^)
        ) else if "!website_status!"=="404" (
            echo    ❌ S3 Website file not found ^(HTTP !website_status!^)
        ) else (
            echo    ⚠️  S3 Website unexpected status ^(HTTP !website_status!^)
        )
        
        REM Test S3 API URL
        set "api_url=%S3_API_URL%/!app_path!"
        echo    📡 Testing S3 API: !api_url!
        
        for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!api_url!" 2^>nul') do set "api_status=%%c"
        
        if "!api_status!"=="200" (
            echo    ✅ S3 API file accessible ^(HTTP !api_status!^)
        ) else if "!api_status!"=="403" (
            echo    ⚠️  S3 API forbidden ^(HTTP !api_status!^)
        ) else if "!api_status!"=="404" (
            echo    ❌ S3 API file not found ^(HTTP !api_status!^)
        ) else (
            echo    ⚠️  S3 API unexpected status ^(HTTP !api_status!^)
        )
        
        echo.
    )
)

REM Summary table
echo 📊 Summary of all microfrontend files:
echo.
echo Application          Expected File                       S3 Website      S3 API
echo -----------          -------------                       ----------      ------

REM Root files summary
for /l %%i in (0,1,1) do (
    set "file=!root_files[%%i]!"
    
    REM Test S3 website
    set "website_url=%S3_WEBSITE_URL%/!file!"
    for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!website_url!" 2^>nul') do set "website_status=%%c"
    
    if "!website_status!"=="200" (
        set "website_result=✅ !website_status!"
    ) else (
        set "website_result=❌ !website_status!"
    )
    
    REM Test S3 API
    set "api_url=%S3_API_URL%/!file!"
    for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!api_url!" 2^>nul') do set "api_status=%%c"
    
    if "!api_status!"=="200" (
        set "api_result=✅ !api_status!"
    ) else if "!api_status!"=="403" (
        set "api_result=⚠️ !api_status!"
    ) else (
        set "api_result=❌ !api_status!"
    )
    
    REM Format output with padding
    set "app_padded=root                    "
    set "app_padded=!app_padded:~0,20!"
    set "file_padded=!file!                                   "
    set "file_padded=!file_padded:~0,35!"
    set "website_padded=!website_result!               "
    set "website_padded=!website_padded:~0,15!"
    
    echo !app_padded! !file_padded! !website_padded! !api_result!
)

REM Import map summary
set "importmap_path=@%ORG_NAME%/importmap.json"
set "website_importmap_url=%S3_WEBSITE_URL%/%importmap_path%"
for /f %%c in ('curl -s -o nul -w "%%{http_code}" "%website_importmap_url%" 2^>nul') do set "importmap_status=%%c"

if "!importmap_status!"=="200" (
    set "importmap_result=✅ !importmap_status!"
) else (
    set "importmap_result=❌ !importmap_status!"
)

set "app_padded=importmap            "
set "app_padded=!app_padded:~0,20!"
set "file_padded=importmap.json                         "
set "file_padded=!file_padded:~0,35!"
set "website_padded=!importmap_result!               "
set "website_padded=!website_padded:~0,15!"

echo !app_padded! !file_padded! !website_padded! N/A

REM Microfrontends summary
for /l %%i in (0,1,11) do (
    for /f "tokens=1,2 delims=:" %%a in ("!apps[%%i]!") do (
        set "app=%%a"
        set "expected_file=%%b"
        set "app_path=@%ORG_NAME%/!app!/!expected_file!"
        
        REM Test S3 website
        set "website_url=%S3_WEBSITE_URL%/!app_path!"
        for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!website_url!" 2^>nul') do set "website_status=%%c"
        
        if "!website_status!"=="200" (
            set "website_result=✅ !website_status!"
        ) else (
            set "website_result=❌ !website_status!"
        )
        
        REM Test S3 API
        set "api_url=%S3_API_URL%/!app_path!"
        for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!api_url!" 2^>nul') do set "api_status=%%c"
        
        if "!api_status!"=="200" (
            set "api_result=✅ !api_status!"
        ) else if "!api_status!"=="403" (
            set "api_result=⚠️ !api_status!"
        ) else (
            set "api_result=❌ !api_status!"
        )
        
        REM Format output with padding
        set "app_padded=!app!                    "
        set "app_padded=!app_padded:~0,20!"
        set "file_padded=!expected_file!                                   "
        set "file_padded=!file_padded:~0,35!"
        set "website_padded=!website_result!               "
        set "website_padded=!website_padded:~0,15!"
        
        echo !app_padded! !file_padded! !website_padded! !api_result!
    )
)

echo.
echo 🔧 Recommendations:
echo 1. If S3 Website returns 404, check if files are deployed to S3
echo 2. If S3 API returns 403, this is normal for public website hosting
echo 3. S3 Website URLs should be used for actual application access
echo 4. Import map should be accessible for SystemJS to load microfrontends
echo 5. Run deployment script if files are missing: scripts\deploy-s3.bat
echo 6. Check S3 bucket policy and website configuration if needed

endlocal