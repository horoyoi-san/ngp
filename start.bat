@echo off
setlocal
title Ananta Server

:: ── Language Selection ──
:lang_select
cls
echo ============================================
echo  AnantaTestGameServer - Modular Version
echo ============================================
echo.
echo Select Language / Selecione o Idioma / 选择语言 / 言語を選択 / Выберите язык:
echo.
echo   1. Portugues (Portuguese)
echo   2. English
echo   3. 中文 (Chinese)
echo   4. 日本語 (Japanese)
echo   5. Русский (Russian)
echo.
set /p LANG="Option / Opcao / 选项 / 選択 / Выбор (1-5): "

if "%LANG%"=="1" goto lang_pt
if "%LANG%"=="2" goto lang_en
if "%LANG%"=="3" goto lang_zh
if "%LANG%"=="4" goto lang_ja
if "%LANG%"=="5" goto lang_ru
echo Invalid option / Opcao invalida / 无效选项 / 無効な選択 / Недопустимый выбор
timeout /t 2 >nul
goto lang_select

:lang_pt
chcp 850 >nul
set TITLE=AnantaTestGameServer - Modular Version
set DEPS_INFO=[INFORMACOES DE DEPENDENCIAS E CONFIGURACOES]
set DOTNET_REQ=1. .NET SDK (obrigatorio):
set DOTNET_VER_REQ=- Versao minima: .NET 8.0 SDK
set DOTNET_DL=- Download: https://dotnet.microsoft.com/download
set NODE_REQ=2. Node.js (opcional, necessario para proxy):
set NODE_VER_REQ=- Versao recomendada: Node.js 18.x ou superior
set NODE_DL=- Download: https://nodejs.org/
set NODE_SKIP=- Se nao instalado, o servidor iniciara sem proxy
set HOSTS_REQ=3. Configuracao de Hosts (obrigatorio para proxy funcionar):
set HOSTS_CMD=- Execute como Administrador UMA VEZ:
set HOSTS_FILE=  server\Ananta_Proxy_Pack\start_proxy_with_admin.cmd
set HOSTS_DESC=- Isso configura o arquivo hosts para redirecionar
set HOSTS_DESC2=  o trafego do jogo para o servidor local
set PORTS_REQ=4. Portas necessarias:
set PORTS_SERVER=- Servidor: porta configurada em ananta.toml
set PORTS_PROXY=- Proxy: 80, 443, 5801, 5803, 5804
set DOTNET_ERR=[ERRO] .NET SDK nao encontrado.
set DOTNET_INSTALL=Por favor, instale o .NET 8.0 SDK ou superior:
set DOTNET_VER_INFO=[INFO] .NET SDK versao:
set SLN_ERR=[ERRO] AnantaServer.sln nao encontrado em server\
set RESTORING=Restaurando dependencias...
set RESTORE_ERR=[ERRO] Falha ao restaurar dependencias.
set COMPILING=Compilando o projeto...
set COMPILE_ERR=[ERRO] Falha ao compilar o projeto.
set BUILD_OK=Build OK!
set NODE_NOT_FOUND=[AVISO] Node.js nao encontrado - proxy nao sera iniciado.
set NODE_INSTALL=         Instale Node.js ou defina ANANTA_NODE_EXE.
set PROXY_FILE_ERR=[AVISO] server\Ananta_Proxy_Pack\proxy\server.js nao encontrado.
set PROXY_SETUP_WARN=[AVISO] SETUP DO PROXY NAO EXECUTADO!
set PROXY_DESC=O proxy redireciona o jogo para o servidor local.
set PROXY_DESC2=Sem ele, o cliente NAO consegue conectar.
set PROXY_CMD=Execute UMA VEZ como Administrador:
set PROXY_FILE=  server\Ananta_Proxy_Pack\start_proxy_with_admin.cmd
set PROXY_KEY=Pressione qualquer tecla para iniciar so o servidor...
set STARTING_PROXY=Iniciando o proxy em janela separada...
set PROXY_STARTED=Proxy iniciado (portas: 80, 443, 5801, 5803, 5804)
set STARTING_SERVER=Iniciando o servidor do jogo...
set SERVER_CLOSED=Servidor encerrado.
goto lang_done

