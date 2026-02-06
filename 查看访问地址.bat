@echo off
chcp 65001 >nul
cls
echo ========================================
echo    SyncBoard 局域网访问地址
echo ========================================
echo.

rem 获取本机局域网IP地址
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4" ^| findstr /V "127.0.0.1"') do (
    set IP=%%a
    set IP=!IP: =!
)

echo 📍 你的局域网IP地址: !IP!
echo.
echo ========================================
echo    其他人的访问地址（复制发送给朋友）
echo ========================================
echo.
echo 📝 注册页面:
echo    http://!IP!:8080/api/register.html
echo.
echo 🔐 登录页面:
echo    http://!IP!:8080/api/login.html
echo.
echo 📊 主应用页面:
echo    http://!IP!:8080/api/index.html
echo.
echo ========================================
echo    使用说明
echo ========================================
echo.
echo 1. 确保你的电脑和朋友的设备连接到同一个WiFi
echo 2. 确保SyncBoard服务正在运行
echo 3. 将上面的地址发送给朋友
echo 4. 如果朋友无法访问，请检查Windows防火墙设置
echo.
echo ========================================
echo    按任意键关闭此窗口...
echo ========================================
pause >nul
