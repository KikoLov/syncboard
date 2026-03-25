# SyncBoard 部署脚本使用指南

## 脚本列表

- `start.sh` - 启动应用
- `stop.sh` - 停止应用
- `restart.sh` - 重启应用
- `status.sh` - 查看应用状态

## 部署步骤

### 1. 通过 XFTP 上传脚本

将 `scripts` 文件夹上传到服务器：
```
/opt/syncboard/scripts/
```

### 2. 赋予执行权限

在 XShell 中执行：
```bash
cd /opt/syncboard/scripts
chmod +x *.sh
```

### 3. 修改配置（如果需要）

如果你的应用目录不是 `/opt/syncboard`，需要修改脚本中的 `APP_DIR` 变量：
```bash
vi start.sh
vi stop.sh
vi restart.sh
vi status.sh
```

将 `APP_DIR="/opt/syncboard"` 改为你的实际路径

## 使用方法

### 启动应用
```bash
cd /opt/syncboard/scripts
./start.sh
```

### 停止应用
```bash
cd /opt/syncboard/scripts
./stop.sh
```

### 重启应用（推荐）
```bash
cd /opt/syncboard/scripts
./restart.sh
```

### 查看状态
```bash
cd /opt/syncboard/scripts
./status.sh
```

### 查看实时日志
```bash
# 查看应用日志
tail -f /opt/syncboard/app.log

# 查看 Nginx 日志（如果有）
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

## 常见问题

### 1. 端口被占用
```bash
# 查看 8080 端口占用
netstat -tlnp | grep 8080

# 或使用 lsof
lsof -i:8080

# 杀死占用进程
kill -9 <PID>
```

### 2. 应用启动失败
```bash
# 查看详细日志
cat /opt/syncboard/app.log

# 检查 Java 版本
java -version

# 检查数据库连接
mysql -u root -p -h localhost
```

### 3. 内存不足
修改 `start.sh` 和 `restart.sh` 中的 JVM 参数：
```bash
# 原配置
java -Xms512m -Xmx1024m

# 减少内存使用
java -Xms256m -Xmx512m
```

### 4. 权限问题
```bash
# 确保脚本有执行权限
chmod +x /opt/syncboard/scripts/*.sh

# 确保应用目录有写入权限
chmod -R 755 /opt/syncboard
```

## 快捷命令（可添加到 ~/.bashrc）

```bash
# 编辑 bashrc
vi ~/.bashrc

# 添加以下别名
alias syncboard-start='cd /opt/syncboard/scripts && ./start.sh'
alias syncboard-stop='cd /opt/syncboard/scripts && ./stop.sh'
alias syncboard-restart='cd /opt/syncboard/scripts && ./restart.sh'
alias syncboard-status='cd /opt/syncboard/scripts && ./status.sh'
alias syncboard-log='tail -f /opt/syncboard/app.log'

# 使配置生效
source ~/.bashrc

# 使用
syncboard-restart    # 重启应用
syncboard-status     # 查看状态
syncboard-log        # 查看日志
```

## 系统服务配置（可选）

如果想设置开机自启，可以创建 systemd 服务：

```bash
# 创建服务文件
sudo vi /etc/systemd/system/syncboard.service
```

内容如下：
```ini
[Unit]
Description=SyncBoard Application
After=network.target mysql.service redis.service

[Service]
Type=simple
User=your-username
WorkingDirectory=/opt/syncboard
ExecStart=/usr/bin/java -Xms512m -Xmx1024m -jar /opt/syncboard/syncboard-1.0.0.jar --spring.profiles.active=prod
ExecStop=/bin/kill -15 $MAINPID
Restart=on-failure
RestartSec=10
StandardOutput=append:/opt/syncboard/app.log
StandardError=append:/opt/syncboard/app.log

[Install]
WantedBy=multi-user.target
```

使用 systemd 管理：
```bash
# 重新加载配置
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start syncboard

# 停止服务
sudo systemctl stop syncboard

# 重启服务
sudo systemctl restart syncboard

# 查看状态
sudo systemctl status syncboard

# 设置开机自启
sudo systemctl enable syncboard

# 禁用开机自启
sudo systemctl disable syncboard
```