:lang_en
chcp 437 >nul
set TITLE=AnantaTestGameServer - Modular Version
set DEPS_INFO=[DEPENDENCY AND CONFIGURATION INFORMATION]
set DOTNET_REQ=1. .NET SDK (required):
set DOTNET_VER_REQ=- Minimum version: .NET 8.0 SDK
set DOTNET_DL=- Download: https://dotnet.microsoft.com/download
set NODE_REQ=2. Node.js (optional, required for proxy):
set NODE_VER_REQ=- Recommended version: Node.js 18.x or higher
set NODE_DL=- Download: https://nodejs.org/
set NODE_SKIP=- If not installed, server will start without proxy
set HOSTS_REQ=3. Hosts Configuration (required for proxy to work):
set HOSTS_CMD=- Run as Administrator ONCE:
set HOSTS_FILE=  server\Ananta_Proxy_Pack\start_proxy_with_admin.cmd
set HOSTS_DESC=- This configures the hosts file to redirect
set HOSTS_DESC2=  game traffic to the local server
set PORTS_REQ=4. Required Ports:
set PORTS_SERVER=- Server: port configured in ananta.toml
set PORTS_PROXY=- Proxy: 80, 443, 5801, 5803, 5804
set DOTNET_ERR=[ERROR] .NET SDK not found.
set DOTNET_INSTALL=Please install .NET 8.0 SDK or higher:
set DOTNET_VER_INFO=[INFO] .NET SDK version:
set SLN_ERR=[ERROR] AnantaServer.sln not found in server\
set RESTORING=Restoring dependencies...
set RESTORE_ERR=[ERROR] Failed to restore dependencies.
set COMPILING=Compiling project...
set COMPILE_ERR=[ERROR] Failed to compile project.
set BUILD_OK=Build OK!
set NODE_NOT_FOUND=[WARNING] Node.js not found - proxy will not start.
set NODE_INSTALL=         Install Node.js or set ANANTA_NODE_EXE.
set PROXY_FILE_ERR=[WARNING] server\Ananta_Proxy_Pack\proxy\server.js not found.
set PROXY_SETUP_WARN=[WARNING] PROXY SETUP NOT EXECUTED!
set PROXY_DESC=The proxy redirects the game to the local server.
set PROXY_DESC2=Without it, the client CANNOT connect.
set PROXY_CMD=Run ONCE as Administrator:
set PROXY_FILE=  server\Ananta_Proxy_Pack\start_proxy_with_admin.cmd
set PROXY_KEY=Press any key to start server only...
set STARTING_PROXY=Starting proxy in separate window...
set PROXY_STARTED=Proxy started (ports: 80, 443, 5801, 5803, 5804)
set STARTING_SERVER=Starting game server...
set SERVER_CLOSED=Server closed.
goto lang_done

