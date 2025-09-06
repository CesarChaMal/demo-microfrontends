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
            echo 🔍 DEBUG: NPM mode - ENV=%ENV%, NPM_TOKEN=SET
            
            REM Switch to NPM .npmrc configuration
            echo 🔄 Switching to NPM .npmrc configuration...
            if exist ".npmrc" copy ".npmrc" ".npmrc.backup" >nul
            copy ".npmrc.npm" ".npmrc" >nul
            
            REM Check if user is logged in to NPM
            npm whoami >nul 2>&1
            if errorlevel 1 (
                echo ❌ Error: Not logged in to NPM. Run 'npm login' first
                exit /b 1
            )
            
            REM Build root application with NPM mode configuration
            echo 🔨 Building root application for NPM deployment...
            call npm run build:root:npm
            if errorlevel 1 exit /b 1
            
            REM Publish packages
            echo 📦 NPM mode: Publishing packages to NPM registry
            if "%ENV%"=="prod" (
                echo 🔍 DEBUG: Running npm run publish:npm:prod
                set FROM_RUN_SCRIPT=true
                call npm run publish:npm:prod
                if errorlevel 1 (
                    echo ❌ NPM publishing failed
                    exit /b 1
                )
                echo ✅ NPM publishing successful
                echo 🌍 Public NPM Package: https://www.npmjs.com/package/@cesarchamal/single-spa-root
                echo 🌐 Production: Local server + root app available on NPM registry
            ) else (
                echo 🔍 DEBUG: Running npm run publish:npm:dev
                set FROM_RUN_SCRIPT=true
                call npm run publish:npm:dev
                if errorlevel 1 (
                    echo ❌ NPM publishing failed
                    exit /b 1
                )
                echo ✅ NPM publishing successful
                echo 📖 Development: Local server loading microfrontends from NPM registry
            )
            
            REM Switch to NPM mode and start server
            echo 📦 Switching to NPM mode and starting server...
            call npm run mode:npm
            if errorlevel 1 exit /b 1
            
            echo ✅ NPM mode setup complete!
            echo 🌐 Main application: http://localhost:8080?mode=npm
        )
        if "%MODE%"=="nexus" (
            echo 🔍 DEBUG: Nexus mode - ENV=%ENV%, NEXUS_REGISTRY=SET
            
            REM Switch to Nexus .npmrc configuration
            echo 🔄 Switching to Nexus .npmrc configuration...
            if exist ".npmrc" copy ".npmrc" ".npmrc.backup" >nul
            copy ".npmrc.nexus" ".npmrc" >nul
            
            REM Build root application with Nexus mode configuration
            echo 🔨 Building root application for Nexus deployment...
            call npm run build:root:nexus
            if errorlevel 1 exit /b 1
            
            REM Publish packages
            echo 📦 Nexus mode: Publishing packages to Nexus registry
            if "%ENV%"=="prod" (
                echo 🔍 DEBUG: Running npm run publish:nexus:prod
                set FROM_RUN_SCRIPT=true
                call npm run publish:nexus:prod
                if errorlevel 1 (
                    echo ❌ Nexus publishing failed
                    exit /b 1
                )
                echo ✅ Nexus publishing successful
                echo 🌍 Public Nexus Package: Available on Nexus registry
                echo 🌐 Production: Local server + root app available on Nexus registry
            ) else (
                echo 🔍 DEBUG: Running npm run publish:nexus:dev
                set FROM_RUN_SCRIPT=true
                call npm run publish:nexus:dev
                if errorlevel 1 (
                    echo ❌ Nexus publishing failed
                    exit /b 1
                )
                echo ✅ Nexus publishing successful
                echo 📖 Development: Local server loading microfrontends from Nexus registry
            )
            
            REM Switch to Nexus mode and start server
            echo 📦 Switching to Nexus mode and starting server...
            call npm run mode:nexus
            if errorlevel 1 exit /b 1
            
            echo ✅ Nexus mode setup complete!
            echo 🌐 Main application: http://localhost:8080?mode=nexus
        )
        if "%MODE%"=="github" (
            echo 🔍 DEBUG: GitHub mode - ENV=%ENV%, GITHUB_API_TOKEN=SET, GITHUB_USERNAME=%GITHUB_USERNAME%
            
            if "%ENV%"=="prod" (
                REM Production mode: Create repositories and deploy
                echo 🚀 GitHub Production: Creating repositories and deploying to GitHub Pages
                
                REM Build root application with GitHub mode configuration
                echo 🔨 Building root application for GitHub deployment...
                call npm run build:root:github
                if errorlevel 1 exit /b 1
                
                REM Deploy each microfrontend using npm scripts
                echo 📤 Deploying microfrontends to GitHub Pages...
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
                call npm run deploy:github:main
                if errorlevel 1 (
                    echo ❌ GitHub deployment failed
                    exit /b 1
                )
                echo ✅ All deployments complete!
                echo 🌍 Public GitHub Pages:
                echo    Root App: https://%GITHUB_USERNAME%.github.io/single-spa-root/
                echo    Documentation: https://%GITHUB_USERNAME%.github.io/demo-microfrontends/
                echo 🌐 Production: Both local server AND public GitHub Pages available
            ) else (
                REM Development mode: Read from existing GitHub Pages
                echo 📖 GitHub Development: Reading from existing GitHub Pages (no deployment)
                echo 🔍 Assumes repositories already exist and are deployed
                
                REM Build root application with GitHub mode configuration
                echo 🔨 Building root application for GitHub mode...
                call npm run build:root:github
                if errorlevel 1 exit /b 1
            )
        )
        if "%MODE%"=="aws" (
            echo 🔍 DEBUG: AWS mode - ENV=%ENV%, S3_BUCKET=%S3_BUCKET%, AWS_REGION=%AWS_REGION%, ORG_NAME=%ORG_NAME%
            
            REM Check prerequisites
            if "%S3_BUCKET%"=="" (
                echo ❌ Error: S3_BUCKET not set in .env
                exit /b 1
            )
            if "%AWS_REGION%"=="" (
                echo ❌ Error: AWS_REGION not set in .env
                exit /b 1
            )
            if "%ORG_NAME%"=="" (
                echo ❌ Error: ORG_NAME not set in .env
                exit /b 1
            )
            
            REM Build root application with AWS mode configuration
            echo 🔨 Building root application for AWS deployment...
            if "%ENV%"=="dev" (
                call npm run build:root:aws
            ) else (
                call npm run build:root:aws
                call npm run build:root:aws:prod
            )
            if errorlevel 1 exit /b 1
            
            REM Deploy to S3
            echo 🚀 AWS mode: Deploying all microfrontends to S3
            set SKIP_BUILD=true
            call npm run deploy:s3:%ENV%
            if errorlevel 1 (
                echo ❌ S3 deployment failed
                exit /b 1
            )
            
            echo ✅ S3 deployment complete!
            if "%ENV%"=="prod" (
                echo 🌍 Production S3 Website: http://%S3_BUCKET%.s3-website-%AWS_REGION%.amazonaws.com
                echo 🌍 Production: Both local server AND public website available
                echo 🔗 Direct S3 Link: http://%S3_BUCKET%.s3-website-%AWS_REGION%.amazonaws.com/index.html?mode=aws
            ) else (
                echo 📖 Development: Local server with S3 deployment
                echo 🔗 S3 Development Site: http://%S3_BUCKET%.s3-website-%AWS_REGION%.amazonaws.com/index.html?mode=aws
            )
            echo 🌐 Main application: http://localhost:8080?mode=aws
        )
        if "%MODE%"=="github" (
            echo 🌐 Main application: http://localhost:8080?mode=github
            echo 🔍 DEBUG: GitHub username: %GITHUB_USERNAME%
        )
        echo.
        echo Press Ctrl+C to stop
        if "%MODE%"=="npm" (
            call npm run serve:npm
        ) else if "%MODE%"=="nexus" (
            call npm run serve:nexus
        ) else (
            call npm run serve:root -- --env.mode=%MODE%
        )
    )
)