@echo off
setlocal enabledelayedexpansion

REM CloudFront CDN Status Checker (Windows)
REM Checks CloudFront distribution status, origin health, and S3 bucket contents

echo 📄 Loading environment variables from .env...
if exist .env (
    for /f "usebackq tokens=1,2 delims==" %%a in (.env) do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" (
            set "%%a=%%b"
        )
    )
)

if "%CLOUDFRONT_DISTRIBUTION_ID%"=="" (
    echo ❌ CLOUDFRONT_DISTRIBUTION_ID not set in .env
    exit /b 1
)

if "%S3_BUCKET%"=="" (
    echo ❌ S3_BUCKET not set in .env
    exit /b 1
)

echo 🔍 CloudFront CDN Status Check
echo ================================

REM 1. Check CloudFront distribution status
echo 📡 CloudFront Distribution Status:
for /f "tokens=*" %%i in ('aws cloudfront get-distribution --id "%CLOUDFRONT_DISTRIBUTION_ID%" --query "Distribution.Status" --output text') do set "STATUS=%%i"
echo    Status: %STATUS%

REM 2. Get CloudFront domain
for /f "tokens=*" %%i in ('aws cloudfront get-distribution --id "%CLOUDFRONT_DISTRIBUTION_ID%" --query "Distribution.DomainName" --output text') do set "CLOUDFRONT_DOMAIN=%%i"
echo    Domain: https://%CLOUDFRONT_DOMAIN%

REM 3. Check origin configuration
echo.
echo 🎯 Origin Configuration:
for /f "tokens=*" %%i in ('aws cloudfront get-distribution --id "%CLOUDFRONT_DISTRIBUTION_ID%" --query "Distribution.DistributionConfig.Origins.Items[0].DomainName" --output text') do set "ORIGIN_DOMAIN=%%i"
echo    Origin: %ORIGIN_DOMAIN%

REM 4. Check S3 bucket status
echo.
echo 🪣 S3 Bucket Status:
aws s3api head-bucket --bucket "%S3_BUCKET%" >nul 2>&1
if errorlevel 1 (
    echo    ❌ Bucket does not exist: %S3_BUCKET%
    goto :test_endpoints
)

echo    ✅ Bucket exists: %S3_BUCKET%

REM Check website configuration
aws s3api get-bucket-website --bucket "%S3_BUCKET%" >nul 2>&1
if errorlevel 1 (
    echo    ❌ Website hosting not configured
) else (
    echo    ✅ Website hosting enabled
    for /f "tokens=*" %%i in ('aws s3api get-bucket-website --bucket "%S3_BUCKET%" --query "IndexDocument.Suffix" --output text') do set "INDEX_DOC=%%i"
    echo    📄 Index document: %INDEX_DOC%
)

REM Check if index.html exists
aws s3api head-object --bucket "%S3_BUCKET%" --key "index.html" >nul 2>&1
if errorlevel 1 (
    echo    ❌ index.html missing
) else (
    echo    ✅ index.html exists
)

REM Count files (simplified)
for /f "tokens=*" %%i in ('aws s3 ls s3://%S3_BUCKET%/ --recursive ^| find /c /v ""') do set "FILE_COUNT=%%i"
echo    📊 Total files: %FILE_COUNT%

:test_endpoints
REM 5. Test S3 website endpoint
echo.
echo 🌐 S3 Website Endpoint Test:
if "%AWS_REGION%"=="" set "AWS_REGION=eu-central-1"
set "S3_WEBSITE_URL=http://%S3_BUCKET%.s3-website.%AWS_REGION%.amazonaws.com"
echo    Testing: %S3_WEBSITE_URL%

curl -s -I "%S3_WEBSITE_URL%" | findstr "200 301 302" >nul
if errorlevel 1 (
    echo    ❌ S3 website endpoint not accessible
    echo    💡 Run: npm run s3:setup:public
) else (
    echo    ✅ S3 website endpoint accessible
)

REM 6. Test CloudFront endpoint
echo.
echo ☁️ CloudFront Endpoint Test:
set "CLOUDFRONT_URL=https://%CLOUDFRONT_DOMAIN%"
echo    Testing: %CLOUDFRONT_URL%

curl -s -I "%CLOUDFRONT_URL%" | findstr "200 301 302" >nul
if errorlevel 1 (
    echo    ❌ CloudFront endpoint not accessible ^(502 Bad Gateway^)
    echo    💡 Possible issues:
    echo       - S3 website hosting not configured
    echo       - Missing index.html file
    echo       - Bucket policy issues
) else (
    echo    ✅ CloudFront endpoint accessible
)

REM 7. Show next steps
echo.
echo 🚀 Recommended Actions:
if not "%STATUS%"=="Deployed" (
    echo    ⏳ Wait for CloudFront deployment to complete
) else if "%FILE_COUNT%"=="0" (
    echo    📦 Deploy files: npm run trigger:aws:s3
) else (
    echo    🔄 Invalidate cache: npm run trigger:aws:s3
)

echo.
echo 🔗 Quick Links:
echo    CloudFront: %CLOUDFRONT_URL%
echo    S3 Direct:  %S3_WEBSITE_URL%

endlocal