:lang_zh
chcp 936 >nul
set TITLE=AnantaTestGameServer - 模块化版本
set DEPS_INFO=[依赖和配置信息]
set DOTNET_REQ=1. .NET SDK (必需):
set DOTNET_VER_REQ=- 最低版本: .NET 8.0 SDK
set DOTNET_DL=- 下载: https://dotnet.microsoft.com/download
set NODE_REQ=2. Node.js (可选，代理需要):
set NODE_VER_REQ=- 推荐版本: Node.js 18.x 或更高
set NODE_DL=- 下载: https://nodejs.org/
set NODE_SKIP=- 如果未安装，服务器将在没有代理的情况下启动
set HOSTS_REQ=3. Hosts 配置 (代理工作需要):
set HOSTS_CMD=- 以管理员身份运行一次:
set HOSTS_FILE=  server\Ananta_Proxy_Pack\start_proxy_with_admin.cmd
set HOSTS_DESC=- 这会配置 hosts 文件以重定向
set HOSTS_DESC2=  游戏流量到本地服务器
set PORTS_REQ=4. 必需端口:
set PORTS_SERVER=- 服务器: ananta.toml 中配置的端口
set PORTS_PROXY=- 代理: 80, 443, 5801, 5803, 5804
set DOTNET_ERR=[错误] 未找到 .NET SDK。
set DOTNET_INSTALL=请安装 .NET 8.0 SDK 或更高版本:
set DOTNET_VER_INFO=[信息] .NET SDK 版本:
set SLN_ERR=[错误] 在 server\ 中未找到 AnantaServer.sln
set RESTORING=正在恢复依赖项...
set RESTORE_ERR=[错误] 恢复依赖项失败。
set COMPILING=正在编译项目...
set COMPILE_ERR=[错误] 编译项目失败。
set BUILD_OK=构建成功!
set NODE_NOT_FOUND=[警告] 未找到 Node.js - 代理将不会启动。
set NODE_INSTALL=         安装 Node.js 或设置 ANANTA_NODE_EXE。
set PROXY_FILE_ERR=[警告] 未找到 server\Ananta_Proxy_Pack\proxy\server.js。
set PROXY_SETUP_WARN=[警告] 代理设置未执行!
set PROXY_DESC=代理将游戏重定向到本地服务器。
set PROXY_DESC2=没有它，客户端无法连接。
set PROXY_CMD=以管理员身份运行一次:
set PROXY_FILE=  server\Ananta_Proxy_Pack\start_proxy_with_admin.cmd
set PROXY_KEY=按任意键仅启动服务器...
set STARTING_PROXY=在单独窗口中启动代理...
set PROXY_STARTED=代理已启动 (端口: 80, 443, 5801, 5803, 5804)
set STARTING_SERVER=正在启动游戏服务器...
set SERVER_CLOSED=服务器已关闭。
goto lang_done

:lang_ja
chcp 932 >nul
set TITLE=AnantaTestGameServer - モジュラーバージョン
set DEPS_INFO=[依存関係と構成情報]
set DOTNET_REQ=1. .NET SDK (必須):
set DOTNET_VER_REQ=- 最小バージョン: .NET 8.0 SDK
set DOTNET_DL=- ダウンロード: https://dotnet.microsoft.com/download
set NODE_REQ=2. Node.js (オプション、プロキシに必要):
set NODE_VER_REQ=- 推奨バージョン: Node.js 18.x 以上
set NODE_DL=- ダウンロード: https://nodejs.org/
set NODE_SKIP=- インストールされていない場合、プロキシなしでサーバーが起動します
set HOSTS_REQ=3. Hosts構成 (プロキシ動作に必要):
set HOSTS_CMD=- 管理者として1回実行:
set HOSTS_FILE=  server\Ananta_Proxy_Pack\start_proxy_with_admin.cmd
set HOSTS_DESC=- これによりhostsファイルが構成され、
set HOSTS_DESC2=  ゲームトラフィックがローカルサーバーにリダイレクトされます
set PORTS_REQ=4. 必要なポート:
set PORTS_SERVER=- サーバー: ananta.tomlで構成されたポート
set PORTS_PROXY=- プロキシ: 80, 443, 5801, 5803, 5804
set DOTNET_ERR=[エラー] .NET SDKが見つかりません。
set DOTNET_INSTALL=.NET 8.0 SDK以降をインストールしてください:
set DOTNET_VER_INFO=[情報] .NET SDKバージョン:
set SLN_ERR=[エラー] server\にAnantaServer.slnが見つかりません
set RESTORING=依存関係を復元しています...
set RESTORE_ERR=[エラー] 依存関係の復元に失敗しました。
set COMPILING=プロジェクトをコンパイルしています...
set COMPILE_ERR=[エラー] プロジェクトのコンパイルに失敗しました。
set BUILD_OK=ビルド成功!
set NODE_NOT_FOUND=[警告] Node.jsが見つかりません - プロキシは起動しません。
set NODE_INSTALL=         Node.jsをインストールするかANANTA_NODE_EXEを設定してください。
set PROXY_FILE_ERR=[警告] server\Ananta_Proxy_Pack\proxy\server.jsが見つかりません。
set PROXY_SETUP_WARN=[警告] プロキシセットアップが実行されていません!
set PROXY_DESC=プロキシはゲームをローカルサーバーにリダイレクトします。
set PROXY_DESC2=これがないと、クライアントは接続できません。
set PROXY_CMD=管理者として1回実行:
set PROXY_FILE=  server\Ananta_Proxy_Pack\start_proxy_with_admin.cmd
set PROXY_KEY=任意のキーを押してサーバーのみを起動...
set STARTING_PROXY=別のウィンドウでプロキシを起動しています...
set PROXY_STARTED=プロキシが起動しました (ポート: 80, 443, 5801, 5803, 5804)
set STARTING_SERVER=ゲームサーバーを起動しています...
set SERVER_CLOSED=サーバーが閉じました。
goto lang_done

