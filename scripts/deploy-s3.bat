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
echo 🔍 DEBUG: S3_BUCKET=%S3_BUCKET%, AWS_REGION=%AWS_REGION%, ORG_NAME=%ORG_NAME%
echo 🔍 DEBUG: Current directory: %CD%
aws --version >nul 2>&1 && echo 🔍 DEBUG: AWS CLI available || echo 🔍 DEBUG: AWS CLI not found
aws sts get-caller-identity --query Account --output text >nul 2>&1 && echo 🔍 DEBUG: AWS credentials configured || echo 🔍 DEBUG: No AWS credentials

REM Check if S3 bucket exists, create if not
echo 🔍 Checking if S3 bucket exists...
aws s3 ls "s3://%BUCKET_NAME%" >nul 2>&1
if errorlevel 1 (
    echo 📦 Creating S3 bucket %BUCKET_NAME%...
    if "%REGION%"=="us-east-1" (
        aws s3 mb "s3://%BUCKET_NAME%"
    ) else (
        aws s3 mb "s3://%BUCKET_NAME%" --region "%REGION%"
    )
    if errorlevel 1 exit /b 1
    
    echo 🌐 Enabling static website hosting...
    aws s3 website "s3://%BUCKET_NAME%" --index-document index.html --error-document error.html
    if errorlevel 1 exit /b 1
    
    echo 🔓 Removing public access block...
    aws s3api put-public-access-block --bucket "%BUCKET_NAME%" --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
    if errorlevel 1 exit /b 1
    
    echo 📋 Adding public read policy...
    (
    echo {
    echo   "Version": "2012-10-17",
    echo   "Statement": [
    echo     {
    echo       "Sid": "PublicReadGetObject",
    echo       "Effect": "Allow",
    echo       "Principal": "*",
    echo       "Action": "s3:GetObject",
    echo       "Resource": "arn:aws:s3:::%BUCKET_NAME%/*"
    echo     }
    echo   ]
    echo }
    ) > bucket-policy.json
    aws s3api put-bucket-policy --bucket "%BUCKET_NAME%" --policy file://bucket-policy.json
    if errorlevel 1 exit /b 1
    del bucket-policy.json
    
    echo 🔧 Setting up CORS configuration...
    (
    echo {
    echo   "CORSRules": [
    echo     {
    echo       "AllowedHeaders": ["*"],
    echo       "AllowedMethods": ["GET", "HEAD", "PUT", "POST"],
    echo       "AllowedOrigins": ["*"],
    echo       "ExposeHeaders": ["ETag"],
    echo       "MaxAgeSeconds": 3000
    echo     }
    echo   ]
    echo }
    ) > cors-config.json
    aws s3api put-bucket-cors --bucket "%BUCKET_NAME%" --cors-configuration file://cors-config.json
    if errorlevel 1 exit /b 1
    del cors-config.json
    
    echo ✅ S3 bucket setup complete!
) else (
    echo ✅ S3 bucket %BUCKET_NAME% already exists
)

REM Check if called from run.bat (which sets SKIP_BUILD) or standalone
if "%SKIP_BUILD%"=="true" (
    echo 📋 Using pre-built applications from run.bat...
    echo 🔍 DEBUG: Skipping build - applications already built by launcher script
) else (
    echo 🔨 Building all applications for %ENV%...
    echo 🔍 DEBUG: Standalone mode - building applications
    if "%ENV%"=="prod" (
        echo 🔍 DEBUG: Running npm run build:prod
        npm run build:prod
    ) else (
        echo 🔍 DEBUG: Running npm run build:dev
        npm run build:dev
    )
    if errorlevel 1 exit /b 1
    echo 🔍 DEBUG: Build command completed
    
    echo 🔨 Building root application...
    echo 🔍 DEBUG: Changing to single-spa-root directory
    cd single-spa-root
    echo 🔍 DEBUG: Current directory: %CD%
    echo 🔍 DEBUG: Running npm run build in root app
    npm run build
    if errorlevel 1 exit /b 1
    echo 🔍 DEBUG: Root build completed, returning to parent directory
    cd ..
    echo 🔍 DEBUG: Back in directory: %CD%
)

REM Deploy root application to S3
echo 📤 Deploying root application to S3...
aws s3 sync single-spa-root/dist/ s3://%BUCKET_NAME%/ --delete --exclude "*.hot-update.*"
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
echo     "@%ORG_NAME%/svelte-app": "https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com/@%ORG_NAME%/svelte-app/single-spa-svelte-app.js",
echo     "@%ORG_NAME%/solid-app": "https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com/@%ORG_NAME%/solid-app/single-spa-solid-app.js"
echo   }
echo }
) > importmap.json

REM Upload import map
aws s3 cp importmap.json s3://%BUCKET_NAME%/@%ORG_NAME%/importmap.json
if errorlevel 1 exit /b 1
del importmap.json

REM Upload each microfrontend
set APPS=auth layout home angular vue react vanilla webcomponents typescript jquery svelte solid

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