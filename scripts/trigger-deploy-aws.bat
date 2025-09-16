@echo off
REM Trigger AWS S3 deployment by adding timestamps to package.json files
REM Usage: trigger-deploy-aws.bat [commit-message]

setlocal enabledelayedexpansion

set "COMMIT_MSG=%~1"
if "%COMMIT_MSG%"=="" set "COMMIT_MSG=Deploy all microfrontends to S3"

echo 🚀 Triggering AWS S3 deployment...

REM Add trigger timestamps to each app to force GitHub Actions
for /f %%i in ('powershell -Command "Get-Date -UFormat %%s"') do set TIMESTAMP=%%i

set APPS=single-spa-auth-app single-spa-layout-app single-spa-home-app single-spa-angular-app single-spa-vue-app single-spa-react-app single-spa-vanilla-app single-spa-webcomponents-app single-spa-typescript-app single-spa-jquery-app single-spa-svelte-app

for %%a in (%APPS%) do (
    if exist "%%a\package.json" (
        echo 📝 Adding trigger to %%a...
        powershell -Command "(Get-Content '%%a\package.json') -replace '\"_trigger\": \"[0-9]*\"', '\"_trigger\": \"%TIMESTAMP%\"' | Set-Content '%%a\package.json'"
        if errorlevel 1 (
            powershell -Command "(Get-Content '%%a\package.json') -replace '\"version\": \"([^\"]*)\",', '\"version\": \"$1\", \"_trigger\": \"%TIMESTAMP%\",' | Set-Content '%%a\package.json'"
        )
    )
)

REM Also trigger root app
if exist "single-spa-root\package.json" (
    echo 📝 Adding trigger to single-spa-root...
    powershell -Command "(Get-Content 'single-spa-root\package.json') -replace '\"_trigger\": \"[0-9]*\"', '\"_trigger\": \"%TIMESTAMP%\"' | Set-Content 'single-spa-root\package.json'"
    if errorlevel 1 (
        powershell -Command "(Get-Content 'single-spa-root\package.json') -replace '\"version\": \"([^\"]*)\",', '\"version\": \"$1\", \"_trigger\": \"%TIMESTAMP%\",' | Set-Content 'single-spa-root\package.json'"
    )
)

echo.
echo ✅ Triggers added to all applications
echo 📤 Committing and pushing to trigger GitHub Actions deployment...

REM Commit and push
git add .
git commit -m "%COMMIT_MSG%"
git push origin main

echo.
echo 🌍 After deployment, your app will be live at:
echo http://single-spa-demo-774145483743.s3-website,eu-central-1.amazonaws.com