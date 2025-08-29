@echo off
REM Demo Microfrontends Launcher Script
REM Usage: run.bat [mode] [environment]
REM Mode: local (default), npm, nexus, github
REM Environment: dev (default), prod
REM Examples:
REM   run.bat local dev    - Full development environment
REM   run.bat local prod   - Production build locally
REM   run.bat npm prod     - NPM packages with production build
REM   run.bat github dev   - GitHub Pages with development build

set MODE=%1
set ENV=%2
if "%MODE%"=="" set MODE=local
if "%ENV%"=="" set ENV=dev

echo Setting Node.js version...
nvm use 22.18.0

set NODE_OPTIONS=--openssl-legacy-provider

echo Starting Demo Microfrontends Application in %MODE% mode (%ENV% environment)...

echo 📦 Installing root dependencies...
npm install

echo Cleaning all applications...
npm cache clean --force
npm run clean

echo Installing all dependencies...
npm run install:all

if "%ENV%"=="prod" (
    echo Building all applications for production...
    npm run build:prod
) else (
    echo Building all applications for development...
    npm run build:dev
)

if "%MODE%"=="local" (
    if "%ENV%"=="prod" (
        echo Starting production server...
        echo Main application: http://localhost:8080
        echo.
        echo Press Ctrl+C to stop
        npm start
    ) else (
        echo Starting all microfrontends...
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
        npm run dev:all
    )
) else (
    if "%ENV%"=="prod" (
        echo Starting production server...
        echo Main application: http://localhost:8080?mode=%MODE%
        echo.
        echo Press Ctrl+C to stop
        npm start
    ) else (
        echo Starting development server...
        echo Main application: http://localhost:8080?mode=%MODE%
        echo.
        if "%MODE%"=="npm" (
            echo Using NPM packages for microfrontends
        ) else if "%MODE%"=="nexus" (
            echo Using Nexus private registry for microfrontends
        ) else if "%MODE%"=="github" (
            echo Using GitHub Pages for microfrontends
        )
        echo.
        echo Press Ctrl+C to stop
        npm run serve:root
    )
)