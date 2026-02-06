@echo off
chcp 65001 >nul
echo ========================================
echo    SyncBoard 数据中文化工具
echo ========================================
echo.

echo 正在执行数据库更新...
echo.

"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -pEA7music666 --default-character-set=utf8mb4 syncboard < "c:\projects\SyncBoard\insert_chinese_data.sql"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo    中文化成功！
    echo ========================================
    echo.
    echo 请刷新浏览器页面查看效果
) else (
    echo.
    echo ========================================
    echo    执行失败，请检查错误信息
    echo ========================================
)

echo.
pause
