# SyncBoard 使用手册

## 📖 目录

1. [平台简介](#平台简介)
2. [快速启动](#快速启动)
3. [核心功能](#核心功能)
4. [API 接口文档](#api-接口文档)
5. [WebSocket 实时通信](#websocket-实时通信)
6. [使用���例](#使用示例)
7. [常见问题](#常见问题)

---

## 平台简介

**SyncBoard** 是一个模仿 Trello/飞书看板的实时协作任务管理平台，支持多用户同时在同一看板内创建、拖拽和编辑任务卡片，所有操作在毫秒级内同步。

### 核心特性

- ✅ **实时协作**: 基于 WebSocket (STOMP) 协议，实现毫秒级同步
- ✅ **分布式架构**: 使用 Redis Pub/Sub 支持多实例部署
- ✅ **拖拽排序**: 采用 Fractional Indexing 算法，避免重排数据库
- ✅ **并发控制**: 乐观锁机制，防止数据冲突
- ✅ **在线感知**: 实时显示看板在线用户

---

## 快速启动

### 前置条件

确���以下服务已启动：

| 服务 | 状态检查 | 端口 |
|------|----------|------|
| MySQL | `mysql -u root -p` | 3306 |
| Redis | `redis-cli ping` | 6379 |

### 启动后端服务

```bash
cd c:\projects\SyncBoard
mvn spring-boot:run
```

启动成功后会看到：

```
===================================
   🚀 SyncBoard 启动成功！
   实时协作任务平台运行中...
   WebSocket: ws://localhost:8080/api/ws
   API文档: http://localhost:8080/api
===================================
```

### 访问地址

- **API 基础路径**: http://localhost:8080/api
- **WebSocket**: ws://localhost:8080/api/ws
- **Druid 监控**: http://localhost:8080/api/druid

---

## 核心功能

### 1. 看板管理

#### 1.1 获取看板详情

获取看板的完整信息，包括列、任务和在线用户数。

**请求**
```
GET /api/boards/{id}
```

**响应示例**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "board": {
      "id": 1,
      "name": "项目开发看板",
      "description": "SyncBoard项目开发任务管理",
      "ownerId": 1,
      "isPublic": 0,
      "backgroundColor": "#0079BF"
    },
    "columns": [
      {
        "id": 1,
        "boardId": 1,
        "name": "待处理",
        "color": "#F4F5F7",
        "sortOrder": 0.0000000001
      }
    ],
    "tasks": [
      {
        "id": 1,
        "boardId": 1,
        "columnId": 1,
        "title": "设计数据库表结构",
        "description": "完成MySQL数据库表设计",
        "assigneeId": 2,
        "priority": 3,
        "version": 0
      }
    ],
    "onlineUserCount": 3
  }
}
```

#### 1.2 创建看板

**请求**
```
POST /api/boards
Content-Type: application/json

{
  "name": "我的看板",
  "description": "项目描述",
  "ownerId": 1,
  "isPublic": 0,
  "backgroundColor": "#0079BF"
}
```

#### 1.3 创建任务列

**请求**
```
POST /api/boards/{boardId}/columns
Content-Type: application/json

{
  "name": "进行中",
  "color": "#EBECF0",
  "sortOrder": 0.0000000002,
  "position": 1
}
```

#### 1.4 获取在线用户

获取当前看板的在线用户列表。

**请求**
```
GET /api/boards/{id}/online-users
```

**响应示例**
```json
{
  "code": 200,
  "data": {
    "1": {
      "userId": 1,
      "username": "张三",
      "joinedAt": "2026-01-31T15:30:00"
    },
    "2": {
      "userId": 2,
      "username": "李四",
      "joinedAt": "2026-01-31T15:31:00"
    }
  }
}
```

#### 1.5 获取在线用户数

**请求**
```
GET /api/boards/{id}/online-count
```

**响应示例**
```json
{
  "code": 200,
  "data": 3
}
```

---

### 2. 任务管理

#### 2.1 创建任务

**请求**
```
POST /api/tasks
Content-Type: application/json

{
  "boardId": 1,
  "columnId": 1,
  "title": "实现用户登录功能",
  "description": "使用 JWT 实现用户认证",
  "assigneeId": 2,
  "priority": 3,
  "labels": ["前端", "后端"],
  "dueDate": "2026-02-15T18:00:00"
}
```

**优先级说明**
- `1`: 低
- `2`: 中
- `3`: 高
- `4`: 紧急

#### 2.2 更新任务

**请求**
```
PUT /api/tasks/{id}
Content-Type: application/json

{
  "title": "实现用户登录功能（更新）",
  "description": "使用 JWT + Spring Security",
  "version": 0
}
```

**注意**: `version` 字段用于乐观锁，必须提供当前版本号。

#### 2.3 移动任务（拖拽）

这是 SyncBoard 的核心功能，支持拖拽任务到不同位置。

**请求**
```
POST /api/tasks/move
Content-Type: application/json

{
  "taskId": 1,
  "targetColumnId": 2,
  "previousSortOrder": 0.1,
  "nextSortOrder": 0.3,
  "version": 0
}
```

**参数说明**
- `taskId`: 要移动的任务ID
- `targetColumnId`: 目标列ID（在同一列内移动则为当前列ID）
- `previousSortOrder`: 前一个任务的 sort_order
- `nextSortOrder`: 后一个任务的 sort_order
- `version`: 当前任务版本号（乐观锁）

**特殊情况处理**
- 移动到列表开头：`previousSortOrder` 为 `null`
- 移动到列表末尾：`nextSortOrder` 为 `null`

#### 2.4 删除任务

**请求**
```
DELETE /api/tasks/{id}
```

#### 2.5 获取看板的所有任务

**请求**
```
GET /api/tasks/board/{boardId}
```

#### 2.6 获取任务详情

**请求**
```
GET /api/tasks/{id}
```

---

### 3. 并发冲突处理

当多个用户同时修改同一任务时，SyncBoard 使用乐观锁机制保证数据一致性。

**冲突检测流程**

1. 客户端获取任务时获得 `version` 字段
2. 更新任务时提交当前 `version`
3. 服务端检查版本是否匹配
4. 匹配则更新并递增版本
5. 不匹配返回 `409 CONFLICT` 错误

**冲突响应示例**
```json
{
  "code": 409,
  "message": "任务已被其他用户修改，请刷新后重试"
}
```

**客户端处理建议**
```javascript
try {
  await updateTask(taskId, data);
} catch (error) {
  if (error.code === 409) {
    // 显示冲突提示
    alert('任务已被其他用户修改，正在刷新...');

    // 刷新任务数据
    const latestTask = await getTask(taskId);

    // 自动填充表单或显示最新数据
    showTaskInEditor(latestTask);
  }
}
```

---

## WebSocket 实时通信

### 连接 WebSocket

```javascript
const ws = new WebSocket('ws://localhost:8080/api/ws');

ws.onopen = () => {
  console.log('WebSocket 连接成功');
};
```

### STOMP 协议（推荐）

```javascript
// 使用 SockJS + STOMP
const socket = new SockJS('http://localhost:8080/api/ws');
const stompClient = Stomp.over(socket);

stompClient.connect({}, (frame) => {
  console.log('STOMP 连接成功:', frame);

  // 订阅看板消息
  stompClient.subscribe('/topic/board/1', (message) => {
    const data = JSON.parse(message.body);
    handleBoardUpdate(data);
  });
});
```

### 消息类型

#### 1. 任务移动事件

```json
{
  "eventType": "TASK_MOVE",
  "boardId": 1,
  "payload": {
    "id": 1,
    "columnId": 2,
    "sortOrder": 0.15,
    "version": 1
  },
  "operatorId": 2,
  "operatorName": "张三",
  "timestamp": "2026-01-31T15:30:00"
}
```

#### 2. 任务更新事件

```json
{
  "eventType": "TASK_UPDATE",
  "boardId": 1,
  "payload": {
    "id": 1,
    "title": "新标题",
    "version": 2
  },
  "operatorId": 2,
  "operatorName": "张三",
  "timestamp": "2026-01-31T15:30:00"
}
```

#### 3. 任务创建事件

```json
{
  "eventType": "TASK_CREATE",
  "boardId": 1,
  "payload": {
    "id": 5,
    "columnId": 1,
    "title": "新任务",
    "sortOrder": 0.5
  },
  "operatorId": 2,
  "operatorName": "张三",
  "timestamp": "2026-01-31T15:30:00"
}
```

#### 4. 任务删除事件

```json
{
  "eventType": "TASK_DELETE",
  "boardId": 1,
  "payload": {
    "id": 1
  },
  "operatorId": 2,
  "operatorName": "张三",
  "timestamp": "2026-01-31T15:30:00"
}
```

#### 5. 用户上线事件

```json
{
  "eventType": "USER_PRESENCE",
  "boardId": 1,
  "payload": {
    "action": "JOIN",
    "user": {
      "userId": 2,
      "username": "张三"
    }
  },
  "timestamp": "2026-01-31T15:30:00"
}
```

### 客户端消息处理

```javascript
function handleBoardUpdate(message) {
  switch (message.eventType) {
    case 'TASK_MOVE':
      // 局部更新：只更新移动的任务
      updateTaskPosition(message.payload);
      showNotification(`${message.operatorName} 移动了任务`);
      break;

    case 'TASK_UPDATE':
      // 局部更新：只更新变化的字段
      updateTaskFields(message.payload);
      break;

    case 'TASK_CREATE':
      // 添加新任务到列表
      addTaskToList(message.payload);
      showNotification(`${message.operatorName} 创建了新任务`);
      break;

    case 'TASK_DELETE':
      // 从列表移除任务
      removeTaskFromList(message.payload.id);
      showNotification(`${message.operatorName} 删除了任务`);
      break;

    case 'USER_PRESENCE':
      // 更新在线用户列表
      if (message.payload.action === 'JOIN') {
        addUserToOnlineList(message.payload.user);
      } else if (message.payload.action === 'LEAVE') {
        removeUserFromOnlineList(message.payload.user.userId);
      }
      break;
  }
}
```

---

## 使用示例

### 示例 1: 创建完整看板

```bash
# 1. 创建看板
curl -X POST http://localhost:8080/api/boards \
  -H "Content-Type: application/json" \
  -d '{
    "name": "项目开发看板",
    "description": "SyncBoard 项目管理",
    "ownerId": 1
  }'

# 2. 创建列
curl -X POST http://localhost:8080/api/boards/1/columns \
  -H "Content-Type: application/json" \
  -d '{
    "name": "待处理",
    "color": "#F4F5F7",
    "sortOrder": 0.0000000001
  }'

curl -X POST http://localhost:8080/api/boards/1/columns \
  -H "Content-Type: application/json" \
  -d '{
    "name": "进行中",
    "color": "#EBECF0",
    "sortOrder": 0.0000000002
  }'

# 3. 创建任务
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "boardId": 1,
    "columnId": 1,
    "title": "设计数据库表结构",
    "description": "完成 MySQL 数据库表设计",
    "assigneeId": 1,
    "priority": 3
  }'
```

### 示例 2: 拖拽任务到不同列

```bash
# 将任务 1 从列 1 移动到列 2
curl -X POST http://localhost:8080/api/tasks/move \
  -H "Content-Type: application/json" \
  -d '{
    "taskId": 1,
    "targetColumnId": 2,
    "previousSortOrder": null,
    "nextSortOrder": null,
    "version": 0
  }'
