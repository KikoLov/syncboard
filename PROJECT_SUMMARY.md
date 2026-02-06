# SyncBoard - 项目摘要

## 🎯 项目概述

**SyncBoard** 是一个企业级的实时协作任务管理��台，灵感来源于 Trello 和飞书看板。这是一个**完整的全栈项目**，展示了现代化 Web 应用的开发能力。

### 核心亮点

- ⚡ **毫秒级实时同步**：基于 WebSocket (STOMP) 协议
- 🔄 **分布式架构**：Redis Pub/Sub 支持多实例部署
- 🎨 **拖拽排序**：Fractional Indexing 算法，避免重排数据库
- 🔒 **并发控制**：乐观锁机制，防止数据冲突
- 👥 **在线感知**：实时显示看板在线用户
- 💅 **现代化 UI**：响应式设计，流畅的动画效果

---

## 🏗️ 技术架构

### 后端技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| **Spring Boot** | 3.1.8 | 核心框架 |
| **JDK** | 17 | 运行环境 |
| **WebSocket + STOMP** | - | 实时通信 |
| **Redis** | 6.0+ | Pub/Sub + 分布式缓存 |
| **MySQL** | 8.0+ | 主数据库 |
| **MyBatis-Plus** | 3.5.7 | ORM 框架 |
| **Druid** | 1.2.22 | 数据库连接池 |

### 前端技术栈

| 技术 | 用途 |
|------|------|
| **HTML5 + CSS3** | 页面结构和样式 |
| **Vanilla JavaScript** | 交互逻辑 |
| **Drag & Drop API** | 拖拽功能 |
| **Fetch API** | HTTP 请求 |
| **CSS Grid/Flexbox** | 响应式布局 |

---

## 🚀 快速开始

### 1. 环境准备

确保已安装：
- JDK 17+
- Maven 3.6+
- MySQL 8.0+
- Redis 6.0+

### 2. 数据库初始化

```bash
# 连接 MySQL
mysql -u root -p

# 执行初始化脚本
source c:/projects/SyncBoard/init_db_fixed.sql
```

### 3. 启动后端服务

```bash
cd c:/projects/SyncBoard
mvn spring-boot:run
```

### 4. 访问应用

打开浏览器访问：**http://localhost:8080**

---

## 💡 核心功能详解

### 1. 实时协作 (WebSocket)

**技术难点**：多用户同时操作时的数据一致性

**解决方案**：
- 使用 STOMP 协议实现发布-订阅模式
- Redis Pub/Sub 实现跨实例消息广播
- 每个看板独立频道：`/topic/board/{boardId}`

**代码示例**：
```java
@MessageMapping("/task/move")
public void moveTask(TaskMoveDTO dto) {
    taskService.moveTask(dto);
    // 通过 Redis 广播到所有实例
    redisPublisher.publish(boardId, message);
}
```

### 2. 拖拽排序算法 (Fractional Indexing)

**技术难点**：避免拖拽时重排整个列表

**解决方案**：
- 使用 DECIMAL 类型存储 sort_order
- 计算公式：`new_order = (prev_order + next_order) / 2`
- 只需单次数据库更新

**算法演示**：
```
原始: [0.1, 0.2, 0.3]
在 0.2 和 0.3 之间插入: (0.2 + 0.3) / 2 = 0.25
结果: [0.1, 0.2, 0.25, 0.3]
```

**性能对比**：
| 方案 | 时间复杂度 | 数据库操作 |
|------|-----------|-----------|
| 传统方式 | O(n) | 更新所有后续记录 |
| Fractional Indexing | O(1) | 只更新当前记录 |

### 3. 乐观锁并发控制

**技术难点**：多用户同时修改同一任务

**解决方案**：
- 使用 `@Version` 注解实现乐观锁
- 前端提交时携带版本号
- 后端校验版本，冲突返回 409

**实现代码**：
```java
@Version
private Integer version;

// 更新前检查版本
if (!existingTask.getVersion().equals(task.getVersion())) {
    return Result.conflict("任务已被其他用户修改，请刷新后重试");
}
```

### 4. 在线用户感知

**技术方案**：
- Redis Hash 存储在线用户：`syncboard:presence:{boardId}`
- 心跳机制：5 分钟超时自动清理
- 实时统计和展示

**数据结构**：
```
Key: syncboard:presence:1
Field: userId
Value: { userId, username, joinedAt }
```

---

