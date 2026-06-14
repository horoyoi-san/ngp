
@echo off
setlocal

REM Verifica se o script está sendo executado com privilégios de administrador
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Executando com privilégios de administrador...
) else (
    echo Este script precisa ser executado como administrador.
    echo Clique com o botão direito no arquivo e selecione "Executar como administrador".
    pause
    exit /b 1
)

REM Configura o Execution Policy temporariamente para permitir a execução de scripts
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"

REM Executa o script de configuração do proxy
echo Executando SETUP_PROXY_AS_ADMIN.ps1...
powershell -ExecutionPolicy Bypass -File "%~dp0SETUP_PROXY_AS_ADMIN.ps1"

if %errorlevel% neq 0 (
    echo Erro ao executar SETUP_PROXY_AS_ADMIN.ps1
    pause
    exit /b 1
)

echo Setup concluido. Pressione qualquer tecla para iniciar o proxy...
pause

REM Inicia o proxy
echo Iniciando o proxy...
powershell -ExecutionPolicy Bypass -File "%~dp0Start-Proxy.ps1"

pause