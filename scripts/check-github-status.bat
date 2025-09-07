@echo off
setlocal enabledelayedexpansion

REM GitHub Pages Status Checker
REM Usage: check-github-status.bat

echo 🔍 Checking GitHub Pages status for microfrontends...

REM Load environment variables from .env file
if exist ".env" (
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" (
            set "%%a=%%b"
        )
    )
)

REM Set default username if not provided
if "%GITHUB_USERNAME%"=="" set "GITHUB_USERNAME=cesarchamal"

REM Use GITHUB_API_TOKEN or fallback to GITHUB_TOKEN
if not "%GITHUB_API_TOKEN%"=="" (
    set "GITHUB_TOKEN=%GITHUB_API_TOKEN%"
)

if "%GITHUB_TOKEN%"=="" (
    echo ❌ Error: GITHUB_API_TOKEN not set
    exit /b 1
)

echo 👤 Username: %GITHUB_USERNAME%
echo.

REM Define repositories and expected files
set "repos[0]=single-spa-auth-app:single-spa-auth-app.umd.js"
set "repos[1]=single-spa-layout-app:single-spa-layout-app.umd.js"
set "repos[2]=single-spa-home-app:single-spa-home-app.js"
set "repos[3]=single-spa-angular-app:single-spa-angular-app.js"
set "repos[4]=single-spa-vue-app:single-spa-vue-app.umd.js"
set "repos[5]=single-spa-react-app:single-spa-react-app.js"
set "repos[6]=single-spa-vanilla-app:single-spa-vanilla-app.js"
set "repos[7]=single-spa-webcomponents-app:single-spa-webcomponents-app.js"
set "repos[8]=single-spa-typescript-app:single-spa-typescript-app.js"
set "repos[9]=single-spa-jquery-app:single-spa-jquery-app.js"
set "repos[10]=single-spa-svelte-app:single-spa-svelte-app.js"
set "repos[11]=single-spa-root:root-application.js"

REM Check each repository
for /l %%i in (0,1,11) do (
    for /f "tokens=1,2 delims=:" %%a in ("!repos[%%i]!") do (
        set "repo=%%a"
        set "expected_file=%%b"
        
        echo 📦 Checking repository: !repo!
        echo    🎯 Expected file: !expected_file!
        
        REM 1. Check if repository exists
        curl -s -H "Authorization: token %GITHUB_TOKEN%" "https://api.github.com/repos/%GITHUB_USERNAME%/!repo!" > temp_repo_check.json 2>nul
        
        findstr /c:"Not Found" temp_repo_check.json >nul 2>&1
        if !errorlevel! equ 0 (
            echo    ❌ Repository does not exist
            goto :next_repo
        ) else (
            echo    ✅ Repository exists
        )
        
        REM 2. Check GitHub Pages status
        curl -s -H "Authorization: token %GITHUB_TOKEN%" "https://api.github.com/repos/%GITHUB_USERNAME%/!repo!/pages" > temp_pages_check.json 2>nul
        
        findstr /c:"Not Found" temp_pages_check.json >nul 2>&1
        if !errorlevel! equ 0 (
            echo    ❌ GitHub Pages not enabled
        ) else (
            for /f "tokens=2 delims=:" %%s in ('findstr /c:"status" temp_pages_check.json') do (
                set "status=%%s"
                set "status=!status:"=!"
                set "status=!status:,=!"
            )
            for /f "tokens=2 delims=:" %%u in ('findstr /c:"html_url" temp_pages_check.json') do (
                set "url=%%u"
                set "url=!url:"=!"
                set "url=!url:,=!"
            )
            echo    ✅ GitHub Pages enabled - Status: !status!
            echo    🌐 URL: !url!
        )
        
        REM 3. Check repository contents
        curl -s -H "Authorization: token %GITHUB_TOKEN%" "https://api.github.com/repos/%GITHUB_USERNAME%/!repo!/contents" > temp_contents_check.json 2>nul
        
        findstr /c:"Not Found" temp_contents_check.json >nul 2>&1
        if !errorlevel! equ 0 (
            echo    ❌ No files in repository
        ) else (
            echo    📁 Repository files:
            for /f "tokens=2 delims=:" %%f in ('findstr /c:"name" temp_contents_check.json') do (
                set "filename=%%f"
                set "filename=!filename:"=!"
                set "filename=!filename:,=!"
                echo       - !filename!
            )
            
            REM Check for expected file
            findstr /c:"!expected_file!" temp_contents_check.json >nul 2>&1
            if !errorlevel! equ 0 (
                echo    ✅ Expected bundle file found: !expected_file!
            ) else (
                echo    ⚠️  Expected bundle file not found: !expected_file!
            )
        )
        
        REM 4. Test GitHub Pages URL
        set "pages_url=https://%GITHUB_USERNAME%.github.io/!repo!/!expected_file!"
        echo    🌐 Testing GitHub Pages: !pages_url!
        
        for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!pages_url!" 2^>nul') do set "pages_status=%%c"
        
        if "!pages_status!"=="200" (
            echo    ✅ GitHub Pages file accessible ^(HTTP !pages_status!^)
        ) else if "!pages_status!"=="404" (
            echo    ❌ GitHub Pages file not found ^(HTTP !pages_status!^)
        ) else (
            echo    ⚠️  GitHub Pages unexpected status ^(HTTP !pages_status!^)
        )
        
        REM 5. Test raw GitHub URL
        set "raw_url=https://raw.githubusercontent.com/%GITHUB_USERNAME%/!repo!/main/!expected_file!"
        echo    📄 Testing raw GitHub: !raw_url!
        
        for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!raw_url!" 2^>nul') do set "raw_status=%%c"
        
        if "!raw_status!"=="200" (
            echo    ✅ Raw GitHub file accessible ^(HTTP !raw_status!^)
        ) else if "!raw_status!"=="404" (
            echo    ❌ Raw GitHub file not found ^(HTTP !raw_status!^)
        ) else (
            echo    ⚠️  Raw GitHub unexpected status ^(HTTP !raw_status!^)
        )
        
        :next_repo
        echo.
    )
)

