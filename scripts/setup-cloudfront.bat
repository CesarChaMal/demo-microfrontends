@echo off
setlocal enabledelayedexpansion

REM CloudFront Setup Script for Single-SPA Microfrontends (Windows)
REM 
REM Usage Examples:
REM   Action-only (uses default bucket from .env):
REM     setup-cloudfront.bat basic           # Basic CloudFront distribution
REM     setup-cloudfront.bat spa             # SPA-optimized distribution
REM     setup-cloudfront.bat full            # Full setup with custom domain
REM     setup-cloudfront.bat                 # Same as basic (default)
REM
REM   Traditional bucket + action:
REM     setup-cloudfront.bat my-bucket basic # Basic distribution with custom bucket
REM     setup-cloudfront.bat my-bucket spa   # SPA distribution with custom bucket
REM     setup-cloudfront.bat my-bucket full  # Full setup with custom bucket
REM
REM Actions:
REM   basic  - Creates basic CloudFront distribution (default)
REM   spa    - SPA-optimized: custom error pages, caching rules
REM   full   - Full setup: SPA optimization + custom domain + SSL

echo 📄 Loading environment variables from .env...
if exist .env (
    for /f "usebackq tokens=1,2 delims==" %%a in (.env) do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" (
            set "%%a=%%b"
        )
    )
)

REM Parse arguments
set "ACTION=basic"
set "BUCKET_NAME=%S3_BUCKET%"

if "%1"=="basic" if "%2"=="" (
    set "ACTION=basic"
) else if "%1"=="spa" if "%2"=="" (
    set "ACTION=spa"
) else if "%1"=="full" if "%2"=="" (
    set "ACTION=full"
) else if not "%1"=="" (
    if "%2"=="" (
        set "BUCKET_NAME=%1"
    ) else (
        set "BUCKET_NAME=%1"
        set "ACTION=%2"
    )
)

if "%AWS_REGION%"=="" set "AWS_REGION=eu-central-1"

if "%BUCKET_NAME%"=="" (
    echo ❌ Error: No bucket name provided and S3_BUCKET not set in .env
    echo Usage: setup-cloudfront.bat [bucket-name] [action]
    echo Actions: basic ^(default^), spa, full
    exit /b 1
)

echo 🚀 CloudFront Setup: %ACTION% for bucket %BUCKET_NAME% in region %AWS_REGION%

REM Check if bucket exists
aws s3api head-bucket --bucket "%BUCKET_NAME%" >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: S3 bucket %BUCKET_NAME% does not exist
    echo 💡 Run setup-s3.bat %BUCKET_NAME% public first
    exit /b 1
)

set "ORIGIN_DOMAIN=%BUCKET_NAME%.s3-website-%AWS_REGION%.amazonaws.com"

if "%ACTION%"=="basic" goto :create_basic
if "%ACTION%"=="spa" goto :create_spa
if "%ACTION%"=="full" goto :create_full

:create_basic
echo 📦 Creating basic CloudFront distribution...

set "CALLER_REF=%RANDOM%%TIME:~-5%"
set "DISTRIBUTION_CONFIG={\"CallerReference\":\"%CALLER_REF%\",\"Comment\":\"Basic distribution for %BUCKET_NAME%\",\"DefaultCacheBehavior\":{\"TargetOriginId\":\"%BUCKET_NAME%-origin\",\"ViewerProtocolPolicy\":\"redirect-to-https\",\"TrustedSigners\":{\"Enabled\":false,\"Quantity\":0},\"ForwardedValues\":{\"QueryString\":false,\"Cookies\":{\"Forward\":\"none\"}},\"MinTTL\":0},\"Origins\":{\"Quantity\":1,\"Items\":[{\"Id\":\"%BUCKET_NAME%-origin\",\"DomainName\":\"%ORIGIN_DOMAIN%\",\"CustomOriginConfig\":{\"HTTPPort\":80,\"HTTPSPort\":443,\"OriginProtocolPolicy\":\"http-only\"}}]},\"Enabled\":true,\"PriceClass\":\"PriceClass_100\"}"

for /f "tokens=*" %%i in ('aws cloudfront create-distribution --distribution-config "%DISTRIBUTION_CONFIG%" --query "Distribution.Id" --output text') do set "DISTRIBUTION_ID=%%i"
for /f "tokens=*" %%i in ('aws cloudfront create-distribution --distribution-config "%DISTRIBUTION_CONFIG%" --query "Distribution.DomainName" --output text') do set "DOMAIN_NAME=%%i"

echo ✅ Basic CloudFront distribution created!
echo 🆔 Distribution ID: %DISTRIBUTION_ID%
echo 🌐 CloudFront URL: https://%DOMAIN_NAME%
goto :update_env

:create_spa
echo 📦 Creating SPA-optimized CloudFront distribution...
echo 💡 Using basic distribution with SPA features ^(Windows batch limitation^)

