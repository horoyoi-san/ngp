@echo off
chcp 65001 >nul
title Ananta Private Server (Rust)
color 0C

echo ======================================================================
echo          ANANTA / PROJECT MUGEN (LX6) PRIVATE SERVER - RUST
echo ======================================================================
echo.

cd /d "%~dp0"

if exist "target\release\server_rust.exe" (
    echo [*] Running precompiled Rust binary...
    echo.
    target\release\server_rust.exe
) else (
    where cargo >nul 2>nul
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Cargo / Rust not found! Please make sure cargo is in PATH.
        pause
        exit /b 1
    )
    echo [*] Compiling and running with Cargo...
    echo.
    cargo run --release
)

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Server exited with an error.
    pause
)
