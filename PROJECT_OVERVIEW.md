# SyncBoard 项目总览

## 📂 项目文件结构

### 🗄️ 数据库层
- `src/main/resources/sql/init.sql` - 数据库初始化脚本（包含表结构、测试数据、存储过程）

### ⚙️ 配置文件
- `pom.xml` - Maven 依赖配置
- `src/main/resources/application.yml` - 应用配置文件
- `DATABASE_SETUP.md` - 数据库初始化说明

### 📦 实体类 (Entity)
- `src/main/java/com/syncboard/entity/User.java` - 用户实体
- `src/main/java/com/syncboard/entity/Board.java` - 看板实体
- `src/main/java/com/syncboard/entity/Column.java` - 任务列实体
- `src/main/java/com/syncboard/entity/Task.java` - 任务实体（包含 @Version 乐观锁）
- `src/main/java/com/syncboard/entity/ActivityLog.java` - 活动日志实体

### 🗺️ 数据访问层 (Mapper)
- `src/main/java/com/syncboard/mapper/UserMapper.java`
- `src/main/java/com/syncboard/mapper/BoardMapper.java`
- `src/main/java/com/syncboard/mapper/ColumnMapper.java`
- `src/main/java/com/syncboard/mapper/TaskMapper.java`
- `src/main/java/com/syncboard/mapper/ActivityLogMapper.java`

### ⚙️ 配置类 (Config)
- `src/main/java/com/syncboard/config/WebSocketConfig.java` - WebSocket STOMP 配置
- `src/main/java/com/syncboard/config/RedisConfig.java` - Redis 配置
- `src/main/java/com/syncboard/config/MyBatisPlusConfig.java` - MyBatis-Plus 配置（乐观锁插件）

### 💼 服务层 (Service)

#### 核心业务服务
- `src/main/java/com/syncboard/service/TaskService.java`
  - 创建/更新/删除任务
  - **拖拽排序逻辑**（核心功能）
  - **乐观锁并发控制**

- `src/main/java/com/syncboard/service/WebSocketService.java`
  - WebSocket 消息分发
  - 用户在线状态广播

- `src/main/java/com/syncboard/service/PresenceService.java`
  - **在线状态感知**（Presence Engine）
  - 使用 Redis Hash 存储在线用户

### 🌐 Redis 发布订阅 (Redis Pub/Sub)
- `src/main/java/com/syncboard/redis/RedisPublisher.java` - Redis 发布者
- `src/main/java/com/syncboard/redis/RedisSubscriber.java` - Redis 订阅者
- `src/main/java/com/syncboard/redis/RedisChannelManager.java` - Redis 频道管理

### 📡 WebSocket 事件处理
- `src/main/java/com/syncboard/websocket/WebSocketEventListener.java`
  - 处理用户连接/断开事件
  - 处理用户订阅/取消订阅事件

### 🎮 控制器 (Controller)
- `src/main/java/com/syncboard/controller/TaskController.java` - 任务 API
- `src/main/java/com/syncboard/controller/BoardController.java` - 看板 API

### 🔧 工具类 (Util)
- `src/main/java/com/syncboard/util/FractionalIndexingUtil.java`
  - **拖拽排序算法**（Fractional Indexing）
  - 计算任务在列表中的位置

### 📦 数据传输对象 (DTO)
- `src/main/java/com/syncboard/dto/Result.java` - 统一响应结果
- `src/main/java/com/syncboard/dto/TaskMoveDTO.java` - 任务移动请求
- `src/main/java/com/syncboard/dto/WebSocketMessageDTO.java` - WebSocket 消息格式

### 📱 Flutter 客户端
- `flutter_client/pubspec.yaml` - Flutter 依赖配置
- `flutter_client/lib/main.dart` - 应用入口
- `flutter_client/lib/board_screen.dart` - 看板页面（包含局部刷新逻辑）
- `flutter_client/lib/websocket_manager.dart` - WebSocket 管理器

### 🚀 启动脚本
- `start.bat` - Windows 快速启动脚本

## 🔑 核心功能实现位置

### 1. 拖拽排序算法 (Fractional Indexing)
**文件**: `FractionalIndexingUtil.java`

核心逻辑：
```java
// 新序号 = (前序号 + 后序号) / 2
BigDecimal newSortOrder = previousOrder.add(nextOrder)
    .divide(BigDecimal.valueOf(2), SCALE, RoundingMode.HALF_UP);
```

### 2. 乐观锁并发控制
**实体**: `Task.java` (第 54 行)
```java
@Version
private Integer version;
```

