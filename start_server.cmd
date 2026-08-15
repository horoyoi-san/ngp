@echo off
setlocal

echo Inicializando o AnantaTestGameServer...
echo Diretorio atual: %~dp0

REM Muda para o diretório correto do projeto
cd /d "%~dp0"

REM Verifica se o .NET esta instalado
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Erro: .NET SDK nao encontrado. Por favor, instale o .NET SDK.
    pause
    exit /b 1
)

REM Verifica se o arquivo .csproj existe no diretorio atual
if not exist "AnantaTestGameServer.csproj" (
    echo Arquivo AnantaTestGameServer.csproj nao encontrado neste diretorio.
    REM Tenta encontrar o arquivo .csproj recursivamente
    for /r %%i in (*.csproj) do (
        if exist "%%i" (
            echo Projeto encontrado: %%i
            cd "%%~dpi"
            goto :found_project
        )
    )
    echo Nenhum arquivo .csproj encontrado.
    pause
    exit /b 1
)

:found_project
echo Diretorio do projeto: %CD%

REM Restaura as dependencias do projeto
echo Restaurando dependencias do projeto...
dotnet restore

if %errorlevel% neq 0 (
    echo Erro ao restaurar as dependencias.
    pause
    exit /b 1
)

REM Constroi o projeto
echo Construindo o projeto...
dotnet build --configuration Release

if %errorlevel% neq 0 (
    echo Erro ao construir o projeto.
    pause
    exit /b 1
)

REM Executa o projeto
echo Iniciando o servidor do jogo...
dotnet run --configuration Release

echo Servidor encerrado.
pause