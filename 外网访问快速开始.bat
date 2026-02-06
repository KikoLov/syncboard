@echo off
chcp 65001 >nul
cls
echo ========================================
echo    SyncBoard 外网访问快速配置
echo ========================================
echo.
echo 此工具将帮助你配置内网穿透，让不同地方的人访问你的SyncBoard
echo.
echo ========================================
echo    选择内网穿透工具
echo ========================================
echo.
echo [1] Natapp（推荐，免费，稳定）
echo [2] 花生壳（老牌，简单，限速）
echo [3] Ngrok（国外，速度慢）
echo [4] 查看详细配置指南
echo [0] 退出
echo.
set /p choice=请选择 (1-4):

if "%choice%"=="1" goto natapp
if "%choice%"=="2" goto peanut
if "%choice%"=="3" goto ngrok
if "%choice%"=="4" goto guide
if "%choice%"=="0" exit /b

:natapp
cls
echo ========================================
echo    Natapp 配置向导
echo ========================================
echo.
echo 步骤1：注册账号
echo.
echo 1. 访问 https://natapp.cn/
echo 2. 点击"注册"创建账号
echo 3. 完成实名认证
echo.
pause
echo.
echo 步骤2：创建隧道
echo.
echo 1. 登录后点击"购买隧道"
echo 2. 选择免费隧道（0元）
echo 3. 配置如下：
echo    - 隧道名称：syncboard
echo    - 隧道协议：HTTP
echo    - 本地端口：8080
echo 4. 点击"购买"后复制authtoken
echo.
pause
echo.
echo 步骤3：下载客户端
echo.
echo 1. 访问 https://natapp.cn/#download
echo 2. 下载Windows版客户端
echo 3. 解压到 C:\natapp\ 目录
echo 4. 在natapp目录创建config.ini文件
echo 5. 粘贴authtoken到config.ini
echo.
echo 打开浏览器查看详细图文教程？
set /p open=按Y打开教程，按其他键跳转 (Y/N):
if /i "%open%"=="Y" start https://natapp.cn/#what
echo.
echo 配置完成后，双击"启动内网穿透-Natapp.bat"启动
echo.
pause
goto menu

:peanut
cls
echo ========================================
echo    花生壳配置向导
echo ========================================
echo.
echo 步骤1：下载安装
echo.
echo 1. 访问 https://hsk.oray.com/
echo 2. 下载"花生壳客户端"
echo 3. 安装并运行客户端
echo.
pause
echo.
echo 步骤2：注册登录
echo.
echo 在客户端中注册或登录账号
echo.
pause
echo.
echo 步骤3：添加映射
echo.
echo 1. 点击"添加映射"
echo 2. 配置如下：
echo    - 应用类型：HTTP
echo    - 内网主机：192.168.10.22
echo    - 内网端口：8080
echo 3. 点击保存
echo.
echo 打开花生壳下载页面？
set /p open=按Y打开下载页面，按其他键跳转 (Y/N):
if /i "%open%"=="Y" start https://hsk.oray.com/download/
echo.
pause
goto menu

:ngrok
cls
echo ========================================
echo    Ngrok配置向导
echo ========================================
echo.
echo 步骤1：下载注册
echo.
echo 1. 访问 https://ngrok.com/
echo 2. 注册账号
echo 3. 下载Windows版本
echo.
pause
echo.
echo 步骤2：解压使用
echo.
echo 1. 解压到 C:\ngrok\
echo 2. 打开命令行，输入：
echo    cd C:\ngrok
echo    ngrok authtoken 你的token
echo    ngrok http 8080
echo.
echo 打开ngrok官网？
set /p open=按Y打开官网，按其他键跳转 (Y/N):
if /i "%open%"=="Y" start https://ngrok.com/
echo.
pause
goto menu

:guide
cls
echo ========================================
echo    打开详细配置指南...
echo ========================================
echo.
start "" "内网穿透配置指南.md"
goto menu

:menu
exit /b
