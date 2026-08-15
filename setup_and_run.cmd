@echo off
echo **********************************************
echo *  Setup and Run - Ananta Gateway Control     *
echo **********************************************
echo.
echo Este script instala as dependencias e inicia
echo o servidor de desenvolvimento em um unico
echo processo.
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

REM Navegar ate o diretorio do gateway control
cd /d "d:\AnantaTestGameServer\AnantaTestGameServer 2.0\ananta-gateway-control"

REM Instalar http-server globalmente se ainda nao estiver instalado
echo 3. Verificando http-server...
npm list -g http-server >nul 2>&1
if %errorlevel% neq 0 (
    echo    http-server nao encontrado. Instalando...
    npm install -g http-server
    if %errorlevel% equ 0 (
        echo    [OK] http-server instalado com sucesso
    ) else (
        echo    [AVISO] Falha ao instalar http-server (talvez nao seja necessario agora)
    )
)
echo.

REM Instalar dependencias locais
echo 4. Instalando dependencias locais...
call npm install
if %errorlevel% equ 0 (
    echo    [OK] Dependencias locais instaladas com sucesso
) else (
    echo    [ERRO] Falha ao instalar dependencias locais
    pause
    exit /b 1
)
echo.

REM Verificar se a porta 8000 esta em uso
echo 5. Verificando porta 8000...
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
del temp_port_check.txt >nul 2>&1
echo.

echo 6. Iniciando o servidor de desenvolvimento...
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