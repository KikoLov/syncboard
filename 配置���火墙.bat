@echo off
chcp 65001 >nul
cls
echo ========================================
echo    SyncBoard 防火墙配置工具
echo ========================================
echo.
echo 此工具将添加Windows防火墙规则，允许其他人访问你的SyncBoard
echo.
echo 需要管理员权限，正在请求权限...
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 正在请求管理员权限...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo 正在配置防火墙规则...
echo.

rem 删除旧规则（如果存在）
netsh advfirewall firewall delete rule name="SyncBoard HTTP" >nul 2>&1

rem 添加新规则
netsh advfirewall firewall add rule name="SyncBoard HTTP" dir=in action=allow protocol=TCP localport=8080 displayname="SyncBoard Web Server" description="允许SyncBoard服务通过端口8080"

if %errorLevel% equ 0 (
    echo.
    echo ========================================
    echo    ✅ 防火墙配置成功！
    echo ========================================
    echo.
    echo 端口 8080 已允许通过防火墙
    echo.
    echo 现在其他人可以通过局域网访问你的SyncBoard了！
    echo.
    echo 下一步：
    echo 1. 双击 "查看访问地址.bat" 获取访问地址
    echo 2. 将地址发送给朋友
    echo 3. 朋友在浏览器输入地址即可访问
) else (
    echo.
    echo ========================================
    echo    ❌ 防火墙配置失败
    echo ========================================
    echo.
    echo 请手动配置：
    echo 1. 按 Win + R，输入 wf.msc
    echo 2. 点击"入站规则"
    echo 3. 点击"新建规则"
    echo 4. 选择"端口" → 下一步
    echo 5. 选择"TCP"，端口输入 8080 → 下一步
    echo 6. 选择"允许连接" → 下一步
    echo 7. 全部勾选 → 下一步
    echo 8. 名称输入 "SyncBoard" → 完成
)

echo.
echo ========================================
pause
