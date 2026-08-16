
@echo off
setlocal

REM Verifica se está sendo executado com privilégios de administrador
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Executando com privilegios de administrador...
) else (
    echo ============================================
    echo  Este script precisa ser executado como Administrador!
    echo ============================================
    echo.
    echo  Clique com botao DIREITO neste arquivo e selecione:
    echo    "Executar como administrador"
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================
echo  Configurando Proxy do Ananta
echo ============================================
echo.

REM Configura o Execution Policy temporariamente
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"

REM Executa o script de configuração do proxy
echo [1/2] Executando setup (certificado + hosts)...
powershell -ExecutionPolicy Bypass -File "%~dp0SETUP_PROXY_AS_ADMIN.ps1"

if %errorlevel% neq 0 (
    echo.
    echo [ERRO] Falha ao executar setup do proxy.
    pause
    exit /b 1
)

echo.
echo [2/2] Iniciando o proxy...
echo.

REM Inicia o proxy
powershell -ExecutionPolicy Bypass -File "%~dp0Start-Proxy.ps1"

pause