## 📊 数据库设计

### ER 图核心关系

```
sys_user (用户) ─┐
                  ├─ sb_board (看板)
sb_column (列) ───┼─ sb_task (任务) ── sb_activity_log (日志)
                  └─ sb_board_member (成员)
```

### 关键表设计

**sb_task (任务表)** - 核心表
```sql
CREATE TABLE sb_task (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    board_id BIGINT NOT NULL,
    column_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    sort_order DECIMAL(20,10) NOT NULL,  -- 支持 Fractional Indexing
    version INT NOT NULL DEFAULT 0,      -- 乐观锁版本号
    priority TINYINT DEFAULT 1,
    INDEX idx_board_column (board_id, column_id),
    INDEX idx_sort (sort_order)
);
```

---

## 🎨 前端界面特性

### UI 设计理念

- **简洁美观**：现代化设计语言，流畅动画
- **直观操作**：拖拽即移动，点击即编辑
- **实时反馈**：操作即时响应，状态实时更新
- **响应式布局**：支持桌面和移动设备

### 交互细节

1. **拖拽动画**：拖拽时卡片旋转 3 度，降低透明度
2. **悬停效果**：卡片悬停时上浮，显示阴影
3. **优先级标识**：左侧彩色边框 + 标签
4. **加载状态**：优雅的加载动画
5. **消息提示**：右下角弹出式通知

---

## 📈 性能优化

### 已实现的优化

1. **数据库层面**
   - 合理的索引设计
   - DECIMAL 类型优化排序计算
   - 外键级联删除

2. **应用层面**
   - Druid 连接池监控
   - Redis 缓存在线用户
   - 异步任务处理 (@EnableAsync)

3. **前端层面**
   - 局部刷新策略
   - 防抖处理频繁操作

---

## 🔧 API 接口文档

### 看板管理

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/boards/{id}` | 获取看板详情 |
| POST | `/api/boards` | 创建看板 |
| GET | `/api/boards/{id}/online-count` | 获取在线人数 |

### 任务管理

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/tasks` | 创建任务 |
| PUT | `/api/tasks/{id}` | 更新任务 |
| POST | `/api/tasks/move` | 移动任务 |
| DELETE | `/api/tasks/{id}` | 删除任务 |

### WebSocket 事件

| 事件 | 说明 |
|------|------|
| TASK_CREATE | 任务创建 |
| TASK_MOVE | 任务移动 |
| TASK_UPDATE | 任务更新 |
| TASK_DELETE | 任务删除 |
| USER_PRESENCE | 用户上下线 |

---

## 🎯 项目亮点（简历用）

### 技术亮点

1. **全栈开发能力**
   - 后端：Spring Boot + WebSocket + Redis
   - 前端：响应式 UI + 拖拽交互
   - 数据库：MySQL + 优化设计

2. **实时通信实现**
   - WebSocket STOMP 协议
   - Redis Pub/Sub 分布式消息
   - 发布-订阅模式设计

3. **算法应用**
   - Fractional Indexing 优化排序
   - 乐观锁解决并发冲突
   - 心跳机制管理在线状态

4. **性能优化**
   - 数据库索引优化
   - Redis 缓存策略
   - 连接池配置

### 解决的问题

- ✅ 多用户实时协作的数据一致性
- ✅ 高并发下的拖拽排序性能
- ✅ 分布式环境下的消息同步
- ✅ 优雅的并发冲突处理

### 可扩展性

- 支持水平扩展（Redis Pub/Sub）
- 模块化设计，易于添加新功能
- RESTful API，支持多端接入

---

## 📝 未来规划

### 短期计划

- [ ] 用户认证系统 (JWT + Spring Security)
- [ ] 文件上传功能
- [ ] 任务评论系统
- [ ] 标签筛选功能

### 长期计划

- [ ] 移动端 App (Flutter)
- [ ] 数据统计分析
- [ ] 权限管理系统 (RBAC)
- [ ] 国际化支持

---

## 👨‍💻 开发者信息

**项目名称**：SyncBoard
**开发时间**：2026年1月
**项目规模**：个人项目
**代码行数**：约 3000+ 行
**开发周期**：2 周

---

## 📞 联系方式

- **GitHub**：[项目地址]
- **演示地址**：[在线演示]
- **技术博客**：[博客地址]

---

*本项目展示了从需求分析、架构设计、编码实现到测试部署的完整软件开发流程。*
