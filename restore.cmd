@echo off
echo **********************************************
echo *        Restauracao - Ananta Gateway        *
echo **********************************************
echo.
echo Este script restaura o estado da aplicacao
echo Ananta Gateway Control a partir de um backup.
echo.

REM Listar backups disponiveis
echo 1. Procurando backups disponiveis...
echo.
dir gateway_backup_* /ad /b
echo.

set /p BACKUP_NAME="Digite o nome do backup que deseja restaurar: "

REM Verificar se o backup existe
if not exist "%BACKUP_NAME%" (
    echo.
    echo ERRO: Backup "%BACKUP_NAME%" nao encontrado.
    echo Verifique o nome e tente novamente.
    pause
    exit /b 1
)

echo.
echo 2. Backup encontrado: %BACKUP_NAME%
echo.

REM Confirmar restauracao
set /p CONFIRM="Tem certeza que deseja restaurar a partir de %BACKUP_NAME%? (S/N): "
if /i not "%CONFIRM%"=="S" (
    echo.
    echo Operacao cancelada.
    pause
    exit /b 0
)

echo.
echo 3. Restaurando arquivos...
echo.

REM Copiar arquivos do backup
copy "%BACKUP_NAME%\package.json" "package.json" >nul
if %errorlevel% equ 0 (echo    [OK] package.json restaurado) else (echo    [ERRO] Falha ao restaurar package.json)

copy "%BACKUP_NAME%\package-lock.json" "package-lock.json" >nul
if %errorlevel% equ 0 (echo    [OK] package-lock.json restaurado) else (echo    [AVISO] package-lock.json nao encontrado no backup)

REM Copiar diretorios
xcopy /s /e /y "%BACKUP_NAME%\src" "src\" >nul
if %errorlevel% equ 0 (echo    [OK] Diretorio src restaurado) else (echo    [ERRO] Falha ao restaurar diretorio src)

xcopy /s /e /y "%BACKUP_NAME%\config" "config\" >nul
if %errorlevel% equ 0 (echo    [OK] Diretorio config restaurado) else (echo    [ERRO] Falha ao restaurar diretorio config)

copy "%BACKUP_NAME%\README.md" "README.md" >nul
if %errorlevel% equ 0 (echo    [OK] README.md restaurado) else (echo    [AVISO] README.md nao encontrado no backup)

echo.
echo 4. Copiando scripts personalizados...
for %%f in ("%BACKUP_NAME%\*.cmd") do (
    if not "%%f"=="%BACKUP_NAME%\restore.cmd" (
        copy "%%f" ".\" >nul
        if %errorlevel% equ 0 (echo    [OK] %%f restaurado) else (echo    [ERRO] Falha ao restaurar %%f)
    )
)

echo.
echo 5. Recomendacoes apos restauracao:
echo    - Execute install_deps.cmd para reinstalar as dependencias
echo    - Verifique se todos os arquivos foram restaurados corretamente
echo    - Teste a aplicacao para garantir que esta funcionando
echo.

echo **********************************************
echo *  Restauracao concluida em %date% as %time%  *
echo **********************************************
echo.
echo Pressione qualquer tecla para continuar...
pause >nul