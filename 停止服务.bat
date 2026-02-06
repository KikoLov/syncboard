@echo off
echo ========================================
echo    SyncBoard Service Stop
echo ========================================
echo.

echo Finding process on port 8080...
set FOUND=0
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING') do (
    set PID=%%a
    set FOUND=1
    echo Found process PID: %%PID
    echo.
    echo Stopping process...
    taskkill /F /PID %%PID >nul 2>&1
    if errorlevel 0 (
        echo.
        echo ========================================
        echo    SyncBoard Service Stopped
        echo ========================================
    ) else (
        echo Trying alternative method...
        taskkill /F /IM java.exe >nul 2>&1
        if errorlevel 0 (
            echo.
            echo ========================================
            echo    SyncBoard Service Stopped
            echo ========================================
        ) else (
            echo.
            echo Could not auto-stop service
            echo Please stop manually:
            echo 1. Press Ctrl+C in Maven terminal
            echo 2. Or use Task Manager to end java.exe process
        )
    )
    goto :end
)

if %FOUND%==0 (
    echo.
    echo ========================================
    echo    No Running Service Found
    echo ========================================
    echo.
    echo SyncBoard service may not be running
)

:end
echo.
pause
