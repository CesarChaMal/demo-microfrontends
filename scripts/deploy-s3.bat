@echo off
REM Deploy Microfrontends to S3
REM Usage: deploy-s3.bat [environment]
REM Environment: dev (default), prod

setlocal enabledelayedexpansion

REM Load environment variables
if exist ".env" (
    echo 📄 Loading environment variables from .env...
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" (
            set "%%a=%%b"
        )
    )
)

set ENV=%1
if "%ENV%"=="" set ENV=dev
set BUCKET_NAME=%S3_BUCKET%
if "%AWS_REGION%"=="" set AWS_REGION=eu-central-1
set REGION=%AWS_REGION%

if "%BUCKET_NAME%"=="" (
    echo ❌ Error: S3_BUCKET not set in .env
    exit /b 1
)

echo 🚀 Deploying to S3 bucket: %BUCKET_NAME% (%ENV% environment)

REM Build all applications
echo 🔨 Building all applications for %ENV%...
if "%ENV%"=="prod" (
    npm run build:prod
) else (
    npm run build:dev
)
if errorlevel 1 exit /b 1

REM Build root application
echo 🔨 Building root application...
cd single-spa-root
npm run build
if errorlevel 1 exit /b 1
cd ..

REM Deploy root application to S3
echo 📤 Deploying root application to S3...
aws s3 sync single-spa-root/dist/ s3://%BUCKET_NAME%/ --delete
if errorlevel 1 exit /b 1

REM Deploy each microfrontend
echo 📤 Deploying microfrontends to S3...

REM Create import map
echo 📋 Creating import map...
(
echo {
echo   "imports": {
echo     "@%ORG_NAME%/auth-app": "https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com/@%ORG_NAME%/auth-app/single-spa-auth-app.umd.js",
echo     "@%ORG_NAME%/layout-app": "https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com/@%ORG_NAME%/layout-app/single-spa-layout-app.umd.js",
echo     "@%ORG_NAME%/home-app": "https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com/@%ORG_NAME%/home-app/single-spa-home-app.js",
echo     "@%ORG_NAME%/angular-app": "https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com/@%ORG_NAME%/angular-app/single-spa-angular-app.js",
echo     "@%ORG_NAME%/vue-app": "https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com/@%ORG_NAME%/vue-app/single-spa-vue-app.umd.js",
echo     "@%ORG_NAME%/react-app": "https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com/@%ORG_NAME%/react-app/single-spa-react-app.js",
echo     "@%ORG_NAME%/vanilla-app": "https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com/@%ORG_NAME%/vanilla-app/single-spa-vanilla-app.js",
echo     "@%ORG_NAME%/webcomponents-app": "https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com/@%ORG_NAME%/webcomponents-app/single-spa-webcomponents-app.js",
echo     "@%ORG_NAME%/typescript-app": "https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com/@%ORG_NAME%/typescript-app/single-spa-typescript-app.js",
echo     "@%ORG_NAME%/jquery-app": "https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com/@%ORG_NAME%/jquery-app/single-spa-jquery-app.js",
echo     "@%ORG_NAME%/svelte-app": "https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com/@%ORG_NAME%/svelte-app/single-spa-svelte-app.js"
echo   }
echo }
) > importmap.json

REM Upload import map
aws s3 cp importmap.json s3://%BUCKET_NAME%/@%ORG_NAME%/importmap.json
if errorlevel 1 exit /b 1
del importmap.json

REM Upload each microfrontend
set APPS=auth layout home angular vue react vanilla webcomponents typescript jquery svelte

for %%a in (%APPS%) do (
    set app_dir=single-spa-%%a-app
    if exist "!app_dir!\dist" (
        echo 📤 Uploading %%a app...
        aws s3 sync "!app_dir!\dist\" "s3://%BUCKET_NAME%/@%ORG_NAME%/%%a-app/" --delete
        if errorlevel 1 exit /b 1
    ) else (
        echo ⚠️  Warning: !app_dir!\dist not found, skipping...
    )
)

echo.
echo 🎉 Deployment complete!
echo 📍 Bucket: %BUCKET_NAME%
echo 🌍 Website URL: %S3_WEBSITE_URL%
echo 📦 Import Map: https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com/@%ORG_NAME%/importmap.json
echo.
echo ✅ Your microfrontend application is now live!