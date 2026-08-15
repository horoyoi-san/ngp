@echo off
echo **********************************************
echo *   Ananta Gateway Control - Clean v1.0       *
echo **********************************************
echo.
echo Este script remove arquivos temporarios e
echo diretorios de build da aplicacao.
echo.
set /p confirm=Tem certeza que deseja continuar? (S/N): 
if /i not "%confirm%"=="S" (
    echo Operacao cancelada.
    pause
    exit /b 0
)

echo.
echo Removendo arquivos temporarios...
echo.

REM Remover diretorios de build e cache
if exist "dist" (
    echo Removendo diretorio dist...
    rmdir /s /q dist
)

if exist "node_modules" (
    echo Removendo diretorio node_modules...
    rmdir /s /q node_modules
)

if exist "src\.umi" (
    echo Removendo diretorio src\.umi...
    rmdir /s /q "src\.umi"
)

if exist "src\.umi-production" (
    echo Removendo diretorio src\.umi-production...
    rmdir /s /q "src\.umi-production"
)

REM Limpar cache do npm
echo Limpando cache do npm...
call npm cache clean --force

echo.
echo Limpeza concluida.
echo.
echo Voce precisara executar 'npm install' novamente
echo antes de executar qualquer script que dependa
echo das dependencias do projeto.
echo.
echo Pressione qualquer tecla para continuar...
pause >nul