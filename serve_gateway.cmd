@echo off
echo **********************************************
echo *   Ananta Gateway Control - Serve v1.0      *
echo **********************************************
echo.
echo Este script serve a aplicacao web do Ananta
echo Gateway Control a partir dos arquivos buildados.
echo.
echo A aplicacao sera servida em:
echo http://localhost:8080
echo.
echo AVISO: Esta versao serve a aplicacao estatica
echo e nao inclui hot reloading (modo producao).
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

REM Verifique se ha um servidor HTTP disponivel
echo Verificando dependencias...
npm list -g http-server >nul 2>&1
if %errorlevel% neq 0 (
    echo http-server nao encontrado. Instalando...
    npm install -g http-server
    if %errorlevel% neq 0 (
        echo Erro ao instalar http-server.
        echo Voce pode instalar manualmente com: npm install -g http-server
        pause
        exit /b 1
    )
)

REM Verifique se o diretorio dist existe
if not exist "dist" (
    echo Diretorio dist nao encontrado.
    echo Execute o build_gateway.cmd primeiro para criar os arquivos.
    pause
    exit /b 1
)

echo.
echo Iniciando servidor para aplicacao web...
echo Acesse a aplicacao em http://localhost:8080
echo Para parar o servidor, pressione Ctrl+C
echo.

REM Mudar para o diretorio dist e iniciar o servidor
cd dist
http-server -p 8080

echo.
echo Servidor encerrado.
pause