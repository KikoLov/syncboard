#!/bin/bash

# SyncBoard 重启脚本
# 使用方法: ./restart.sh

echo "=========================================="
echo "  SyncBoard 应用重启脚本"
echo "=========================================="

# 应用配置
APP_NAME="syncboard-1.0.0.jar"
APP_DIR="/opt/syncboard"
LOG_FILE="$APP_DIR/app.log"
PID_FILE="$APP_DIR/app.pid"

# 进入应用目录
cd $APP_DIR || exit 1

# 1. 停止旧进程
echo "正在停止旧进程..."

if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat $PID_FILE)
    if ps -p $OLD_PID > /dev/null 2>&1; then
        echo "找到运行中的进程 PID: $OLD_PID"
        kill $OLD_PID
        sleep 3

        # 检查进程是否停止
        if ps -p $OLD_PID > /dev/null 2>&1; then
            echo "进程未停止，强制杀死..."
            kill -9 $OLD_PID
            sleep 2
        fi
        echo "旧进程已停止"
    else
        echo "PID 文件中的进程不存在，清理 PID 文件"
    fi
    rm -f $PID_FILE
else
    # 尝试通过进程名查找
    PID=$(ps -ef | grep $APP_NAME | grep -v grep | awk '{print $2}')
    if [ -n "$PID" ]; then
        echo "找到运行中的进程 PID: $PID"
        kill $PID
        sleep 3
        echo "旧进程已停止"
    else
        echo "没有找到运行中的进程"
    fi
fi

# 2. 备份旧日志（可选）
if [ -f "$LOG_FILE" ]; then
    BACKUP_LOG="$APP_DIR/app.log.$(date +%Y%m%d_%H%M%S)"
    mv $LOG_FILE $BACKUP_LOG
    echo "旧日志已备份到: $BACKUP_LOG"
fi

# 3. 启动新进程
echo "正在启动应用..."
nohup java -Xms512m -Xmx1024m -jar $APP_NAME --spring.profiles.active=prod > $LOG_FILE 2>&1 &
NEW_PID=$!

# 保存 PID
echo $NEW_PID > $PID_FILE
echo "新进程 PID: $NEW_PID"

# 4. 等待应用启动
echo "等待应用启动..."
sleep 5

# 5. 检查启动状态
if ps -p $NEW_PID > /dev/null 2>&1; then
    echo "=========================================="
    echo "✅ 应用启动成功！"
    echo "   PID: $NEW_PID"
    echo "   日志文件: $LOG_FILE"
    echo "=========================================="

    # 显示最后 20 行日志
    echo ""
    echo "最近的日志输出："
    echo "----------------------------------------"
    tail -20 $LOG_FILE
    echo "----------------------------------------"
    echo ""
    echo "使用 'tail -f $LOG_FILE' 查看实时日志"
else
    echo "=========================================="
    echo "❌ 应用启动失败！"
    echo "   请查看日志文件: $LOG_FILE"
    echo "=========================================="
    tail -50 $LOG_FILE
    exit 1
fi
