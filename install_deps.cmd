@echo off
echo **********************************************
echo *  Instalador de Dependencias - Gateway       *
echo **********************************************
echo.
echo Este script instala as dependencias globais
echo necessarias para o funcionamento do Ananta
echo Gateway Control.
echo.

REM Verificar se o Node.js esta instalado
echo 1. Verificando Node.js...
node --version >nul 2>&1
if %errorlevel% equ 0 (
    echo    [OK] Node.js instalado
) else (
    echo    [ERRO] Node.js nao encontrado
    echo    Por favor, instale o Node.js antes de continuar.
    pause
    exit /b 1
)
echo.

REM Verificar se o npm esta instalado
echo 2. Verificando npm...
npm --version >nul 2>&1
if %errorlevel% equ 0 (
    echo    [OK] npm instalado
) else (
    echo    [ERRO] npm nao encontrado
    echo    Por favor, instale o Node.js (que inclui npm) antes de continuar.
    pause
    exit /b 1
)
echo.

REM Instalar http-server globalmente se ainda nao estiver instalado
echo 3. Verificando http-server...
npm list -g http-server >nul 2>&1
if %errorlevel% neq 0 (
    echo    http-server nao encontrado. Instalando...
    npm install -g http-server
    if %errorlevel% equ 0 (
        echo    [OK] http-server instalado com sucesso
    ) else (
        echo    [ERRO] Falha ao instalar http-server
        pause
        exit /b 1
    )
) else (
    echo    [OK] http-server ja esta instalado
)
echo.

REM Instalar dependencias locais
echo 4. Instalando dependencias locais...
cd /d "d:\AnantaTestGameServer\AnantaTestGameServer 2.0\ananta-gateway-control"
call npm install
if %errorlevel% equ 0 (
    echo    [OK] Dependencias locais instaladas com sucesso
) else (
    echo    [ERRO] Falha ao instalar dependencias locais
    pause
    exit /b 1
)
echo.

echo 5. Verificando dependencias instaladas...
if exist "node_modules" (
    echo    [OK] Diretorio node_modules encontrado
) else (
    echo    [ERRO] Diretorio node_modules nao encontrado
)
echo.

echo **********************************************
echo *  Instalacao concluida em %date% as %time%   *
echo **********************************************
echo.
echo Voce pode agora usar os seguintes comandos:
echo  - run_gateway.cmd: Para iniciar o servidor de desenvolvimento
echo  - build_gateway.cmd: Para criar uma build da aplicacao
echo.
echo Pressione qualquer tecla para continuar...
pause >nul