:lang_ru
chcp 866 >nul
set TITLE=AnantaTestGameServer - Модульная версия
set DEPS_INFO=[ИНФОРМАЦИЯ О ЗАВИСИМОСТЯХ И КОНФИГУРАЦИИ]
set DOTNET_REQ=1. .NET SDK (обязательно):
set DOTNET_VER_REQ=- Минимальная версия: .NET 8.0 SDK
set DOTNET_DL=- Скачать: https://dotnet.microsoft.com/download
set NODE_REQ=2. Node.js (опционально, требуется для прокси):
set NODE_VER_REQ=- Рекомендуемая версия: Node.js 18.x или выше
set NODE_DL=- Скачать: https://nodejs.org/
set NODE_SKIP=- Если не установлен, сервер запустится без прокси
set HOSTS_REQ=3. Конфигурация Hosts (обязательно для работы прокси):
set HOSTS_CMD=- Запустите один раз от имени администратора:
set HOSTS_FILE=  server\Ananta_Proxy_Pack\start_proxy_with_admin.cmd
set HOSTS_DESC=- Это настраивает файл hosts для перенаправления
set HOSTS_DESC2=  игрового трафика на локальный сервер
set PORTS_REQ=4. Необходимые порты:
set PORTS_SERVER=- Сервер: порт настроен в ananta.toml
set PORTS_PROXY=- Прокси: 80, 443, 5801, 5803, 5804
set DOTNET_ERR=[ОШИБКА] .NET SDK не найден.
set DOTNET_INSTALL=Пожалуйста, установите .NET 8.0 SDK или выше:
set DOTNET_VER_INFO=[ИНФО] Версия .NET SDK:
set SLN_ERR=[ОШИБКА] AnantaServer.sln не найден в server\
set RESTORING=Восстановление зависимостей...
set RESTORE_ERR=[ОШИБКА] Не удалось восстановить зависимости.
set COMPILING=Компиляция проекта...
set COMPILE_ERR=[ОШИБКА] Не удалось скомпилировать проект.
set BUILD_OK=Сборка успешна!
set NODE_NOT_FOUND=[ПРЕДУПРЕЖДЕНИЕ] Node.js не найден - прокси не запустится.
set NODE_INSTALL=         Установите Node.js или установите ANANTA_NODE_EXE.
set PROXY_FILE_ERR=[ПРЕДУПРЕЖДЕНИЕ] server\Ananta_Proxy_Pack\proxy\server.js не найден.
set PROXY_SETUP_WARN=[ПРЕДУПРЕЖДЕНИЕ] НАСТРОЙКА ПРОКСИ НЕ ВЫПОЛНЕНА!
set PROXY_DESC=Прокси перенаправляет игру на локальный сервер.
set PROXY_DESC2=Без него клиент НЕ МОЖЕТ подключиться.
set PROXY_CMD=Запустите ОДИН РАЗ от имени администратора:
set PROXY_FILE=  server\Ananta_Proxy_Pack\start_proxy_with_admin.cmd
set PROXY_KEY=Нажмите любую клавишу для запуска только сервера...
set STARTING_PROXY=Запуск прокси в отдельном окне...
set PROXY_STARTED=Прокси запущен (порты: 80, 443, 5801, 5803, 5804)
set STARTING_SERVER=Запуск игрового сервера...
set SERVER_CLOSED=Сервер закрыт.
goto lang_done

:lang_done
cls
echo ============================================
echo  %TITLE%
echo ============================================
echo.

:: ── Language Support Warning ──
if "%LANG%"=="3" (
    echo [WARNING] If Chinese characters do not display correctly,
    echo           your system may not have Chinese language support installed.
    echo.
)
if "%LANG%"=="4" (
    echo [警告] If Japanese characters do not display correctly,
    echo       your system may not have Japanese language support installed.
    echo.
)
if "%LANG%"=="5" (
    echo [ПРЕДУПРЕЖДЕНИЕ] If Russian characters do not display correctly,
    echo                  your system may not have Russian language support installed.
    echo.
)