**服务**: `TaskService.java` (第 63-89 行)
```java
if (!existingTask.getVersion().equals(task.getVersion())) {
    return Result.conflict("任务已被其他用户修改");
}
```

### 3. WebSocket 消息分发
**配置**: `WebSocketConfig.java`
**服务**: `WebSocketService.java`

消息流程：
```
用户操作 → TaskService → WebSocketService.broadcastToBoard()
         ↓
RedisPublisher.publish() → Redis Pub/Sub
         ↓
RedisSubscriber.onMessage() → WebSocketService.sendToBoard()
         ↓
StompMessagingTemplate.convertAndSend("/topic/board/{id}")
```

### 4. Redis 分布式广播
**文件**:
- `RedisPublisher.java` - 发布消息到 Redis 频道
- `RedisSubscriber.java` - 监听 Redis 频道并转发到 WebSocket
- `RedisChannelManager.java` - 管理频道订阅

频道格式：`syncboard:board:{boardId}`

### 5. 在线状态感知 (Presence Engine)
**文件**: `PresenceService.java`

Redis 数据结构：
```
Key: syncboard:presence:{boardId}
Type: Hash
Fields: { userId → { userId, username, joinedAt } }
TTL: 300 seconds (5 分钟)
```

触发时机：
- 用户订阅看板频道 → `userJoined()`
- 用户断开连接 → `userLeft()`
- 定期心跳 → `heartbeat()`

### 6. Flutter 局部刷新
**文件**: `flutter_client/lib/board_screen.dart`

核心逻辑：
```dart
_wsManager.messageStream.listen((message) {
  switch (message['eventType']) {
    case 'TASK_MOVE':
      // 只更新移动的任务，不重新加载整个列表
      final index = _tasks.indexWhere((t) => t['id'] == payload['id']);
      setState(() {
        _tasks[index] = payload;
      });
  }
});
```

## 📊 数据库表关系

```
sys_user (用户)
    ↓ 1:N
sb_board (看板)
    ↓ 1:N         ↓ 1:N
sb_column (列)   sb_board_member (成员)
    ↓ 1:N
sb_task (任务)
    ↓ 1:N
sb_activity_log (活动日志)
```

## 🌐 API 端点

| 功能 | 方法 | 路径 |
|------|------|------|
| 创建任务 | POST | `/api/tasks` |
| 更新任务 | PUT | `/api/tasks/{id}` |
| 移动任务 | POST | `/api/tasks/move` |
| 删除任务 | DELETE | `/api/tasks/{id}` |
| 获取看板任务 | GET | `/api/tasks/board/{boardId}` |
| 获取看板详情 | GET | `/api/boards/{id}` |
| 获取在线用户 | GET | `/api/boards/{id}/online-users` |
| WebSocket 连接 | WS | `/api/ws` |

## 🚦 启动流程

1. **启动 MySQL**
   ```cmd
   net start MySQL80
   ```

2. **初始化数据库**
   - 使用 MySQL Workbench 执行 `init.sql`
   - 或参考 `DATABASE_SETUP.md`

3. **启动 Redis**
   ```cmd
   redis-server
   ```

4. **启动后端**
   - 双击 `start.bat`
   - 或运行 `mvn spring-boot:run`

5. **运行 Flutter 客户端**（可选）
   ```cmd
   cd flutter_client
   flutter pub get
   flutter run
   ```

## 🧪 测试数据

初始化脚本已包含测试数据：
- 3 个用户（admin, user1, user2）
- 2 个看板
- 3 个任务列（待处理、进行中、已完成）
- 4 个测试任务

## 📖 相关文档

- `README.md` - 项目说明和使用指南
- `DATABASE_SETUP.md` - 数据库初始化说明
- `PROJECT_OVERVIEW.md` - 本文件

## ⚡ 性能优化点

1. **拖拽排序**: 使用 Fractional Indexing，O(1) 复杂度
2. **并发控制**: 乐观锁避免锁等待
3. **分布式**: Redis Pub/Sub 实现多实例水平扩展
4. **缓存**: Redis 缓存在线用户，减少数据库查询
5. **局部刷新**: Flutter 只更新变化的任务，避免全量刷新

## 🔒 安全建议

1. 添加 Spring Security + JWT 认证
2. 限制 WebSocket 跨域来源
3. 输入参数验证（@Valid）
4. 敏感信息加密存储
5. 添加操作审计日志

## 📝 许可证

MIT License
