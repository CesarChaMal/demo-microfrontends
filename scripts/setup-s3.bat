@echo off
REM S3 Bucket Setup Script for Single-SPA Microfrontends (Windows)
REM Usage: setup-s3.bat [bucket-name]
REM If no bucket name provided, uses S3_BUCKET from .env

setlocal enabledelayedexpansion

REM Load environment variables from .env file
if exist "single-spa-root\.env" (
    echo 📄 Loading environment variables from .env...
    for /f "usebackq tokens=1,2 delims==" %%a in ("single-spa-root\.env") do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" (
            set "%%a=%%b"
        )
    )
)

REM Get bucket name from parameter or environment variable
set BUCKET_NAME=%1
if "%BUCKET_NAME%"=="" set BUCKET_NAME=%S3_BUCKET%
if "%AWS_REGION%"=="" set AWS_REGION=eu-central-1
set REGION=%AWS_REGION%

if "%BUCKET_NAME%"=="" (
    echo ❌ Error: No bucket name provided and S3_BUCKET not set in .env
    echo Usage: setup-s3.bat [bucket-name]
    exit /b 1
)

echo 🚀 Setting up S3 bucket: %BUCKET_NAME% in region: %REGION%

REM Check if bucket exists
aws s3api head-bucket --bucket %BUCKET_NAME% >nul 2>&1
if %errorlevel%==0 (
    echo ✅ Bucket %BUCKET_NAME% already exists
) else (
    echo 📦 Creating bucket %BUCKET_NAME%...
    if "%REGION%"=="us-east-1" (
        aws s3 mb s3://%BUCKET_NAME%
    ) else (
        aws s3 mb s3://%BUCKET_NAME% --region %REGION%
    )
    if errorlevel 1 exit /b 1
    echo ✅ Bucket created successfully
)

REM Enable static website hosting
echo 🌐 Enabling static website hosting...
aws s3 website s3://%BUCKET_NAME% --index-document index.html --error-document error.html
if errorlevel 1 exit /b 1

REM Remove public access block
echo 🔓 Removing public access block...
aws s3api put-public-access-block --bucket %BUCKET_NAME% --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
if errorlevel 1 exit /b 1

REM Add public read policy
echo 📋 Adding public read policy...
aws s3api put-bucket-policy --bucket %BUCKET_NAME% --policy "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PublicReadGetObject\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::%BUCKET_NAME%/*\"}]}"
if errorlevel 1 exit /b 1

REM Enable CORS for microfrontends
echo 🔧 Configuring CORS...
aws s3api put-bucket-cors --bucket %BUCKET_NAME% --cors-configuration "{\"CORSRules\":[{\"AllowedHeaders\":[\"*\"],\"AllowedMethods\":[\"GET\",\"HEAD\",\"PUT\",\"POST\"],\"AllowedOrigins\":[\"*\"],\"ExposeHeaders\":[\"ETag\"]}]}"
if errorlevel 1 exit /b 1

REM Display results
echo.
echo 🎉 S3 bucket setup complete!
echo 📍 Bucket: %BUCKET_NAME%
echo 🌍 Region: %REGION%
echo 🔗 Website URL: http://%BUCKET_NAME%.s3-website-%REGION%.amazonaws.com
echo 📦 S3 URL: https://%BUCKET_NAME%.s3.%REGION%.amazonaws.com
echo.
echo ✅ Your bucket is now publicly accessible and ready for microfrontend deployment!