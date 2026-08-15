@echo off
echo ================================================
echo        ANANTA GATEWAY CONTROL - AJUDA
echo ================================================
echo.
echo Este diretorio contem varios scripts para
echo gerenciar o Ananta Gateway Control:
echo.
echo 1. run_gateway.cmd
echo    - Inicia o servidor de desenvolvimento
echo    - Acesso em http://localhost:8000
echo    - Inclui hot reloading durante o desenvolvimento
echo.
echo 2. build_gateway.cmd
echo    - Cria uma build otimizada da aplicacao
echo    - Os arquivos sao gerados no diretorio /dist
echo    - Adequado para implantacao em producao
echo.
echo 3. serve_gateway.cmd
echo    - Serve a aplicacao a partir dos arquivos buildados
echo    - Acesso em http://localhost:8080
echo    - Modo producao, sem hot reloading
echo.
echo 4. clean_gateway.cmd
echo    - Remove arquivos temporarios e diretorios de build
echo    - Tambem limpa o cache do npm
echo.
echo 5. status_gateway.cmd
echo    - Verifica o status da instalacao e arquivos
echo    - Mostra informacoes sobre versoes e configuracao
echo.
echo 6. quick_start.cmd
echo    - Inicia rapidamente o servidor de desenvolvimento
echo    - Simples e rapido para uso diario
echo.
echo 7. check_port.cmd
echo    - Verifica se as portas 8000 e 8080 estao em uso
echo    - Ajuda a diagnosticar problemas de conexao
echo.
echo 8. safe_start.cmd
echo    - Inicia o servidor com verificacao de portas
echo    - Pergunta confirmacao se a porta ja estiver em uso
echo.
echo 9. install_deps.cmd
echo    - Instala as dependencias globais e locais
echo    - Necessario para o funcionamento do gateway
echo.
echo 10. setup_and_run.cmd
echo    - Combina instalacao de dependencias e inicio
echo    - Um unico script para preparar e executar
echo.
echo 11. diagnose.cmd
echo    - Realiza verificacao completa do ambiente
echo    - Identifica possiveis problemas e solucoes
echo.
echo 12. backup.cmd
echo    - Cria um backup do estado atual da aplicacao
echo    - Preserva arquivos importantes para recuperacao
echo.
echo 13. restore.cmd
echo    - Restaura a aplicacao a partir de um backup
echo    - Recupera arquivos importantes do estado salvo
echo.
echo 14. help_gateway.cmd (este script)
echo    - Mostra esta mensagem de ajuda
echo.
echo REQUISITOS:
echo - Node.js instalado
echo - npm instalado (incluido com Node.js)
echo.
echo INFORMACOES ADICIONAIS:
echo - A aplicacao se comunica com o servidor do jogo
echo   atraves da porta 9011 (certifique-se de que o
echo   servidor do jogo esteja em execucao)
echo - O gateway control roda na porta 8000 em modo
echo   de desenvolvimento
echo.
echo ================================================
echo.
echo Pressione qualquer tecla para continuar...
pause >nul