@echo off
echo **********************************************
echo *     Ananta Gateway Control - Build v1.0    *
echo **********************************************
echo.
echo Este script cria uma build da aplicacao web
echo do Ananta Gateway Control.
echo.
echo A build sera criada no diretorio /dist
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
echo Iniciando processo de build...
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
echo Executando build da aplicacao web...
echo.

REM Executar o build
npm run build

if %errorlevel% equ 0 (
    echo.
    echo Build concluido com sucesso!
    echo Os arquivos estao disponiveis no diretorio /dist
    echo.
    dir dist /s
    echo.
    echo **********************************************
    echo * Build concluido em %date% as %time% *
    echo **********************************************
) else (
    echo.
    echo Erro durante o processo de build.
    echo Verifique os logs acima para mais informacoes.
    echo.
)

pause