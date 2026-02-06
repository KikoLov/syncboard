@echo off
chcp 65001 >nul
cls
echo ========================================
echo    SyncBoard + Natapp 内网穿透启动
echo ========================================
echo.

rem 检查Natapp是否已安装
if not exist "C:\natapp\natapp.exe" (
    echo Natapp未安装！
    echo.
    echo 请按以下步骤安装：
    echo 1. 访问 https://natapp.cn/
    echo 2. 注册账号并创建免费隧道
    echo 3. 下载Windows版客户端
    echo 4. 解压到 C:\natapp\ 目录
    echo 5. 将authtoken填入config.ini
    echo.
    echo 详细教程请查看：内网穿透配置指南.md
    echo.
    pause
    exit /b
)

echo 正在启动内网穿透...
echo.
echo ========================================
echo.

cd C:\natapp
start natapp

timeout /t 3 /nobreak >nul

echo.
echo ✅ Natapp已启动！
echo.
echo 请在Natapp窗口中找到你的外网访问地址
echo 格式类似：http://xxx.natapp.cn
echo.
echo 分享给朋友的访问地址：
echo   注册页面：http://xxx.natapp.cn/api/register.html
echo   登录页面：http://xxx.natapp.cn/api/login.html
echo.
echo ========================================
echo.
echo 注意事项：
echo - 保持此窗口运行，不要关闭
echo - 内网穿透窗口不能关闭
echo - SyncBoard服务必须保持运行
echo.
pause
