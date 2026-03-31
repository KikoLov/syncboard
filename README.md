# SyncBoard - 实时协作任务管理平台

---

## 项目简介

SyncBoard 是一个基于 Spring Boot 和 WebSocket 的实时协作看板应用，类似于 Trello。它支持多人实时协作、任务拖拽排序、在线状态同步等功能，适用于团队项目管理、敏捷开发等场景。

### 在线演示

**部署地址**：http://60.205.140.97:8080/api/login.html

**测试账号**：
- 用户名：root
- 密码：admin123（或使用忘记密码功能重置）

你也可以自行注册新账号体验。

> **💡 提示**：如果你忘记了密码，可以点击登录页面的"忘记密码？"链接，通过注册时填写的用户名和邮箱来重置密码。

---

## 核心功能

- **用户认证**：注册、登录、会话管理
- **密码重置**：忘记密码？通过用户名和邮箱验证后重置密码
- **看板管理**：创建、编辑看板，设置背景颜色
- **任务管理**：创建、编辑、删除任务，支持优先级设置
- **拖拽排序**：采用 Fractional Indexing 算法，流畅的拖拽体验
- **实时协作**：WebSocket 实时同步，多用户同时操作
- **在线统计**：实时显示在线用户和人数
- **并发控制**：乐观锁机制，避免数据冲突

---

## 快速开始

### 环境要求

- JDK 17+
- Maven 3.6+
- MySQL 8.0+
- Redis 6.0+

### 安装步骤

1. **克隆项目**

```bash
git clone https://github.com/KikoLov/syncboard.git
cd syncboard
```

2. **初始化数据库**

```bash
mysql -u root -p -e "CREATE DATABASE syncboard CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p syncboard < database/init.sql
```

3. **修改配置**

编辑 `src/main/resources/application.yml`，修改数据库密码：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/syncboard
    username: root
    password: admin123
```

4. **启动应用**

```bash
mvn spring-boot:run
```

5. **访问应用**

打开浏览器访问：http://localhost:8080/api/login.html

---

## 技术栈

### 后端

- Java 17
- Spring Boot 3.1.8
- Spring WebSocket
- MyBatis-Plus 3.5.7
- MySQL 8.0
- Redis 6.x

### 前端

- HTML5 + CSS3 + JavaScript
- HTML5 Drag and Drop API
- WebSocket API

---

## 部署情况

本项目已成功部署在阿里云 ECS 服务器上。

### 部署环境

- **服务器**：阿里云 ECS
- **公网 IP**：60.205.140.97
- **操作系统**：Ubuntu 20.04
- **Java 版本**：OpenJDK 17
- **数据库**：MySQL 8.0
- **缓存**：Redis 6.x

### 部署架构

```
用户浏览器 → Spring Boot 应用 (端口 8080)
                                    ↓
                              MySQL 数据库
                                    ↓
                              Redis 缓存/消息队列
```

### 部署步骤

1. 在服务器上安装 JDK、MySQL、Redis
2. 导入数据库脚本 `database/init.sql`
3. 配置 `application.yml` 中的数据库连接信息
4. 使用 Maven 打包：`mvn clean package`
5. 上传 JAR 文件到服务器：`/opt/syncboard/syncboard-1.0.0.jar`
6. 后台运行：`nohup java -jar syncboard-1.0.0.jar > app.log 2>&1 &`
7. 配置防火墙开放 8080 端口

### 部署心得

这是我第一次将项目部署到云服务器，过程中遇到了不少问题：

- **数据库表名不匹配**：本地开发的表名和服务器上不一样
- **端口占用**：8080 端口被占用，需要先停止旧进程
- **Redis 消息格式问题**：旧数据导致解析失败，需要清空 Redis
- **静态资源 404**：应用的 context path 是 `/api`，访问时需要加上这个前缀

但正是这些问题让我学到了很多，也感受到了解决实际问题后的成就感！

---

## 项目结构

```
SyncBoard/
├── docs/                    # 项目文档
│   ├── api.md              # API 接口文档
│   ├── deployment.md       # 部署指南
│   └── github-push-guide.md # GitHub 推送指南
├── database/               # 数据库脚本
│   └── init.sql           # 数据库初始化脚本
├── src/main/
│   ├── java/com/syncboard/
│   │   ├── config/        # 配置类
│   │   ├── controller/    # REST API
│   │   ├── entity/        # 实体类
│   │   ├── mapper/        # MyBatis Mapper
│   │   ├── service/       # 业务逻辑
│   │   ├── redis/         # Redis 发布订阅
│   │   └── util/          # 工具类
│   └── resources/
│       ├── application.yml # 应用配置
│       └── static/        # 静态资源（HTML 页面）
├── README.md              # 项目说明
├── CONTRIBUTING.md        # 贡献指南
├── CHANGELOG.md           # 更新日志
├── LICENSE                # MIT 开源协议
└── pom.xml               # Maven 配置
```

---

## 核心技术实现

### 拖拽排序算法

使用 Fractional Indexing 算法，用浮点数作为排序序号，移动卡片时计算中间值，避免重排整个列表。

### 乐观锁并发控制

通过 `@Version` 注解实现乐观锁，当多个用户同时修改同一任务时，检测版本冲突。

### Redis 分布式广播

通过 Redis Pub/Sub 实现多实例部署时的消息广播，确保实时同步。

---

## 数据库设计

### 核心表结构

| 表名 | 说明 | 关键字段 |
|------|------|----------|
| sys_user | 用户表 | id, username, password, avatar_url |
| sb_board | 看板表 | id, name, owner_id, background_color |
| sb_column | 任务列表 | id, board_id, name, sort_order |
| sb_task | 任务卡片 | id, column_id, title, sort_order, version |
| sb_activity_log | 操作日志 | id, board_id, action_type, details |

---

## API 示例

### 用户登录

```http
POST /api/users/login

{
  "username": "root",
  "password": "admin123"
}
```

### 重置密码

```http
POST /api/users/reset-password

{
  "username": "root",
  "email": "2029002141@qq.com",
  "newPassword": "newPassword123",
  "confirmPassword": "newPassword123"
}
```

### 创建任务

```http
POST /api/tasks

{
  "boardId": 1,
  "columnId": 1,
  "title": "新任务",
  "priority": 2
}
```

### WebSocket 连接

```
ws://60.205.140.97:8080/api/ws
```

详细 API 文档请查看：[docs/api.md](docs/api.md)

---

## 更新日志

### v1.0.0 (2026-01-31)

**新功能**
- 用户注册/登录功能
- 看板和任务管理
- 拖拽排序功能
- WebSocket 实时协作
- 在线用户统计

**Bug 修复**
- 修复并发冲突问题
- 修复 WebSocket 连接问题

详细更新日志：[CHANGELOG.md](CHANGELOG.md)

---

## 贡献

欢迎贡献代码！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详情。

---

## 开源协议

本项目基于 MIT License 开源，你可以自由使用、修改和分发。

---

## 致谢

感谢以下开源项目：

- [Spring Boot](https://spring.io/projects/spring-boot)
- [MyBatis-Plus](https://baomidou.com/)
- [Redis](https://redis.io/)

特别感谢 Claude AI 在开发过程中提供的帮助！

---

## 联系方式

如果你有任何意见、建议或想法，欢迎联系我！

- **微信**：z13592483458
- **邮箱**：zhaohuinan1@gmail.com
- **GitHub**：[KikoLov](https://github.com/KikoLov)

---

**如果这个项目对你有帮助，请给一个 Star**

**Made with ❤️ by 小屋**