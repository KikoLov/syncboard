#!/bin/bash

# SyncBoard 启动脚本
# 使用方法: ./start.sh

APP_NAME="syncboard-1.0.0.jar"
APP_DIR="/opt/syncboard"
LOG_FILE="$APP_DIR/app.log"
PID_FILE="$APP_DIR/app.pid"

cd $APP_DIR || exit 1

# 检查是否已经运行
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat $PID_FILE)
    if ps -p $OLD_PID > /dev/null 2>&1; then
        echo "应用已经在运行中，PID: $OLD_PID"
        echo "如需重启，请使用 ./restart.sh"
        exit 1
    fi
fi

echo "正在启动 SyncBoard..."

# 启动应用
nohup java -Xms512m -Xmx1024m -jar $APP_NAME --spring.profiles.active=prod > $LOG_FILE 2>&1 &
NEW_PID=$!

# 保存 PID
echo $NEW_PID > $PID_FILE

echo "应用已启动，PID: $NEW_PID"
echo "日志文件: $LOG_FILE"
echo ""
echo "使用以下命令查看日志："
echo "  tail -f $LOG_FILE"
