@echo off
chcp 65001 >nul
echo ========================================
echo    SyncBoard 服务状态检查
echo ========================================
echo.

echo [检查 1/4] MySQL 服务状态
sc query MySQL80 >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] MySQL 服务正在运行
) else (
    echo [!!] MySQL 服务未运行 - 请启动 MySQL80 服务
)
echo.

echo [检查 2/4] Redis 服务状态
sc query Redis >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Redis 服务正在运行
) else (
    echo [!!] Redis 服务未运行 - 请启动 Redis 服务
)
echo.

echo [检查 3/4] 端口 8080 状态
netstat -ano | findstr :8080 | findstr LISTENING >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] 端口 8080 已被占用 - SyncBoard 服务可能正在运行
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING') do (
        echo      进程 PID: %%a
    )
) else (
    echo [!!] 端口 8080 未被占用 - SyncBoard 服务未启动
)
echo.

echo [检查 4/4] 测试 API 连接
echo.
echo 正在测试 http://localhost:8080/api ...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080/api/boards/1' -TimeoutSec 5; if ($response.StatusCode -eq 200) { Write-Host '[OK] API 连接正常' -ForegroundColor Green } else { Write-Host '[!!] API 返回异常状态' -ForegroundColor Red } } catch { Write-Host '[!!] 无法连接到 API' -ForegroundColor Red }"
echo.

echo ========================================
echo    检查完成
echo ========================================
echo.
echo 需要启动服务？请运行"启动服务.bat"
echo 需要停止服务？请运行"停止服务.bat"
echo.
pause
