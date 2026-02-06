@echo off
chcp 65001 >nul
echo ========================================
echo    SyncBoard 服务启动脚本
echo ========================================
echo.

echo [1/3] 检查 MySQL 服务...
sc query MySQL80 >nul 2>&1
if %errorlevel% neq 0 (
    echo 警告: MySQL 服务未运行
    echo 请先启动 MySQL 服务后再继续
    pause
    exit /b 1
)
echo OK - MySQL 服务正在运行
echo.

echo [2/3] 检查 Redis 服务...
sc query Redis >nul 2>&1
if %errorlevel% neq 0 (
    echo 警告: Redis 服务未运行
    echo 请先启动 Redis 服务后再继续
    pause
    exit /b 1
)
echo OK - Redis 服务正在运行
echo.

echo [3/3] 启动 SyncBoard 服务...
echo.
echo 正在启动服务，请稍候...
echo.
cd /d C:\projects\SyncBoard
"C:\Users\赵慧楠\Desktop\宁波实训\apache-maven-3.9.9-bin\apache-maven-3.9.9\bin\mvn.cmd" spring-boot:run

pause
