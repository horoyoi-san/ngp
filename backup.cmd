@echo off
echo **********************************************
echo *         Backup - Ananta Gateway Control      *
echo **********************************************
echo.
echo Este script cria um backup do estado atual
echo da aplicacao Ananta Gateway Control.
echo.

REM Obter data e hora para nome do backup
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set stamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%

set BACKUP_DIR="gateway_backup_%stamp%"

echo 1. Criando diretorio de backup: !BACKUP_DIR!
mkdir !BACKUP_DIR!

echo.
echo 2. Copiando arquivos importantes...
copy "package.json" "!BACKUP_DIR!\package.json" >nul
copy "package-lock.json" "!BACKUP_DIR!\package-lock.json" >nul
xcopy /s /e /y "src" "!BACKUP_DIR!\src\" >nul
xcopy /s /e /y "config" "!BACKUP_DIR!\config\" >nul
copy "README.md" "!BACKUP_DIR!\README.md" >nul

echo.
echo 3. Copiando scripts personalizados...
copy "*.cmd" "!BACKUP_DIR!" >nul

echo.
echo 4. Verificando se o backup foi criado...
if exist "!BACKUP_DIR!" (
    echo    [OK] Backup criado com sucesso em !BACKUP_DIR!
    dir /s "!BACKUP_DIR!" | find /i "File(s)"
) else (
    echo    [ERRO] Falha ao criar o backup
)

echo.
echo 5. Recomendacoes:
echo    - Mantenha os backups em um local seguro
echo    - Voce pode restaurar a aplicacao copiando os arquivos de volta
echo    - Os backups nao incluem o diretorio node_modules (muito grande)
echo    - Para restaurar, copie os arquivos e execute install_deps.cmd
echo.

echo **********************************************
echo *  Backup concluido em %date% as %time%      *
echo **********************************************
echo.
echo Diretorio do backup: !BACKUP_DIR!
echo.
echo Pressione qualquer tecla para continuar...
pause >nul