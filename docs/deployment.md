# 部署指南

本文档介绍如何将 SyncBoard 部署到生产环境。

---

## 目录

- [环境准备](#环境准备)
- [数据库配置](#数据库配置)
- [应用配置](#应用配置)
- [本地部署](#本地部署)
- [Docker 部署](#docker-部署)
- [云服务器部署](#云服务器部署)
- [Nginx 反向代理](#nginx-反向代理)
- [常见问题](#常见问题)

---

## 环境准备

### 必需软件

| 软件 | 版本要求 | 下载地址 |
|------|---------|----------|
| JDK | 17+ | [Oracle JDK](https://www.oracle.com/java/technologies/downloads/) |
| Maven | 3.6+ | [Maven](https://maven.apache.org/download.cgi) |
| MySQL | 8.0+ | [MySQL](https://dev.mysql.com/downloads/mysql/) |
| Redis | 6.0+ | [Redis](https://redis.io/download) |

### 可选软件

| 软件 | 用途 | 下载地址 |
|------|------|----------|
| Nginx | 反向代理 | [Nginx](https://nginx.org/en/download.html) |
| Docker | 容器化部署 | [Docker](https://www.docker.com/products/docker-desktop) |

---

## 数据库配置

### 1. 创建数据库

```bash
# 登录 MySQL
mysql -u root -p

# 创建数据库
CREATE DATABASE syncboard CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 创建用户（可选）
CREATE USER 'syncboard'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON syncboard.* TO 'syncboard'@'localhost';
FLUSH PRIVILEGES;
```

### 2. 导入数据

```bash
mysql -u root -p syncboard < database/init.sql
```

### 3. 验证表结构

```sql
USE syncboard;
SHOW TABLES;
DESCRIBE sys_user;
```

---

## 应用配置

### 1. 修改配置文件

编辑 `src/main/resources/application.yml`：

```yaml
spring:
  application:
    name: syncboard

  # 数据源配置
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/syncboard?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: your_password
    type: com.alibaba.druid.pool.DruidDataSource
    druid:
      initial-size: 5
      min-idle: 5
      max-active: 20
      max-wait: 60000

  # Redis 配置
  data:
    redis:
      host: localhost
      port: 6379
      password:
      timeout: 3000
      lettuce:
        pool:
          max-active: 8
          max-wait: -1
          max-idle: 8
          min-idle: 0

# 服务器配置
server:
  port: 8080
  servlet:
    context-path: /api

# MyBatis-Plus 配置
mybatis-plus:
  mapper-locations: classpath*:mapper/**/*.xml
  type-aliases-package: com.syncboard.entity
  configuration:
    map-underscore-to-camel-case: true
    cache-enabled: false
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
```

### 2. 配置说明

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `server.port` | 应用端口 | 8080 |
| `server.servlet.context-path` | 应用路径 | /api |
| `spring.datasource.url` | 数据库连接 | - |
| `spring.datasource.username` | 数据库用户名 | root |
| `spring.datasource.password` | 数据库密码 | - |
| `spring.data.redis.host` | Redis 主机 | localhost |
| `spring.data.redis.port` | Redis 端口 | 6379 |

---

## 本地部署

### 方式一：使用 Maven

```bash
# 进入项目目录
cd syncboard

# 启动应用
mvn spring-boot:run
```

### 方式二：打包运行

```bash
# 打包
mvn clean package -DskipTests

# 运行
java -jar target/syncboard-1.0.0.jar
```

### 方式三：后台运行

```bash
# 后台运行
nohup java -jar target/syncboard-1.0.0.jar > app.log 2>&1 &

# 查看日志
tail -f app.log

# 停止应用
ps aux | grep syncboard
kill -9 <PID>
```

---

## Docker 部署

### 1. 创建 Dockerfile

在项目根目录创建 `Dockerfile`：

```dockerfile
FROM openjdk:17-slim

LABEL maintainer="your.email@example.com"

WORKDIR /app

# 复制 JAR 文件
COPY target/syncboard-1.0.0.jar app.jar

# 暴露端口
EXPOSE 8080

# 设置时区
ENV TZ=Asia/Shanghai

# 启动应用
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 2. 创建 docker-compose.yml

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: syncboard-mysql
    environment:
      MYSQL_ROOT_PASSWORD: your_password
      MYSQL_DATABASE: syncboard
      TZ: Asia/Shanghai
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

  redis:
    image: redis:6.2
    container_name: syncboard-redis
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data

  app:
    build: .
    container_name: syncboard-app
    ports:
      - "8080:8080"
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/syncboard?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: your_password
      SPRING_DATA_REDIS_HOST: redis
      SPRING_DATA_REDIS_PORT: 6379
    depends_on:
      - mysql
      - redis
    restart: unless-stopped

volumes:
  mysql-data:
  redis-data:
```

### 3. 构建和运行

```bash
# 构建镜像
docker build -t syncboard:latest .

# 使用 docker-compose 启动
docker-compose up -d

# 查看日志
docker-compose logs -f app

# 停止服务
docker-compose down
```

---

## 云服务器部署

### 阿里云 ECS 部署示例

#### 1. 服务器配置

| 配置项 | 推荐值 |
|--------|--------|
| 操作系统 | Ubuntu 20.04 / CentOS 8 |
| CPU | 2 核 |
| 内存 | 4 GB |
| 磁盘 | 40 GB SSD |

#### 2. 安装 Java

```bash
# Ubuntu
sudo apt update
sudo apt install openjdk-17-jdk -y

# CentOS
sudo yum install java-17-openjdk-devel -y

# 验证安装
java -version
```

#### 3. 安装 MySQL

```bash
# Ubuntu
sudo apt install mysql-server -y

# CentOS
sudo yum install mysql-server -y

# 启动 MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# 初始化数据库
mysql -u root -p < database/init.sql
```

#### 4. 安装 Redis

```bash
# Ubuntu
sudo apt install redis-server -y

# CentOS
sudo yum install redis -y

# 启动 Redis
sudo systemctl start redis
sudo systemctl enable redis
```

#### 5. 部署应用

```bash
# 上传 JAR 文件到服务器
scp target/syncboard-1.0.0.jar root@your-server:/opt/syncboard/

# SSH 连接服务器
ssh root@your-server

# 创建目录
sudo mkdir -p /opt/syncboard
cd /opt/syncboard

# 赋予执行权限
sudo chmod +x syncboard-1.0.0.jar

# 创建 systemd 服务
sudo vim /etc/systemd/system/syncboard.service
```

添加以下内容：

```ini
[Unit]
Description=SyncBoard Application
After=network.target mysql.service redis.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/syncboard
ExecStart=/usr/bin/java -jar /opt/syncboard/syncboard-1.0.0.jar
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启动服务：

```bash
# 重新加载 systemd
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start syncboard

# 设置开机自启
sudo systemctl enable syncboard

# 查看状态
sudo systemctl status syncboard

# 查看日志
sudo journalctl -u syncboard -f
```

#### 6. 配置防火墙

```bash
# Ubuntu (UFW)
sudo ufw allow 8080/tcp
sudo ufw reload

# CentOS (firewalld)
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

---

## Nginx 反向代理

### 1. 安装 Nginx

```bash
# Ubuntu
sudo apt install nginx -y

# CentOS
sudo yum install nginx -y
```

### 2. 配置反向代理

创建配置文件 `/etc/nginx/conf.d/syncboard.conf`：

```nginx
upstream syncboard_backend {
    server localhost:8080;
}

server {
    listen 80;
    server_name your-domain.com;

    # 静态文件
    location / {
        proxy_pass http://syncboard_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # WebSocket 支持
    location /ws {
        proxy_pass http://syncboard_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 3. 启动 Nginx

```bash
# 测试配置
sudo nginx -t

# 启动 Nginx
sudo systemctl start nginx

# 设置开机自启
sudo systemctl enable nginx
```

---

## 性能优化

### 1. JVM 参数优化

```bash
java -Xms512m -Xmx1024m \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=200 \
     -XX:+HeapDumpOnOutOfMemoryError \
     -jar syncboard-1.0.0.jar
```

### 2. 数据库连接池优化

```yaml
spring:
  datasource:
    druid:
      initial-size: 10
      min-idle: 10
      max-active: 50
      max-wait: 60000
```

### 3. Redis 持久化

```bash
# redis.conf
appendonly yes
appendfsync everysec
```

---

## 监控和日志

### 1. 应用日志

```bash
# 查看实时日志
tail -f /opt/syncboard/app.log

# 查看错误日志
grep ERROR /opt/syncboard/app.log
```

### 2. 系统监控

```bash
# CPU 使用率
top -p $(pgrep -f syncboard)

# 内存使用
free -h

# 磁盘使用
df -h
```

---

## 常见问题

### Q1: 启动时提示连接数据库失败？

**A:** 检查以下几点：
1. MySQL 是否启动
2. 数据库用户名密码是否正确
3. 数据库是否已创建
4. 防火墙是否开放 3306 端口

### Q2: WebSocket 连接失败？

**A:** 检查：
1. Redis 是否启动
2. Nginx 是否正确配置 WebSocket 支持
3. 防火墙是否开放相应端口

### Q3: 应用占用内存过高？

**A:** 调整 JVM 参数：
```bash
java -Xms256m -Xmx512m -jar syncboard-1.0.0.jar
```

### Q4: 无法上传文件大小超过限制？

**A:** 修改 Nginx 配置：
```nginx
client_max_body_size 10M;
```

---

## 备份和恢复

### 数据库备份

```bash
# 备份
mysqldump -u root -p syncboard > backup_$(date +%Y%m%d).sql

# 恢复
mysql -u root -p syncboard < backup_20260131.sql
```

### 应用备份

```bash
# 备份 JAR 文件
cp /opt/syncboard/syncboard-1.0.0.jar /opt/syncboard/backup/
```

---

## 更新应用

```bash
# 1. 停止服务
sudo systemctl stop syncboard

# 2. 备份旧版本
sudo cp /opt/syncboard/syncboard-1.0.0.jar /opt/syncboard/backup/

# 3. 上传新版本
scp target/syncboard-1.0.0.jar root@your-server:/opt/syncboard/

# 4. 启动服务
sudo systemctl start syncboard

# 5. 查看日志
sudo journalctl -u syncboard -f
```

---

## 联系支持

如果遇到部署问题：

- 查看日志：`/opt/syncboard/app.log`
- 提交 Issue：[GitHub Issues](https://github.com/yourusername/syncboard/issues)
- 发送邮件：your.email@example.com
