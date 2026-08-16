@echo off
setlocal
title Ananta Server - Minimal Test

echo ============================================
echo  AnantaTestGameServer - Minimal Test
echo ============================================
echo.

cd /d "%~dp0"

:: Check .NET SDK
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] .NET SDK nao encontrado. Instale o .NET SDK.
    pause
    exit /b 1
)

:: Restore + Build
echo Restaurando dependencias...
dotnet restore server\AnantaServer.sln
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao restaurar dependencias.
    pause
    exit /b 1
)

echo.
echo Compilando o projeto...
dotnet build server\Ananta.App\Ananta.App.csproj -c Release
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao compilar o projeto.
    pause
    exit /b 1
)

echo.
echo Build OK!
echo.

:: Copy minimal config
echo Configurando servidor minimal...
copy /Y server\Ananta.App\configs\server_config_minimal.json server\Ananta.App\bin\Release\net8.0\configs\server_config.json >nul 2>&1

echo.
echo Iniciando servidor minimal (porta 5200 apenas)...
echo.
cd server\Ananta.App\bin\Release\net8.0
Ananta.App.exe

echo.
echo ============================================
echo  Servidor encerrado.
echo ============================================
pause
