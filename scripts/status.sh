#!/bin/bash

# SyncBoard 状态检查脚本
# 使用方法: ./status.sh

APP_NAME="syncboard-1.0.0.jar"
APP_DIR="/opt/syncboard"
PID_FILE="$APP_DIR/app.pid"
LOG_FILE="$APP_DIR/app.log"

cd $APP_DIR || exit 1

echo "=========================================="
echo "  SyncBoard 应用状态"
echo "=========================================="

# 检查 PID 文件
if [ -f "$PID_FILE" ]; then
    PID=$(cat $PID_FILE)
    echo "PID 文件存在: $PID"

    if ps -p $PID > /dev/null 2>&1; then
        echo "✅ 应用正在运行"
        echo ""
        echo "进程信息："
        ps -fp $PID
        echo ""
        echo "端口监听："
        netstat -tlnp 2>/dev/null | grep $PID || ss -tlnp 2>/dev/null | grep $PID
        echo ""
        echo "最近日志（最后 20 行）："
        echo "----------------------------------------"
        tail -20 $LOG_FILE
        echo "----------------------------------------"
    else
        echo "❌ PID 文件存在但进程未运行"
        echo "建议: 运行 ./restart.sh 重启应用"
    fi
else
    echo "PID 文件不存在"

    # 尝试查找进程
    PID=$(ps -ef | grep $APP_NAME | grep -v grep | awk '{print $2}')
    if [ -n "$PID" ]; then
        echo "⚠️  发现未记录的进程 PID: $PID"
        echo "建议: 运行 ./stop.sh 清理"
    else
        echo "❌ 应用未运行"
        echo "建议: 运行 ./start.sh 启动应用"
    fi
fi

echo "=========================================="
