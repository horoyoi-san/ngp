@echo off
chcp 65001 >nul
title Ananta Private Server (.NET 9 C#)
color 0A

echo ======================================================================
echo       ANANTA / PROJECT MUGEN (LX6) PRIVATE SERVER - .NET 9 (C#)
echo ======================================================================
echo.

cd /d "%~dp0"

if exist "publish\AnantaServer.exe" (
    echo [*] Running precompiled C# executable...
    echo.
    publish\AnantaServer.exe
) else (
    where dotnet >nul 2>nul
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] .NET SDK not found! Please make sure dotnet is in PATH.
        pause
        exit /b 1
    )
    echo [*] Launching C# Server with dotnet run...
    echo.
    dotnet run --no-restore
)

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Server exited with an error.
    pause
)
