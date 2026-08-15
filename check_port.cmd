@echo off
echo **********************************************
echo *    Verificador de Porta - Ananta Gateway    *
echo **********************************************
echo.
echo Verificando se a porta 8000 esta em uso...
echo.

REM Verificar se a porta 8000 esta em uso
netstat -an | find "8000" > temp_port_check.txt
if %errorlevel% equ 0 (
    echo A porta 8000 esta atualmente em uso:
    type temp_port_check.txt
    echo.
    echo Isso pode indicar que o Ananta Gateway Control ja esta em execucao.
    echo Se voce nao tiver o gateway control rodando, talvez precise encerrar
    echo o processo que esta usando a porta.
) else (
    echo A porta 8000 esta livre e disponivel para uso.
)

REM Verificar tambem a porta 8080 (para o modo producao)
echo.
echo Verificando se a porta 8080 esta em uso...
netstat -an | find "8080" > temp_port_check_8080.txt
if %errorlevel% equ 0 (
    echo A porta 8080 esta atualmente em uso:
    type temp_port_check_8080.txt
    echo.
    echo Isso pode indicar que o servidor de producao ja esta em execucao.
) else (
    echo A porta 8080 esta livre e disponivel para uso.
)

REM Limpar arquivos temporarios
del temp_port_check.txt >nul 2>&1
del temp_port_check_8080.txt >nul 2>&1

echo.
echo Verificacao concluida.
echo.
echo DICA: Se voce encontrar problemas de conexao:
echo - Verifique se o servidor do jogo esta rodando na porta 9011
echo - Verifique se nao ha outros processos usando as portas 8000 ou 8080
echo - Execute o gateway control como administrador se necessario
echo.
echo Pressione qualquer tecla para continuar...
pause >nul