#!/bin/bash

# SyncBoard 停止脚本
# 使用方法: ./stop.sh

APP_NAME="syncboard-1.0.0.jar"
APP_DIR="/opt/syncboard"
PID_FILE="$APP_DIR/app.pid"

cd $APP_DIR || exit 1

echo "正在停止 SyncBoard..."

if [ -f "$PID_FILE" ]; then
    PID=$(cat $PID_FILE)
    if ps -p $PID > /dev/null 2>&1; then
        echo "找到进程 PID: $PID"
        kill $PID
        sleep 3

        if ps -p $PID > /dev/null 2>&1; then
            echo "进程未停止，强制杀死..."
            kill -9 $PID
            sleep 2
        fi

        rm -f $PID_FILE
        echo "应用已停止"
    else
        echo "PID 文件中的进程不存在"
        rm -f $PID_FILE
    fi
else
    # 尝试通过进程名查找
    PID=$(ps -ef | grep $APP_NAME | grep -v grep | awk '{print $2}')
    if [ -n "$PID" ]; then
        echo "找到运行中的进程 PID: $PID"
        kill $PID
        sleep 3
        echo "应用已停止"
    else
        echo "没有找到运行中的进程"
    fi
fi
