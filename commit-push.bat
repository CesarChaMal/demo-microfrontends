@echo off

REM Use provided message or default to "Update"
set MESSAGE=%1
if "%MESSAGE%"=="" set MESSAGE=Update

REM Use provided folder or current directory
set FOLDER=%2
if "%FOLDER%"=="" set FOLDER=.

echo Committing and pushing changes...
echo Message: %MESSAGE%
echo Folder: %FOLDER%
echo.

cd /d "%FOLDER%"
git add .
git commit -m "%MESSAGE%"

git push

echo.
echo Done!