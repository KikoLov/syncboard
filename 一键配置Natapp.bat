@echo off
chcp 65001 >nul

:: ========================================
:: Natapp 一键配置脚本
:: ========================================

cls
echo ╔════════════════════════════════════════╗
echo ║   Natapp 一键配置工具                  ║
echo ║   让不同地���的人访问你的SyncBoard     ║
echo ╚════════════════════════════════════════╝
echo.
echo 当前状态检查：
echo.

:: 检查Natapp目录
if not exist "C:\natapp" (
    echo [ ] C:\natapp\ 目录不存在
    echo.
    echo 正在创建目录...
    mkdir "C:\natapp"
    echo [√] 已创建 C:\natapp\ 目录
) else (
    echo [√] C:\natapp\ 目录已存在
)

:: 检查natapp.exe
if not exist "C:\natapp\natapp.exe" (
    echo [ ] natapp.exe 不存在
    echo.
    echo ┌─────────────────────────────────────┐
    echo │  请先完成以下步骤：                  │
    echo ├─────────────────────────────────────┤
    echo │  1. 访问 https://natapp.cn/         │
    echo │  2. 点击"下载中心"                  │
    echo │  3. 下载Windows版客户端             │
    echo │  4. 解压到 C:\natapp\               │
    echo │  5. 确保文件名为 natapp.exe        │
    echo └─────────────────────────────────────┘
    echo.
    echo 下载完成后请重新运行此脚本
    echo.
    pause
    exit /b
) else (
    echo [√] natapp.exe 已就绪
)

:: 检查config.ini
if not exist "C:\natapp\config.ini" (
    echo [ ] config.ini 不存在，需要配置
    echo.
    goto :config
) else (
    echo [√] config.ini 已存在
    echo.
    echo 是否重新配置？(Y/N)
    choice /c YN /n
    if errorlevel 2 goto :test
    if errorlevel 1 goto :config
)

:config
cls
echo ╔════════════════════════════════════════╗
echo ║   配置 Natapp authtoken               ║
echo ╚════════════════════════════════════════╝
echo.
echo 请按照以下步骤获取authtoken：
echo.
echo 1. 打开浏览器访问：https://natapp.cn/
echo 2. 登录你的账号
echo 3. 点击"我的隧道"
echo 4. 找到你创建的隧道
echo 5. 点击"复制authtoken"
echo.
echo ┌─────────────────────────────────────┐
echo │  authtoken 是一串很长的字符          │
echo │  例如：abc123def456...              │
echo └─────────────────────────────────────┘
echo.
set /p authtoken=请粘贴你的authtoken:

if "%authtoken%"=="" (
    echo.
    echo ❌ authtoken不能为空！
    pause
    goto :config
)

:: 创建config.ini
echo.
echo 正在创建配置文件...

(
    echo [default]
    echo authtoken=%authtoken%
    echo clienttoken=
    echo log=none
    echo loglevel=ERROR
) > "C:\natapp\config.ini"

echo [√] config.ini 创建成功
echo.
pause

:test
cls
echo ╔════════════════════════════════════════╗
echo ║   测试 Natapp                         ║
echo ╚════════════════════════════════════════╝
echo.
echo 正在启动Natapp...
echo.

cd C:\natapp
start natapp

echo.
echo [√] Natapp已启动
echo.
echo ⏳ 等待5秒检查连接状态...
timeout /t 5 /nobreak >nul

cls
echo ╔════════════════════════════════════════╗
echo ║   检查连接状态                        ║
echo ╚════════════════════════════════════════╝
echo.
echo 请查看Natapp窗口，找到类似这样的信息：
echo.
echo ┌─────────────────────────────────────┐
echo │  online_url=http://xxxx.natapp.cn   │
echo │  Forwarding:                        │
echo │  http://xxxx.natapp.cn              │
echo │    -> http://127.0.0.1:8080         │
echo └─────────────────────────────────────┘
echo.
echo 其中的 http://xxxx.natapp.cn 就是你的外网地址！
echo.
echo 按任意键继续...
pause >nul

:final
cls
echo ╔════════════════════════════════════════╗
echo ║   ✅ 配置完成！                        ║
echo ╚════════════════════════════════════════╝
echo.
echo 📝 你的外网访问地址是：
echo.
echo     http://你的地址.natapp.cn
echo.
echo ───────────────────────────────────────
echo.
echo 分享给朋友的地址：
echo.
echo 📝 注册页面：
echo    http://你的地址.natapp.cn/api/register.html
echo.
echo 🔐 登录页面：
echo    http://你的地址.natapp.cn/api/login.html
echo.
echo 📊 主应用页面：
echo    http://你的地址.natapp.cn/api/index.html
echo.
echo ───────────────────────────────────────
echo.
echo 📖 使用说明：
echo.
echo 第1步：启动SyncBoard服务
echo   双击运行 "启动服务.bat"
echo.
echo 第2步：启动Natapp
echo   双击运行 "C:\natapp\natapp.exe"
echo.
echo 第3步：复制外网地址
echo   在Natapp窗口中找到 online_url
echo.
echo 第4步：分享给朋友
echo   将地址发送给朋友即可
echo.
echo ───────────────────────────────────────
echo.
echo ⚠️  重要提示：
echo   - 两个窗口都必须保持运行
echo   - 关闭任何一个，朋友都无法访问
echo   - 免费版重启后地址可能会变
echo.
echo ───────────────────────────────────────
echo.
echo 按任意键退出...
pause >nul

exit /b
