@echo off
chcp 65001 >nul
title Ananta Private Server (Node.js)
color 0E

echo ======================================================================
echo       ANANTA / PROJECT MUGEN (LX6) PRIVATE SERVER - NODE.JS
echo ======================================================================
echo.

where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Node.js not found! Please make sure node is in PATH.
    pause
    exit /b 1
)

cd /d "%~dp0"
echo [*] Launching Node.js Server...
echo.
node main.js

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Server exited with an error.
    pause
)