```

### 示例 3: JavaScript 客户端完整示例

```javascript
class SyncBoardClient {
  constructor(baseUrl = 'http://localhost:8080/api') {
    this.baseUrl = baseUrl;
    this.stompClient = null;
  }

  // 连接 WebSocket
  connectWebSocket() {
    const socket = new SockJS(`${this.baseUrl}/ws`);
    this.stompClient = Stomp.over(socket);

    return new Promise((resolve, reject) => {
      this.stompClient.connect({}, resolve, reject);
    });
  }

  // 订阅看板
  subscribeToBoard(boardId, callback) {
    this.stompClient.subscribe(`/topic/board/${boardId}`, (message) => {
      const data = JSON.parse(message.body);
      callback(data);
    });
  }

  // 获取看板数据
  async getBoard(boardId) {
    const response = await fetch(`${this.baseUrl}/boards/${boardId}`);
    return response.json();
  }

  // 创建任务
  async createTask(taskData) {
    const response = await fetch(`${this.baseUrl}/tasks`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(taskData)
    });
    return response.json();
  }

  // 移动任务
  async moveTask(taskId, targetColumnId, prevOrder, nextOrder, version) {
    const response = await fetch(`${this.baseUrl}/tasks/move`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        taskId,
        targetColumnId,
        previousSortOrder: prevOrder,
        nextSortOrder: nextOrder,
        version
      })
    });
    return response.json();
  }
}