set "CALLER_REF=%RANDOM%%TIME:~-5%"
set "DISTRIBUTION_CONFIG={\"CallerReference\":\"%CALLER_REF%\",\"Comment\":\"SPA-optimized distribution for %BUCKET_NAME%\",\"DefaultCacheBehavior\":{\"TargetOriginId\":\"%BUCKET_NAME%-origin\",\"ViewerProtocolPolicy\":\"redirect-to-https\",\"TrustedSigners\":{\"Enabled\":false,\"Quantity\":0},\"ForwardedValues\":{\"QueryString\":true,\"Cookies\":{\"Forward\":\"none\"}},\"MinTTL\":0,\"DefaultTTL\":86400,\"MaxTTL\":31536000,\"Compress\":true},\"CustomErrorResponses\":{\"Quantity\":1,\"Items\":[{\"ErrorCode\":404,\"ResponsePagePath\":\"/index.html\",\"ResponseCode\":\"200\",\"ErrorCachingMinTTL\":300}]},\"Origins\":{\"Quantity\":1,\"Items\":[{\"Id\":\"%BUCKET_NAME%-origin\",\"DomainName\":\"%ORIGIN_DOMAIN%\",\"CustomOriginConfig\":{\"HTTPPort\":80,\"HTTPSPort\":443,\"OriginProtocolPolicy\":\"http-only\"}}]},\"Enabled\":true,\"PriceClass\":\"PriceClass_100\"}"

for /f "tokens=*" %%i in ('aws cloudfront create-distribution --distribution-config "%DISTRIBUTION_CONFIG%" --query "Distribution.Id" --output text') do set "DISTRIBUTION_ID=%%i"
for /f "tokens=*" %%i in ('aws cloudfront create-distribution --distribution-config "%DISTRIBUTION_CONFIG%" --query "Distribution.DomainName" --output text') do set "DOMAIN_NAME=%%i"

echo ✅ SPA-optimized CloudFront distribution created!
echo 🆔 Distribution ID: %DISTRIBUTION_ID%
echo 🌐 CloudFront URL: https://%DOMAIN_NAME%
echo 🔧 Features: Custom error pages, compression, SPA routing
goto :update_env

:create_full
if "%CUSTOM_DOMAIN%"=="" (
    echo ⚠️  CUSTOM_DOMAIN not set in .env, creating SPA distribution without custom domain
    goto :create_spa
)

echo 📦 Creating full CloudFront distribution with custom domain...
echo 🌐 Custom domain: %CUSTOM_DOMAIN%
echo ⚠️  Note: You need to have SSL certificate in ACM for %CUSTOM_DOMAIN%
echo 💡 For custom domain setup, please:
echo    1. Create SSL certificate in AWS Certificate Manager
echo    2. Update DNS to point to CloudFront
echo    3. Use AWS Console for custom domain configuration
goto :create_spa

:update_env
if not "%DISTRIBUTION_ID%"=="" (
    echo 📝 Updating .env file with Distribution ID...
    
    REM Create temp file with updated content
    (
        for /f "usebackq tokens=1,* delims==" %%a in (.env) do (
            if "%%a"=="CLOUDFRONT_DISTRIBUTION_ID" (
                echo CLOUDFRONT_DISTRIBUTION_ID=%DISTRIBUTION_ID%
            ) else (
                echo %%a=%%b
            )
        )
    ) > .env.tmp
    
    REM Check if CLOUDFRONT_DISTRIBUTION_ID was found and updated
    findstr "CLOUDFRONT_DISTRIBUTION_ID=" .env.tmp >nul
    if errorlevel 1 (
        echo CLOUDFRONT_DISTRIBUTION_ID=%DISTRIBUTION_ID% >> .env.tmp
    )
    
    move .env.tmp .env >nul
    echo ✅ Updated .env with CLOUDFRONT_DISTRIBUTION_ID=%DISTRIBUTION_ID%
)

echo.
echo ⏳ Waiting for CloudFront distribution to deploy ^(this may take 10-15 minutes^)...
echo 💡 You can continue with other tasks - deployment happens in background
echo 🔍 Check status: aws cloudfront get-distribution --id %DISTRIBUTION_ID%
echo.
echo 🎉 CloudFront configuration complete!
echo 📍 Bucket: %BUCKET_NAME%
echo 🆔 Distribution ID: %DISTRIBUTION_ID%
echo 🌐 CloudFront URL: https://%DOMAIN_NAME%
echo ⏳ Status: Deploying ^(10-15 minutes^)
echo.
echo 🚀 Next steps:
echo    1. Wait for deployment to complete
echo    2. Test your microfrontends via CloudFront URL
echo    3. Use 'npm run trigger:aws:s3' for deployments with cache invalidation

endlocal