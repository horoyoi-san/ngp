@echo off
chcp 65001 >nul
title Ananta / Project Mugen Private Server
color 0B

echo ======================================================================
echo          ANANTA / PROJECT MUGEN (LX6) PRIVATE SERVER
echo ======================================================================
echo.

where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Python not found! Please make sure Python is installed and in PATH.
    echo.
    pause
    exit /b 1
)

cd /d "%~dp0"
echo [*] Starting Private Server...
echo.
python main.py

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Server exited with an error.
    pause
)
