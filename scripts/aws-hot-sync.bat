@echo off
setlocal enabledelayedexpansion

REM AWS S3 Hot Sync Script
REM Usage: aws-hot-sync.bat

echo 🔥 Starting AWS S3 Hot Sync for microfrontends...

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

REM Define applications and their S3 paths
set "apps[0]=single-spa-root:"
set "apps[1]=single-spa-auth-app:@%ORG_NAME%/auth-app/"
set "apps[2]=single-spa-layout-app:@%ORG_NAME%/layout-app/"
set "apps[3]=single-spa-home-app:@%ORG_NAME%/home-app/"
set "apps[4]=single-spa-angular-app:@%ORG_NAME%/angular-app/"
set "apps[5]=single-spa-vue-app:@%ORG_NAME%/vue-app/"
set "apps[6]=single-spa-react-app:@%ORG_NAME%/react-app/"
set "apps[7]=single-spa-vanilla-app:@%ORG_NAME%/vanilla-app/"
set "apps[8]=single-spa-webcomponents-app:@%ORG_NAME%/webcomponents-app/"
set "apps[9]=single-spa-typescript-app:@%ORG_NAME%/typescript-app/"
set "apps[10]=single-spa-jquery-app:@%ORG_NAME%/jquery-app/"
set "apps[11]=single-spa-svelte-app:@%ORG_NAME%/svelte-app/"

REM Function to sync a single app
:sync_app
set "app=%~1"
set "s3_path=%~2"

if exist "%app%\dist" (
    echo 🔄 Syncing %app% to s3://%S3_BUCKET%/%s3_path%
    aws s3 sync "%app%\dist\" "s3://%S3_BUCKET%/%s3_path%" --exclude "*.hot-update.*" --exclude "*.map" --delete --cache-control "no-cache, no-store, must-revalidate"
    if !errorlevel! equ 0 (
        echo ✅ Synced %app%
    ) else (
        echo ❌ Failed to sync %app%
    )
) else (
    echo ⚠️  No dist directory found for %app%
)
goto :eof

REM Initial sync of all apps
echo 🚀 Performing initial sync of all apps...
for /l %%i in (0,1,11) do (
    for /f "tokens=1,2 delims=:" %%a in ("!apps[%%i]!") do (
        call :sync_app "%%a" "%%b"
    )
)

echo.
echo 🎉 Initial sync complete!
echo.

REM Start watching for changes
echo 👀 Watching for file changes...
echo Press Ctrl+C to stop
echo.

REM Create a timestamp file for comparison
echo %date% %time% > last_sync.tmp

:watch_loop
timeout /t 5 /nobreak >nul

REM Check if any dist directory has been modified
set "changed=false"
for /l %%i in (0,1,11) do (
    for /f "tokens=1,2 delims=:" %%a in ("!apps[%%i]!") do (
        set "app=%%a"
        if exist "!app!\dist" (
            REM Check if any file in dist is newer than our timestamp
            for /f %%f in ('dir "!app!\dist" /s /b /a-d 2^>nul') do (
                for /f %%t in ('forfiles /p "!app!\dist" /s /m *.* /c "cmd /c if @isdir==FALSE if @fdate gtr %date% echo changed" 2^>nul ^| findstr changed') do (
                    set "changed=true"
                    goto :sync_all
                )
            )
        )
    )
)

REM If no changes detected, continue watching
if "%changed%"=="false" goto :watch_loop

:sync_all
echo 📁 File changes detected, syncing all apps...
for /l %%i in (0,1,11) do (
    for /f "tokens=1,2 delims=:" %%a in ("!apps[%%i]!") do (
        call :sync_app "%%a" "%%b"
    )
)

echo 🎉 All apps synced at %date% %time%
echo.

REM Update timestamp and continue watching
echo %date% %time% > last_sync.tmp
goto :watch_loop

REM Cleanup on exit
:cleanup
if exist last_sync.tmp del last_sync.tmp
endlocal