echo %DEPS_INFO%
echo.
echo %DOTNET_REQ%
echo %DOTNET_VER_REQ%
echo %DOTNET_DL%
echo.
echo %NODE_REQ%
echo %NODE_VER_REQ%
echo %NODE_DL%
echo %NODE_SKIP%
echo.
echo %HOSTS_REQ%
echo %HOSTS_CMD%
echo %HOSTS_FILE%
echo %HOSTS_DESC%
echo %HOSTS_DESC2%
echo.
echo %PORTS_REQ%
echo %PORTS_SERVER%
echo %PORTS_PROXY%
echo.
echo ============================================
echo.
pause
echo.

cd /d "%~dp0"

:: ── Check .NET SDK ──
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo %DOTNET_ERR%
    echo.
    echo %DOTNET_INSTALL%
    echo https://dotnet.microsoft.com/download
    echo.
    pause
    exit /b 1
)

:: ── Check .NET version ──
for /f "tokens=*" %%i in ('dotnet --version 2^>^&1') do set DOTNET_VER=%%i
echo %DOTNET_VER_INFO% %DOTNET_VER%
echo.

:: ── Check solution ──
if not exist "server\AnantaServer.sln" (
    echo %SLN_ERR%
    pause
    exit /b 1
)

:: ── Restore + Build ──
echo %RESTORING%
dotnet restore server\AnantaServer.sln
if %errorlevel% neq 0 (
    echo %RESTORE_ERR%
    pause
    exit /b 1
)

echo.
echo %COMPILING%
dotnet build server\Ananta.App\Ananta.App.csproj -c Release
if %errorlevel% neq 0 (
    echo %COMPILE_ERR%
    pause
    exit /b 1
)

echo.
echo %BUILD_OK%
echo.

:: ── Find Node.js ──
set "NODE_EXE="
where node >nul 2>&1
if %errorlevel% equ 0 (
    set "NODE_EXE=node"
    goto :found_node
)
if exist "%~dp0server\Ananta_Proxy_Pack\tools\node\node.exe" (
    set "NODE_EXE=%~dp0server\Ananta_Proxy_Pack\tools\node\node.exe"
    goto :found_node
)
if exist "C:\Program Files\nodejs\node.exe" (
    set "NODE_EXE=C:\Program Files\nodejs\node.exe"
    goto :found_node
)
echo %NODE_NOT_FOUND%
echo %NODE_INSTALL%
goto :start_server

:found_node
if not exist "%~dp0server\Ananta_Proxy_Pack\proxy\server.js" (
    echo %PROXY_FILE_ERR%
    goto :start_server
)

:: Verifica se hosts foi configurado
findstr /C:"Ananta local proxy" "%WINDIR%\System32\drivers\etc\hosts" >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo %PROXY_SETUP_WARN%
    echo %PROXY_DESC%
    echo %PROXY_DESC2%
    echo.
    echo %PROXY_CMD%
    echo %PROXY_FILE%
    echo.
    echo %PROXY_KEY%
    pause >nul
    goto :start_server
)

echo %STARTING_PROXY%
set "PROXY_DIR=%~dp0server\Ananta_Proxy_Pack\proxy"

:: ── Kill existing proxy if running (by ports) ──
echo [INFO] Verificando se proxy ja esta rodando...
for %%p in (443 80 5801 5803 5804) do (
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%%p " ^| findstr LISTENING') do (
        echo [INFO] Encerrando processo PID %%a usando porta %%p...
        taskkill /PID %%a /F >NUL 2>&1
    )
)
timeout /t 2 >nul

start "Ananta Proxy" /D "%PROXY_DIR%" cmd /k "%NODE_EXE%" server.js
timeout /t 2 >nul
echo %PROXY_STARTED%
echo.

:start_server
:: ── Start Game Server ──
echo %STARTING_SERVER%
echo.
cd server\Ananta.App\bin\Release\net8.0
Ananta.App.exe

echo.
echo ============================================
echo  %SERVER_CLOSED%
echo ============================================
pause