REM Summary table
echo 📊 Summary of all microfrontend files:
echo.
echo Repository               Expected File                  GitHub Pages    Raw GitHub
echo ----------               -------------                  ------------    -----------

for /l %%i in (0,1,11) do (
    for /f "tokens=1,2 delims=:" %%a in ("!repos[%%i]!") do (
        set "repo=%%a"
        set "expected_file=%%b"
        
        REM Test GitHub Pages
        set "pages_url=https://%GITHUB_USERNAME%.github.io/!repo!/!expected_file!"
        for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!pages_url!" 2^>nul') do set "pages_status=%%c"
        
        if "!pages_status!"=="200" (
            set "pages_result=✅ !pages_status!"
        ) else (
            set "pages_result=❌ !pages_status!"
        )
        
        REM Test raw GitHub
        set "raw_url=https://raw.githubusercontent.com/%GITHUB_USERNAME%/!repo!/main/!expected_file!"
        for /f %%c in ('curl -s -o nul -w "%%{http_code}" "!raw_url!" 2^>nul') do set "raw_status=%%c"
        
        if "!raw_status!"=="200" (
            set "raw_result=✅ !raw_status!"
        ) else (
            set "raw_result=❌ !raw_status!"
        )
        
        REM Format output with padding
        set "repo_padded=!repo!                         "
        set "repo_padded=!repo_padded:~0,25!"
        set "file_padded=!expected_file!                              "
        set "file_padded=!file_padded:~0,30!"
        set "pages_padded=!pages_result!               "
        set "pages_padded=!pages_padded:~0,15!"
        
        echo !repo_padded! !file_padded! !pages_padded! !raw_result!
    )
)

REM Cleanup temp files
del temp_repo_check.json 2>nul
del temp_pages_check.json 2>nul
del temp_contents_check.json 2>nul

echo.
echo 🔧 Recommendations:
echo 1. If repositories exist but GitHub Pages not enabled, run the deployment script again
echo 2. If files are missing, check the build process in each repository
echo 3. If GitHub Pages shows 'building', wait 5-10 minutes and try again
echo 4. Check repository visibility - must be public for GitHub Pages
echo 5. Raw GitHub URLs work immediately, GitHub Pages may take time to update

endlocal