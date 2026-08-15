@echo off
echo **********************************************
echo *     Diagnostico - Ananta Gateway Control     *
echo **********************************************
echo.
echo Este script realiza uma verificacao completa
echo do ambiente e identifica possiveis problemas.
echo.

echo 1. Verificando Node.js...
node --version >nul 2>&1
if %errorlevel% equ 0 (
    echo    [OK] Node.js instalado
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo    Versao: !NODE_VERSION!
) else (
    echo    [ERRO] Node.js nao encontrado
    echo    Por favor, instale o Node.js
)
echo.

echo 2. Verificando npm...
npm --version >nul 2>&1
if %errorlevel% equ 0 (
    echo    [OK] npm instalado
    for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
    echo    Versao: !NPM_VERSION!
) else (
    echo    [ERRO] npm nao encontrado
    echo    Por favor, instale o Node.js (que inclui npm)
)
echo.

echo 3. Verificando arquivos essenciais...
if exist "package.json" (echo    [OK] package.json encontrado) else (echo    [ERRO] package.json nao encontrado)
if exist "node_modules" (echo    [OK] node_modules encontrado) else (echo    [AVISO] node_modules nao encontrado - execute npm install)
if exist "src\pages\index.tsx" (echo    [OK] index.tsx encontrado) else (echo    [ERRO] index.tsx nao encontrado)
if exist "src\pages\GameCommands.tsx" (echo    [OK] GameCommands.tsx encontrado) else (echo    [ERRO] GameCommands.tsx nao encontrado)
if exist "src\layouts\index.tsx" (echo    [OK] Layout encontrado) else (echo    [ERRO] Layout nao encontrado)
echo.

echo 4. Verificando portas comuns...
echo    Verificando porta 8000 (desenvolvimento)...
netstat -an | find "8000" >nul
if %errorlevel% equ 0 (echo    [AVISO] Porta 8000 esta em uso) else (echo    [OK] Porta 8000 disponivel)

echo    Verificando porta 8080 (producao)...
netstat -an | find "8080" >nul
if %errorlevel% equ 0 (echo    [AVISO] Porta 8080 esta em uso) else (echo    [OK] Porta 8080 disponivel)

echo    Verificando porta 9011 (servidor do jogo)...
netstat -an | find "9011" >nul
if %errorlevel% equ 0 (echo    [OK] Porta 9011 esta em uso - provavelmente servidor do jogo esta rodando) else (echo    [AVISO] Porta 9011 nao esta em uso - verifique se o servidor do jogo esta rodando)
echo.

echo 5. Verificando conexao com servidor do jogo...
echo    Tentando conectar ao servidor do jogo na porta 9011...
ping -n 1 127.0.0.1 >nul
echo    Teste de conexao realizado. Se o servidor do jogo estiver rodando,
echo    o gateway control deve conseguir se comunicar com ele na porta 9011.
echo.

echo 6. Recomendacoes:
echo    - Se o node_modules nao foi encontrado, execute install_deps.cmd
echo    - Se houver problemas de conexao, verifique se o servidor do jogo esta rodando
echo    - Se as portas 8000 ou 8080 estiverem em uso, considere fechar outros servidores
echo    - Para iniciar o gateway control, execute run_gateway.cmd
echo    - Para obter ajuda sobre os scripts, execute help_gateway.cmd
echo.

echo **********************************************
echo *  Diagnostico concluido em %date% as %time%  *
echo **********************************************
echo.
echo Pressione qualquer tecla para continuar...
pause >nul