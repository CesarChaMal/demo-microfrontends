@echo off
REM Demo Microfrontends Launcher Script for Windows
REM Usage: run.bat [mode] [environment]
REM Mode: local (default), npm, nexus, github, aws
REM Environment: dev (default), prod
REM Examples:
REM   run.bat                     Default: local dev (all 12 apps)
REM   run.bat local               Local dev (all 12 apps)
REM   run.bat local dev           Local dev (all 12 apps)
REM   run.bat local prod          Local prod (root only)
REM   run.bat npm                 NPM dev (root only)
REM   run.bat npm dev             NPM dev (root only)
REM   run.bat npm prod            NPM prod (root only)
REM   run.bat nexus               Nexus dev (root only)
REM   run.bat nexus dev           Nexus dev (root only)
REM   run.bat nexus prod          Nexus prod (root only)
REM   run.bat github              GitHub dev - read existing pages (root only)
REM   run.bat github dev          GitHub dev - read existing pages (root only)
REM   run.bat github prod         GitHub prod - create repos + deploy (root only)
REM   run.bat aws                 AWS dev (root only)
REM   run.bat aws dev             AWS dev (root only)
REM   run.bat aws prod            AWS prod (root only)

setlocal enabledelayedexpansion

REM Parse arguments
set MODE=%1
set ENV=%2
if "%MODE%"=="" set MODE=local
if "%ENV%"=="" set ENV=dev

REM Update .env file with current mode and environment
echo 📝 Updating SPA configuration in .env...
powershell -Command "(Get-Content .env) -replace '^SPA_MODE=.*', 'SPA_MODE=%MODE%' | Set-Content .env"
powershell -Command "(Get-Content .env) -replace '^SPA_ENV=.*', 'SPA_ENV=%ENV%' | Set-Content .env"

echo 🚀 Starting Demo Microfrontends Application in %MODE% mode (%ENV% environment)...
echo 🔍 DEBUG: Script execution started at %DATE% %TIME%
echo 🔍 DEBUG: Working directory: %CD%
echo 🔍 DEBUG: User: %USERNAME%
echo 🔍 DEBUG: Platform: Windows

REM Set OpenSSL legacy provider for Node.js 22 compatibility with older Webpack
echo ⚠️  Setting OpenSSL legacy provider for Node.js 22 compatibility
set NODE_OPTIONS=--openssl-legacy-provider

REM Install root dependencies first (needed for rimraf)
echo 📦 Installing root dependencies...
call npm install
if errorlevel 1 exit /b 1

REM Install all dependencies
echo 📦 Installing all dependencies...
call npm run install:all
if errorlevel 1 exit /b 1

REM Build applications based on environment
if "%ENV%"=="prod" (
    echo 🔨 Building all applications for production...
    call npm run build:prod
    if errorlevel 1 exit /b 1
) else (
    echo 🔨 Building all applications for development...
    call npm run build:dev
    if errorlevel 1 exit /b 1
)

