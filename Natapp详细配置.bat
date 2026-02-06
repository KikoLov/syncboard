@echo off
chcp 65001 >nul
cls
echo ========================================
echo    Natapp 详细配置教程
echo ========================================
echo.
echo 首先我需要确认你已经准备好了：
echo.
echo [1] 已经注册了Natapp账号
echo [2] 已经创建了免费隧道
echo [3] 已经复制了authtoken
echo.
echo 如果都准备好了，我们开始配置！
echo.
pause

cls
echo ========================================
echo    第1步：下载Natapp客户端
echo ========================================
echo.
echo 正在打开Natapp下载页面...
echo.
start https://natapp.cn/#download
echo.
echo 请按照以下步骤下载：
echo.
echo 1. 在打开的网页中找到 "Windows版"
echo 2. 点击下载 natapp_windows_amd64.zip
echo 3. 等待下载完成
echo.
echo 下载完成后，按任意键继续...
pause >nul

cls
echo ========================================
echo    第2步：创建Natapp目录
echo ========================================
echo.
echo 现在我们在C盘创建一个natapp文件夹
echo.

if not exist "C:\natapp" mkdir "C:\natapp"
echo ✅ 已创建 C:\natapp\ 目录
echo.
echo 请将下载的 natapp_windows_amd64.zip 文件：
echo.
echo 1. 找到下载的zip文件
echo 2. 右键点击 -> 解压到
echo 3. 选择解压到 C:\natapp\
echo 4. 确保文件夹里有 natapp.exe 文件
echo.
echo 解压完成后，按任意键继续...
pause >nul

if not exist "C:\natapp\natapp.exe" (
    echo.
    echo ❌ 错误：在 C:\natapp\ 中没有找到 natapp.exe
    echo.
    echo 请确认：
    echo 1. 是否正确解压到 C:\natapp\
    echo 2. 解压后的文件名是 natapp.exe（不是natapp_windows_amd64.exe）
    echo.
    echo 重新配置请再次运行此脚本
    pause
    exit /b
)

cls
echo ========================================
echo    第3步：配置authtoken
echo ========================================
echo.
echo 现在需要配置你的authtoken
echo.
echo 请打开Natapp官网：https://natapp.cn/
echo 登录后进入 "我的隧道"
echo 复制你的authtoken（一串很长的字符）
echo.
pause

cls
echo.
echo 请将你的authtoken粘贴到下面：
echo.
set /p authtoken=authtoken=

if "%authtoken%"=="" (
    echo ❌ authtoken不能为空！
    pause
    goto :eof
)

echo.
echo 正在创建配置文件...

(
    echo [default]
    echo authtoken=%authtoken%
    echo clienttoken=
    echo log=none
    echo loglevel=ERROR
) > "C:\natapp\config.ini"

echo ✅ 配置文件已创建：C:\natapp\config.ini
echo.
pause

cls
echo ========================================
echo    第4步：启动测试
echo ========================================
echo.
echo 现在测试启动Natapp...
echo.

cd C:\natapp
echo 启动中...
echo.

start natapp

timeout /t 5 /nobreak >nul

echo.
echo ✅ Natapp已启动！
echo.
echo 请查看新打开的Natapp窗口...
echo.
echo 在窗口中找到类似这样的信息：
echo.
echo ┌────────────────────────────────────┐
echo │ Tunnel Status online              │
echo │ online_url http://xxxx.natapp.cn  │
echo │ Forwarding                        │
echo │ http://xxxx.natapp.cn             │
echo │    -> http://127.0.0.1:8080       │
echo └────────────────────────────────────┘
echo.
echo 其中 http://xxxx.natapp.cn 就是你的外网地址！
echo.
pause

cls
echo ========================================
echo    第5步：测试访问
echo ========================================
echo.
echo 正在测试本地服务...
echo.

tasklist | findstr java.exe >nul
if %errorlevel% neq 0 (
    echo ❌ 检测到SyncBoard服务未运行！
    echo.
    echo 请先启动SyncBoard服务：
    echo 双击运行 "启动服务.bat"
    echo.
    pause
    exit /b
)

echo ✅ SyncBoard服务正在运行
echo.
echo 现在请打开浏览器测试：
echo.
echo 本地测试：http://localhost:8080/api/login.html
echo 外网测试：http://你的地址.natapp.cn/api/login.html
echo.

cls
echo ========================================
echo    配置完成！
echo ========================================
echo.
echo 🎉 恭喜！Natapp配置成功！
echo.
echo 今后每次使用时：
echo.
echo 第1步：启动SyncBoard服务
echo   双击 "启动服务.bat"
echo.
echo 第2步：启动Natapp内网穿透
echo   双击 "启动内网穿透-Natapp.bat"
echo.
echo 第3步：获取外网地址
echo   在Natapp窗口中找到你的地址
echo.
echo 第4步：分享给朋友
echo   将地址发送给朋友，例如：
echo   http://xxxx.natapp.cn/api/register.html
echo.
echo ========================================
echo.
echo 常见问题：
echo.
echo Q1: Natapp显示离线？
echo A1: 重新运行 "启动内网穿透-Natapp.bat"
echo.
echo Q2: 朋友无法访问？
echo A2: 检查SyncBoard服务和Natapp都在运行
echo.
echo Q3: 地址变了？
echo A3: 免费版重启后地址会变，这是正常的
echo     付费版可以固定域名
echo.
echo ========================================
echo.
pause