// 使用示例
const client = new SyncBoardClient();

// 连接并订阅
await client.connectWebSocket();
client.subscribeToBoard(1, (message) => {
  console.log('收到更新:', message);
  handleBoardUpdate(message);
});

// 加载看板
const board = await client.getBoard(1);
console.log('看板数据:', board);
```

---

## 常见问题

### Q1: 如何测试实时协作功能？

**方法 1: 使用两个浏览器窗口**

1. 在浏览器 A 中打开 http://localhost:8080/api
2. 在浏览器 B 中打开相同的地址
3. 在窗口 A 中移动任务
4. 窗口 B 应该立即看到变化

**方法 2: 使用 Postman/curl + WebSocket 客户端**

1. 使用 Postman 创建任务
2. 使用 WebSocket 客户端订阅看板
3. 观察 WebSocket 接收到的实时消息

### Q2: 如何处理并发冲突？

当收到 409 错误时：

1. **显示冲突提示**: "任务已被其他用户修改"
2. **刷新数据**: 重新获取任务最新信息
3. **提示用户**: 决定是否继续修改或放弃

```javascript
async function safeUpdateTask(taskId, updates) {
  try {
    const result = await client.updateTask(taskId, updates);
    return result;
  } catch (error) {
    if (error.code === 409) {
      const latest = await client.getTask(taskId);

      if (confirm(`任务已被修改，是否继续？\n最新内容: ${latest.title}`)) {
        // 使用最新版本号重试
        updates.version = latest.version;
        return client.updateTask(taskId, updates);
      } else {
        throw new Error('用户取消操作');
      }
    }
    throw error;
  }
}
```

### Q3: Fractional Indexing 算法原理？

**核心思想**: 使用浮点数作为排序序号，移动时计算中间值。

```
原始列表: [0.1, 0.2, 0.3]
在 0.2 和 0.3 之间插入: (0.2 + 0.3) / 2 = 0.25
新列表: [0.1, 0.2, 0.25, 0.3]
```

**优点**:
- 不需要重排整个列表
- 支持任意位置插入
- 只需单次数据库更新

### Q4: 如何监控服务状态？

访问 Druid 监控页面：http://localhost:8080/api/druid

可以看到：
- SQL 执行统计
- 慢查询日志
- 数据库连接池状态

### Q5: 数据库表结构说明

| 表名 | 说明 | 关键字段 |
|------|------|----------|
| `sys_user` | 用户表 | id, username, password, avatar_url |
| `sb_board` | 看板表 | id, name, owner_id, is_public |
| `sb_column` | 任务列表 | id, board_id, name, **sort_order (DECIMAL)** |
| `sb_task` | 任务卡片 | id, board_id, column_id, **sort_order (DECIMAL)**, **version (INT)** |
| `sb_activity_log` | 操作日志 | id, board_id, task_id, action_type, details |

### Q6: 如何停止服务？

在运行 Maven 的终端按 `Ctrl + C` 停止服务。

---

## 数据库初始化

如果需要重新初始化数据库：

```bash
mysql -u root -pEA7music666 < c:\projects\SyncBoard\init_db_fixed.sql
```

---

## 技术支持

- **项目地址**: c:\projects\SyncBoard
- **后端端口**: 8080
- **数据库**: MySQL 8.0+
- **缓存**: Redis 6.0+

---

## 版本信息

- **Spring Boot**: 3.1.8
- **JDK**: 17.0.17
- **MyBatis-Plus**: 3.5.7
- **WebSocket**: STOMP 协议

---

*最后更新时间: 2026-01-31*
