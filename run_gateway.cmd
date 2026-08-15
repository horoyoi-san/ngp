@echo off
echo **********************************************
echo *       Ananta Gateway Control - v1.0        *
echo **********************************************
echo.
echo Este script inicia o Ananta Gateway Control
echo em modo de desenvolvimento na porta 8000.
echo.
echo Acesse a aplicacao web em:
echo http://localhost:8000
echo.
echo Paginas disponiveis:
echo - Home:          http://localhost:8000/
echo - Comandos:      http://localhost:8000/game-commands
echo - Sobre:         http://localhost:8000/about
echo.
REM Verifique se o Node.js esta instalado
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Erro: Node.js nao encontrado.
    echo Por favor, instale o Node.js antes de continuar.
    pause
    exit /b 1
)

REM Verifique se o npm esta instalado
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Erro: npm nao encontrado.
    echo Por favor, instale o Node.js (que inclui npm) antes de continuar.
    pause
    exit /b 1
)

echo.
echo Iniciando o Ananta Gateway Control...
echo.

REM Instalar dependencias se necessario
echo Verificando dependencias...
call npm install --silent
if %errorlevel% neq 0 (
    echo Erro ao instalar dependencias.
    pause
    exit /b 1
)

echo.
echo Dependencias verificadas.
echo.
echo Iniciando o servidor de desenvolvimento na porta 8000...
echo Para parar o servidor, feche esta janela ou pressione Ctrl+C
echo.

REM Iniciar o servidor de desenvolvimento
npm run dev -- --port=8000

echo.
echo Servidor encerrado.
pause