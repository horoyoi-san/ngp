@echo off
echo Iniciando o Ananta Gateway Control...
echo.

REM Navegar ate o diretorio do gateway control
cd /d "d:\AnantaTestGameServer\AnantaTestGameServer 2.0\ananta-gateway-control"

REM Iniciar o gateway control em modo de desenvolvimento
echo Iniciando servidor de desenvolvimento na porta 8000...
call npm run dev -- --port=8000

echo.
echo Acesse a aplicacao em http://localhost:8000
echo.
echo Scripts adicionais disponiveis:
echo  - run_gateway.cmd: Inicia o servidor de desenvolvimento
echo  - build_gateway.cmd: Cria uma build da aplicacao
echo  - serve_gateway.cmd: Serve a aplicacao a partir dos arquivos buildados
echo  - clean_gateway.cmd: Remove arquivos temporarios
echo  - status_gateway.cmd: Verifica o status da instalacao
echo  - help_gateway.cmd: Mostra informacoes de ajuda
echo.
echo Pressione qualquer tecla para fechar esta janela...
pause >nul