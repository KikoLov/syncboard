<div align="center">

  ![SyncBoard Logo](docs/logo.png)

  # 📊 SyncBoard

  ### **实时协作任务管理平台**

  ![Java](https://img.shields.io/badge/Java-17-orange)
  ![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.1.8-green)
  ![MySQL](https://img.shields.io/badge/MySQL-8.0-blue)
  ![Redis](https://img.shields.io/badge/Redis-6.x-red)
  ![License](https://img.shields.io/badge/License-MIT-yellow)

  [![Stars](https://img.shields.io/github/stars/yourusername/syncboard?style=social)](https://github.com/yourusername/syncboard/stargazers)
  [![Forks](https://img.shields.io/github/forks/yourusername/syncboard?style=social)](https://github.com/yourusername/syncboard/network/members)
  [![Issues](https://img.shields.io/github/issues/yourusername/syncboard)](https://github.com/yourusername/syncboard/issues)

  **一个现代化的实时协作看板应用，支持多人在线、实时同步、任务管理**

  [功能特性](#-核心特性) • [快速开始](#-快速开始) • [技术栈](#-技术栈) • [API 文档](#-api-文档) • [贡献指南](#-贡献指南)

</div>

---

## 📖 项目简介

SyncBoard 是一个基于 Spring Boot 和 WebSocket 的实时协作任务管理平台，类似于 Trello 的看板应用。它支持多人实时协作、任务拖拽排序、在线状态同步等功能，适用于团队项目管理、敏捷开发等场景。

### ✨ 核心亮点

- 🚀 **实时协作**：基于 WebSocket + Redis 发布订阅，毫秒级数据同步
- 🎯 **拖拽排序**：采用 Fractional Indexing 算法，支持任意位置插入
- 🔒 **并发控制**：乐观锁机制，避免多人同时修改导致的数据冲突
- 👥 **在线感知**：实时显示在线用户，支持心跳检测
- 📱 **响应式设计**：支持桌面端和移动端访问
- 🎨 **现代化 UI**：渐变背景、流畅动画、优雅交互

---

## 🎬 在线演示

> 📢 **部署地址**：http://60.205.140.97:8080/api/login.html

**测试账号**：
- 用户名：`root`
- 密码：`EA7music666`

或自行注册新账号体验。

---

## 🚀 快速开始

### 前置要求

- JDK 17+
- Maven 3.6+
- MySQL 8.0+
- Redis 6.0+

### 1️⃣ 克隆项目

```bash
git clone https://github.com/KikoLov/syncboard.git
cd syncboard
```

### 2️⃣ 初始化数据库

```bash
# 创建数据库
mysql -u root -p -e "CREATE DATABASE syncboard CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 导入数据
mysql -u root -p syncboard < database/init.sql
```

### 3️⃣ 修改配置

编辑 `src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/syncboard
    username: root
    password: EA7music666
  data:
    redis:
      host: localhost
      port: 6379
```

### 4️⃣ 启动应用

```bash
# 方式一：使用 Maven
mvn spring-boot:run

# 方式二：打包运行
mvn clean package
java -jar target/syncboard-1.0.0.jar
```

### 5️⃣ 访问应用

打开浏览器访问：http://60.205.140.97:8080/api/login.html

---

## 🎯 核心特性

### 功能列表

| 功能 | 描述 | 状态 |
|------|------|------|
| 用户认证 | 注册、登录、退出、会话管理 | ✅ |
| 看板管理 | 创建、编辑、删除看板 | ✅ |
| 任务管理 | 创建、编辑、删除、拖拽任务 | ✅ |
| 优先级设置 | 高/中/低优先级，颜色标识 | ✅ |
| 实时协作 | WebSocket 实时数据同步 | ✅ |
| 在线统计 | 显示在线用户和人数 | ✅ |
| 操作日志 | 记录所有操作历史 | ✅ |
| 响应式设计 | 支持桌面端和移动端 | ✅ |

### 核心实现

#### 1. 拖拽排序算法（Fractional Indexing）

使用浮点数作为排序序号，移动卡片时计算中间值，避免重排整个列表。

```java
// 计算新序号 = (前序号 + 后序号) / 2
BigDecimal newSortOrder = previousOrder.add(nextOrder)
    .divide(BigDecimal.valueOf(2), SCALE, RoundingMode.HALF_UP);
```

#### 2. 乐观锁并发控制

通过 `@Version` 注解实现乐观锁，避免并发冲突。

```java
@Version
private Integer version;
```

#### 3. Redis 分布式广播

多实例部署时，通过 Redis Pub/Sub 实现实时消息广播。

```
用户A操作 → Server1 → Redis Pub/Sub → Server1/2/3 → WebSocket推送
```

---

## 🛠️ 技术栈

### 后端技术

| 技术 | 版本 | 说明 |
|------|------|------|
| Java | 17 | 编程语言 |
| Spring Boot | 3.1.8 | 应用框架 |
| Spring WebSocket | - | WebSocket 支持 |
| MyBatis-Plus | 3.5.7 | ORM 框架 |
| MySQL | 8.0 | 关系数据库 |
| Redis | 6.x | 缓存/消息队列 |
| Druid | - | 数据库连接池 |
| FastJSON2 | - | JSON 处理 |

### 前端技术

| 技术 | 说明 |
|------|------|
| HTML5 + CSS3 | 页面结构和样式 |
| JavaScript (ES6+) | 交互逻辑 |
| Drag and Drop API | 拖拽功能 |
| Fetch API | HTTP 请求 |
| WebSocket API | 实时通信 |
| LocalStorage | 本地存储 |

---

## 📁 项目结构

```
SyncBoard/
├── docs/                          # 项目文档
│   ├── api.md                     # API 文档
│   ├── deployment.md              # 部署指南
│   └── architecture.md            # 架构设计
├── database/                      # 数据库脚本
│   └── init.sql                   # 初始化脚本
├── src/main/
│   ├── java/com/syncboard/
│   │   ├── config/                # 配置类
│   │   │   ├── WebSocketConfig.java
│   │   │   ├── RedisConfig.java
│   │   │   └── MyBatisPlusConfig.java
│   │   ├── controller/            # REST API
│   │   │   ├── UserController.java
│   │   │   ├── BoardController.java
│   │   │   └── TaskController.java
│   │   ├── dto/                   # 数据传输对象
│   │   ├── entity/                # 实体类
│   │   ├── mapper/                # MyBatis Mapper
│   │   ├── service/               # 业务逻辑
│   │   ├── redis/                 # Redis 发布订阅
│   │   ├── util/                  # 工具类
│   │   └── websocket/             # WebSocket 处理
│   └── resources/
│       ├── application.yml        # 应用配置
│       └── static/                # 静态资源
│           ├── login.html
│           ├── index.html
│           └── register.html
├── .gitignore                     # Git 忽略文件
├── LICENSE                        # 开源协议
├── README.md                      # 项目说明
└── pom.xml                        # Maven 配置
```

---

## 📡 API 文档

### 用户认证

```http
POST /api/users/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123"
}
```

```http
POST /api/users/login
Content-Type: application/json

{
  "username": "testuser",
  "password": "password123"
}
```

### 任务管理

```http
POST /api/tasks
Content-Type: application/json

{
  "boardId": 1,
  "columnId": 1,
  "title": "新任务",
  "description": "任务描述",
  "priority": 2
}
```

```http
POST /api/tasks/move
Content-Type: application/json

{
  "taskId": 1,
  "targetColumnId": 2,
  "previousOrderId": "0.5000000000",
  "nextOrderId": "0.6000000000",
  "version": 1
}
```

### WebSocket 连接

```
ws://60.205.140.97:8080/api/ws
```

订阅看板更新：

```
SUBSCRIBE
destination:/topic/board/1
```

详细 API 文档请查看：[docs/api.md](docs/api.md)

---

## 🗄️ 数据库设计

### 核心表结构

| 表名 | 说明 | 关键字段 |
|------|------|----------|
| `sys_user` | 用户表 | id, username, password, avatar_url |
| `sb_board` | 看板表 | id, name, owner_id, is_public |
| `sb_column` | 任务列表 | id, board_id, name, sort_order |
| `sb_task` | 任务卡片 | id, column_id, title, sort_order, version |
| `sb_activity_log` | 操作日志 | id, board_id, action_type, details |

### ER 图

详见：[docs/architecture.md](docs/architecture.md)

---

## 🚀 部署指南

### Docker 部署

```bash
# 构建镜像
docker build -t syncboard:latest .

# 运行容器
docker run -d \
  -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://host.docker.internal:3306/syncboard \
  -e SPRING_DATASOURCE_PASSWORD=your_password \
  syncboard:latest
```

### 传统部署

详见：[docs/deployment.md](docs/deployment.md)

---

## 🤝 贡献指南

欢迎贡献代码！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详情。

### 开发流程

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

---

## 📝 更新日志

### v1.0.0 (2026-01-31)

✨ **新功能**
- 用户注册/登录功能
- 看板管理功能
- 任务创建/编辑/删除
- 拖拽排序功能
- 实时协作功能
- 在线用户统计

🐛 **Bug 修复**
- 修复并发冲突问题
- 修复 WebSocket 连接断开问题

📚 **文档**
- 添加 API 文档
- 添加部署指南

---

## ❓ 常见问题

<details>
<summary><b>Q: 启动时提示连接数据库失败？</b></summary>

**A:** 请检查 MySQL 是否启动，用户名密码是否正确，数据库是否已创建。
</details>

<details>
<summary><b>Q: WebSocket 连接失败？</b></summary>

**A:** 请检查 Redis 是否启动，Redis 配置是否正确。
</details>

<details>
<summary><b>Q: 拖拽任务时提示版本冲突？</b></summary>

**A:** 说明该任务已被其他用户修改，请刷新页面后重试。
</details>

更多问题请查看：[docs/faq.md](docs/faq.md)

---

## 📄 开源协议

本项目基于 [MIT License](LICENSE) 开源。

---

## 👥 作者

**你的名字** - [@yourusername](https://github.com/yourusername)

- 邮箱：your.email@example.com
- 个人主页：https://yourwebsite.com

---

## 🙏 致谢

- [Spring Boot](https://spring.io/projects/spring-boot)
- [MyBatis-Plus](https://baomidou.com/)
- [WebSocket](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)
- [Redis](https://redis.io/)

---

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/syncboard&type=Date)](https://star-history.com/#yourusername/syncboard&Date)

---

<div align="center">

**如果这个项目对你有帮助，请给一个 ⭐**

**Made with ❤️ by [kiko]**

</div>
