@echo off
chcp 65001 >nul
echo ==========================================
echo   SyncBoard 快速启动脚本
echo ==========================================
echo.

REM 检查 Maven 是否安装
where mvn >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 未找到 Maven，请先安装 Maven
    pause
    exit /b 1
)

REM 检查 Java 是否安装
where java >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 未找到 Java，请先安装 JDK 17+
    pause
    exit /b 1
)

echo ✅ 环境检查通过
echo.
echo 📦 正在编译项目...
call mvn clean package -DskipTests

if %errorlevel% neq 0 (
    echo ❌ 编译失败
    pause
    exit /b 1
)

echo.
echo 🚀 正在启动 SyncBoard...
echo.
echo ==========================================
echo   WebSocket: ws://localhost:8080/api/ws
echo   API: http://localhost:8080/api
echo ==========================================
echo.

java -jar target\syncboard-1.0.0.jar

pause
