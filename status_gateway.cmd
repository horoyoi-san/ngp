@echo off
echo **********************************************
echo *  Ananta Gateway Control - Status v1.0       *
echo **********************************************
echo.

echo Verificando o status do Ananta Gateway Control...
echo.

REM Verificar se o Node.js esta instalado
echo 1. Verificando Node.js...
node --version >nul 2>&1
if %errorlevel% equ 0 (
    echo    [OK] Node.js instalado
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo    Versao: !NODE_VERSION!
) else (
    echo    [ERRO] Node.js nao encontrado
)
echo.

REM Verificar se o npm esta instalado
echo 2. Verificando npm...
npm --version >nul 2>&1
if %errorlevel% equ 0 (
    echo    [OK] npm instalado
    for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
    echo    Versao: !NPM_VERSION!
) else (
    echo    [ERRO] npm nao encontrado
)
echo.

REM Verificar se o diretorio dist existe
echo 3. Verificando build...
if exist "dist" (
    echo    [OK] Build encontrado
    dir /ad dist >nul
    echo    Arquivos disponiveis em /dist
) else (
    echo    [INFO] Build nao encontrado
    echo    Execute build_gateway.cmd para criar uma build
)
echo.

REM Verificar se o package.json existe
echo 4. Verificando configuracao...
if exist "package.json" (
    echo    [OK] package.json encontrado
) else (
    echo    [ERRO] package.json nao encontrado
)
echo.

REM Verificar se os arquivos principais existem
echo 5. Verificando arquivos principais...
if exist "src\layouts\index.tsx" (
    echo    [OK] Layout principal encontrado
) else (
    echo    [ERRO] Layout principal nao encontrado
)

if exist "src\pages\index.tsx" (
    echo    [OK] Pagina inicial encontrada
) else (
    echo    [ERRO] Pagina inicial nao encontrada
)

if exist "src\pages\GameCommands.tsx" (
    echo    [OK] Pagina de comandos encontrada
) else (
    echo    [ERRO] Pagina de comandos nao encontrada
)
echo.

echo 6. Scripts disponiveis:
if exist "run_gateway.cmd" ( echo    - run_gateway.cmd) else ( echo    - run_gateway.cmd (NAO ENCONTRADO))
if exist "build_gateway.cmd" ( echo    - build_gateway.cmd) else ( echo    - build_gateway.cmd (NAO ENCONTRADO))
if exist "serve_gateway.cmd" ( echo    - serve_gateway.cmd) else ( echo    - serve_gateway.cmd (NAO ENCONTRADO))
if exist "clean_gateway.cmd" ( echo    - clean_gateway.cmd) else ( echo    - clean_gateway.cmd (NAO ENCONTRADO))
if exist "help_gateway.cmd" ( echo    - help_gateway.cmd) else ( echo    - help_gateway.cmd (NAO ENCONTRADO))
if exist "status_gateway.cmd" ( echo    - status_gateway.cmd) else ( echo    - status_gateway.cmd (NAO ENCONTRADO))
if exist "quick_start.cmd" ( echo    - quick_start.cmd) else ( echo    - quick_start.cmd (NAO ENCONTRADO))
if exist "safe_start.cmd" ( echo    - safe_start.cmd) else ( echo    - safe_start.cmd (NAO ENCONTRADO))
if exist "install_deps.cmd" ( echo    - install_deps.cmd) else ( echo    - install_deps.cmd (NAO ENCONTRADO))
if exist "setup_and_run.cmd" ( echo    - setup_and_run.cmd) else ( echo    - setup_and_run.cmd (NAO ENCONTRADO))
if exist "diagnose.cmd" ( echo    - diagnose.cmd) else ( echo    - diagnose.cmd (NAO ENCONTRADO))
if exist "backup.cmd" ( echo    - backup.cmd) else ( echo    - backup.cmd (NAO ENCONTRADO))
if exist "restore.cmd" ( echo    - restore.cmd) else ( echo    - restore.cmd (NAO ENCONTRADO))
if exist "check_port.cmd" ( echo    - check_port.cmd) else ( echo    - check_port.cmd (NAO ENCONTRADO))
echo.

echo **********************************************
echo *      Status verificado em %date% as %time%   *
echo **********************************************
echo.
echo Pressione qualquer tecla para continuar...
pause >nul