if "%MODE%"=="local" (
    echo 🔍 DEBUG: Local mode - ENV=%ENV%, NODE_VERSION=
    node --version
    echo 🔍 DEBUG: NPM_VERSION=
    npm --version
    
    if "%ENV%"=="prod" (
        echo 🌐 Starting production server...
        echo 🔍 DEBUG: Production mode - serving built files from single-spa-root/dist
        echo Main application: http://localhost:8080
        echo.
        echo Press Ctrl+C to stop
        call npm start
    ) else (
        echo 🌐 Starting all microfrontends...
        echo 🔍 DEBUG: Development mode - starting individual servers on ports 4201-4211
        echo Main application: http://localhost:8080
        echo.
        echo Microfrontend ports:
        echo   - Auth App: http://localhost:4201
        echo   - Layout App: http://localhost:4202
        echo   - Home App: http://localhost:4203
        echo   - Angular App: http://localhost:4204
        echo   - Vue App: http://localhost:4205
        echo   - React App: http://localhost:4206
        echo   - Vanilla App: http://localhost:4207
        echo   - Web Components App: http://localhost:4208
        echo   - TypeScript App: http://localhost:4209
        echo   - jQuery App: http://localhost:4210
        echo   - Svelte App: http://localhost:4211
        echo.
        echo Press Ctrl+C to stop all services
        call npm run dev:all
    )
) else (
    if "%ENV%"=="prod" (
        if "%MODE%"=="aws" (
            echo 🚀 AWS production: Deploy using scripts\deploy-s3.bat prod
            echo 🌐 Starting production server...
            echo Main application: http://localhost:8080?mode=%MODE%
            echo.
            echo 🌍 Public S3 Website:
            echo   http://single-spa-demo-774145483743.s3-website-eu-central-1.amazonaws.com
        ) else (
            echo 🌐 Starting production server...
            echo Main application: http://localhost:8080?mode=%MODE%
        )
        echo.
        echo Press Ctrl+C to stop
        call npm start -- --env.mode=%MODE%
    ) else (
        echo 🌐 Starting development server...
        echo Main application: http://localhost:8080?mode=%MODE%
        echo.
        if "%MODE%"=="npm" (
            echo 🔍 DEBUG: NPM mode - ENV=%ENV%
            echo 📦 NPM mode: Publishing packages to NPM registry
            if "%ENV%"=="prod" (
                echo 🔍 DEBUG: Running npm run publish:npm:prod
                call npm run publish:npm:prod
            ) else (
                echo 🔍 DEBUG: Running npm run publish:npm:dev
                call npm run publish:npm:dev
            )
            if errorlevel 1 (
                echo ❌ NPM publishing failed
                exit /b 1
            )
            echo ✅ NPM publishing successful
            if "%ENV%"=="prod" (
                echo 🌍 Public NPM Package: https://www.npmjs.com/package/@cesarchamal/single-spa-root
                echo 🌐 Production: Local server + root app available on NPM registry
            ) else (
                echo 📖 Development: Local server loading microfrontends from NPM registry
            )
            echo 📦 Switching to NPM mode and starting server...
            call npm run mode:npm
            if errorlevel 1 exit /b 1
        )
        if "%MODE%"=="nexus" (
            echo 🔍 DEBUG: Nexus mode - ENV=%ENV%
            echo 📦 Nexus mode: Publishing packages to Nexus registry
            if "%ENV%"=="prod" (
                echo 🔍 DEBUG: Running npm run publish:nexus:prod
                call npm run publish:nexus:prod
            ) else (
                echo 🔍 DEBUG: Running npm run publish:nexus:dev
                call npm run publish:nexus:dev
            )
            if errorlevel 1 (
                echo ❌ Nexus publishing failed
                exit /b 1
            )
            echo ✅ Nexus publishing successful
            if "%ENV%"=="prod" (
                echo 🌍 Public Nexus Package: Available on Nexus registry
                echo 🌐 Production: Local server + root app available on Nexus registry
            ) else (
                echo 📖 Development: Local server loading microfrontends from Nexus registry
            )
        )
        if "%MODE%"=="github" (
            echo 🔍 DEBUG: GitHub mode - ENV=%ENV%, GITHUB_USERNAME=%GITHUB_USERNAME%
            echo 🚀 GitHub mode: Deploying all microfrontends to GitHub Pages
            echo 🔍 DEBUG: Running GitHub deployment via npm scripts
            REM Deploy each microfrontend using npm scripts
            call npm run deploy:github:auth
            call npm run deploy:github:layout
            call npm run deploy:github:home
            call npm run deploy:github:angular
            call npm run deploy:github:vue
            call npm run deploy:github:react
            call npm run deploy:github:vanilla
            call npm run deploy:github:webcomponents
            call npm run deploy:github:typescript
            call npm run deploy:github:jquery
            call npm run deploy:github:svelte
            call npm run deploy:github:root
            if errorlevel 1 (
                echo ❌ GitHub deployment failed
                exit /b 1
            )
            echo ✅ GitHub deployment complete!
            if "%ENV%"=="prod" (
                echo 🌍 Public GitHub Pages available
            )
        )
        if "%MODE%"=="aws" (
            echo 🔍 DEBUG: AWS mode - ENV=%ENV%, S3_BUCKET=%S3_BUCKET%, AWS_REGION=%AWS_REGION%
            echo 🚀 AWS mode: Deploying all microfrontends to S3
            echo 🔍 DEBUG: Running npm run deploy:s3:%ENV%
            set SKIP_BUILD=true
            call npm run deploy:s3:%ENV%
            if errorlevel 1 (
                echo ❌ S3 deployment failed
                exit /b 1
            )
            echo ✅ S3 deployment complete!
            if "%ENV%"=="prod" (
                echo 🌍 Public S3 Website available
            )
        )
        echo.
        echo Press Ctrl+C to stop
        if "%MODE%"=="npm" (
            call npm run serve:npm
        ) else (
            call npm run serve:root -- --env.mode=%MODE%
        )
    )
)