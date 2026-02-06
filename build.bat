@echo off
cd /d C:\projects\SyncBoard
call mvn clean package -DskipTests
echo Package completed!
pause
