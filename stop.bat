@echo off
echo Stopping Demo Microfrontends Applications...

echo Killing processes on ports 8080, 4201-4206...

for %%p in (8080 4201 4202 4203 4204 4205 4206) do (
    for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%%p') do (
        if not "%%a"=="" (
            echo Killing process %%a on port %%p
            taskkill /f /pid %%a >nul 2>&1
        )
    )
)

echo All microfrontend applications stopped
pause