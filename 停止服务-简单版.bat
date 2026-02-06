@echo off
echo ========================================
echo    Stop SyncBoard Service
echo ========================================
echo.
echo Stopping all Java processes...
taskkill /F /IM java.exe >nul 2>&1

echo.
echo ========================================
echo    Done!
echo ========================================
echo.
echo Service stopped. Press any key to exit...
pause >nul
