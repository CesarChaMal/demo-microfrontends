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

echo 🚀 Starting Demo Microfrontends Application in %MODE% mode (%ENV% environment)...

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
    if "%ENV%"=="prod" (
        echo 🌐 Starting production server...
        echo Main application: http://localhost:8080
        echo.
        echo Press Ctrl+C to stop
        call npm start
    ) else (
        echo 🌐 Starting all microfrontends...
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
            echo 🚀 Deploying to S3 first...
            call deploy-s3.bat prod
            if errorlevel 1 exit /b 1
            echo.
            echo 🌐 Starting production server...
            echo Main application: http://localhost:8080?mode=%MODE%
            echo.
            echo 🌍 Public S3 Website (deployed):
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
        if "%MODE%"=="npm" echo Using NPM packages for microfrontends
        if "%MODE%"=="nexus" echo Using Nexus private registry for microfrontends
        if "%MODE%"=="github" (
            echo Using GitHub Pages for microfrontends
            if "%ENV%"=="prod" (
                echo 🔧 Starting GitHub repository creation server for production...
                start /b npm run serve:github
                echo 📡 GitHub API server: http://localhost:3001
                timeout /t 2 /nobreak >nul
            ) else (
                echo 📖 Development mode: Reading from existing GitHub Pages
            )
        )
        if "%MODE%"=="aws" echo Using AWS S3 for microfrontends
        echo.
        echo Press Ctrl+C to stop
        call npm run serve:root -- --env.mode=%MODE%
    )
)