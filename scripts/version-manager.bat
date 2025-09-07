@echo off
setlocal enabledelayedexpansion

REM Version Manager for Demo Microfrontends (Windows)
REM Usage: version-manager.bat [command] [args]

set COMMAND=%1
set ARG1=%2
set ARG2=%3

if "%COMMAND%"=="" (
    echo.
    echo 📦 Version Manager for Demo Microfrontends
    echo.
    echo 🔄 Integration with Publishing:
    echo   publish-all.bat patch                          - Auto-bump patch + publish all
    echo   publish-all.bat minor                          - Auto-bump minor + publish all
    echo   publish-all.bat major                          - Auto-bump major + publish all
    echo.
    echo 📋 Manual Version Management:
    echo   version-manager.bat bump [patch^|minor^|major]  - Increment version for all packages
    echo   version-manager.bat set ^<version^>             - Set specific version for all packages
    echo   version-manager.bat reset [version]             - Reset all packages to base version (default: 0.1.0)
    echo   version-manager.bat current                     - Show current versions
    echo   version-manager.bat clean                       - Remove _trigger fields
    echo.
    echo 💡 Version Bump Examples:
    echo   version-manager.bat bump patch                  - 0.1.0 → 0.1.1 (bug fixes)
    echo   version-manager.bat bump minor                  - 0.1.0 → 0.2.0 (new features)
    echo   version-manager.bat bump major                  - 0.1.0 → 1.0.0 (breaking changes)
    echo   version-manager.bat set 1.2.3                   - Set all to 1.2.3 (specific version)
    echo   version-manager.bat reset                       - Reset all to 0.1.0 (base version)
    echo   version-manager.bat reset 1.0.0                 - Reset all to 1.0.0 (custom base)
    echo.
    echo 🔍 Information Commands:
    echo   version-manager.bat current                     - Show all package versions
    echo   version-manager.bat reset                       - Reset all to base version
    echo   version-manager.bat clean                       - Clean _trigger fields
    echo.
    echo 🎯 Complete Workflow Examples:
    echo   # Quick patch release:
    echo   publish-all.bat patch
    echo.
    echo   # Manual version then publish:
    echo   version-manager.bat bump minor
    echo   publish-all.bat
    echo.
    echo   # Check versions before publishing:
    echo   version-manager.bat current
    echo   publish-all.bat patch
    echo.
    echo 📦 What Gets Updated (13 packages total):
    echo   - demo-microfrontends (main package)
    echo   - @cesarchamal/single-spa-root
    echo   - @cesarchamal/single-spa-auth-app
    echo   - @cesarchamal/single-spa-layout-app
    echo   - @cesarchamal/single-spa-home-app
    echo   - @cesarchamal/single-spa-angular-app
    echo   - @cesarchamal/single-spa-vue-app
    echo   - @cesarchamal/single-spa-react-app
    echo   - @cesarchamal/single-spa-vanilla-app
    echo   - @cesarchamal/single-spa-webcomponents-app
    echo   - @cesarchamal/single-spa-typescript-app
    echo   - @cesarchamal/single-spa-jquery-app
    echo   - @cesarchamal/single-spa-svelte-app
    echo.
    exit /b 1
)

REM Call the Node.js version manager
node version-manager.js %COMMAND% %ARG1% %ARG2%
exit /b %errorlevel%