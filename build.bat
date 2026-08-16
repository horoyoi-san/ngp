@echo off
setlocal
title Ananta Server - Build

echo ============================================
echo  AnantaTestGameServer - Build / Recompilacao
echo ============================================
echo.

cd /d "%~dp0"

:: ── Check .NET SDK ──
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] .NET SDK nao encontrado. Instale o .NET 8.0 SDK.
    echo Download: https://dotnet.microsoft.com/download
    echo.
    pause
    exit /b 1
)

:: ── Check .NET version ──
for /f "tokens=*" %%i in ('dotnet --version 2^>^&1') do set DOTNET_VER=%%i
echo [INFO] .NET SDK versao: %DOTNET_VER%
echo.

:: ── Check solution ──
if not exist "server\AnantaServer.sln" (
    echo [ERRO] AnantaServer.sln nao encontrado em server\
    pause
    exit /b 1
)

:: ── Clean ──
echo Limpando build anterior...
dotnet clean server\AnantaServer.sln -c Release
if %errorlevel% neq 0 (
    echo [AVISO] Falha ao limpar build anterior (pode ser ignorado)
)
echo.

:: ── Restore ──
echo Restaurando dependencias...
dotnet restore server\AnantaServer.sln
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao restaurar dependencias.
    pause
    exit /b 1
)
echo.

:: ── Build ──
echo Compilando projeto (Release)...
dotnet build server\Ananta.App\Ananta.App.csproj -c Release
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao compilar o projeto.
    pause
    exit /b 1
)

echo.
echo ============================================
echo  Build concluido com sucesso!
echo  Executavel: server\Ananta.App\bin\Release\net8.0\Ananta.App.exe
echo ============================================
echo.
pause
