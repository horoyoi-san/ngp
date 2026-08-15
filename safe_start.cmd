@echo off
echo **********************************************
echo *   Safe Start - Ananta Gateway Control       *
echo **********************************************
echo.
echo Este script verifica as portas e inicia o
echo servidor de desenvolvimento com seguranca.
echo.

REM Verificar se a porta 8000 esta em uso
netstat -an | find "8000" > temp_port_check.txt
if %errorlevel% equ 0 (
    echo AVISO: A porta 8000 ja esta em uso.
    echo.
    type temp_port_check.txt
    echo.
    set /p confirm=Continuar mesmo assim? (S/N): 
    if /i not "%confirm%"=="S" (
        echo Operacao cancelada.
        del temp_port_check.txt >nul 2>&1
        pause
        exit /b 0
    )
) else (
    echo Porta 8000 esta disponivel.
)

REM Limpar arquivo temporario
del temp_port_check.txt >nul 2>&1

REM Verificar se o Node.js esta instalado
echo.
echo Verificando Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Erro: Node.js nao encontrado.
    echo Por favor, instale o Node.js antes de continuar.
    pause
    exit /b 1
)

REM Verificar se o npm esta instalado
echo Verificando npm...
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Erro: npm nao encontrado.
    echo Por favor, instale o Node.js (que inclui npm) antes de continuar.
    pause
    exit /b 1
)

REM Navegar ate o diretorio do gateway control
cd /d "d:\AnantaTestGameServer\AnantaTestGameServer 2.0\ananta-gateway-control"

REM Instalar dependencias se necessario
echo.
echo Verificando dependencias...
call npm install --silent
if %errorlevel% neq 0 (
    echo Erro ao instalar dependencias.
    pause
    exit /b 1
)

echo.
echo Iniciando o servidor de desenvolvimento na porta 8000...
echo Acesse a aplicacao em http://localhost:8000
echo Para parar o servidor, pressione Ctrl+C
echo.

REM Iniciar o servidor de desenvolvimento
call npm run dev -- --port=8000

echo.
echo Servidor encerrado.
echo.
echo Pressione qualquer tecla para continuar...
pause >nul