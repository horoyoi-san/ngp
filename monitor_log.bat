@echo off
echo Waiting for debug.log to be created...
echo.

:wait
if not exist "logs\debug.log" (
    timeout /t 1 /nobreak >nul
    goto wait
)

echo File found! Monitoring debug.log in real-time...
echo Press Ctrl+C to stop
echo.

powershell -Command "Get-Content 'logs\debug.log' -Wait -Tail 20"
