# SyncBoard API 文档

## 基础信息

- **Base URL**: `http://localhost:8080/api`
- **Content-Type**: `application/json`
- **认证方式**: Token（LocalStorage）

---

## 用户认证 API

### 1. 用户注册

**请求**
```http
POST /api/users/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123",
  "nickname": "测试用户"
}
```

**响应**
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "nickname": "测试用户",
    "avatarUrl": "https://api.dicebear.com/7.x/avataaars/svg?seed=testuser"
  }
}
```

### 2. 用户登录

**请求**
```http
POST /api/users/login
Content-Type: application/json

{
  "username": "testuser",
  "password": "password123"
}
```

**响应**
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "testuser",
      "email": "test@example.com",
      "nickname": "测试用户",
      "avatarUrl": "https://api.dicebear.com/7.x/avataaars/svg?seed=testuser"
    }
  }
}
```

### 3. 获取当前用户信息

**请求**
```http
GET /api/users/current
Authorization: Bearer {token}
```

**响应**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "nickname": "测试用户",
    "avatarUrl": "https://api.dicebear.com/7.x/avataaars/svg?seed=testuser"
  }
}
```

---

## 看板管理 API

### 1. 获取看板详情

**请求**
```http
GET /api/boards/{boardId}
```

**响应**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "name": "项目看板",
    "description": "SyncBoard 项目管理",
    "ownerId": 1,
    "isPublic": 0,
    "columns": [
      {
        "id": 1,
        "name": "待办事项",
        "color": "#F4F5F7",
        "sortOrder": "0.0000000001"
      }
    ],
    "tasks": [
      {
        "id": 1,
        "columnId": 1,
        "title": "设计数据库表",
        "description": "完成 MySQL 数据库表结构设计",
        "assigneeId": 2,
        "priority": 3,
        "isCompleted": 0,
        "version": 1
      }
    ]
  }
}
```

### 2. 创建看板

**请求**
```http
POST /api/boards
Content-Type: application/json

{
  "name": "新看板",
  "description": "看板描述",
  "isPublic": 0
}
```

### 3. 创建列

**请求**
```http
POST /api/boards/{boardId}/columns
Content-Type: application/json

{
  "name": "进行中",
  "color": "#EBECF0"
}
```

### 4. 获取在线用户数

**请求**
```http
GET /api/boards/{boardId}/online-count
```

**响应**
```json
{
  "code": 200,
  "data": 5
}
```

### 5. 加入看板

**请求**
```http
POST /api/boards/{boardId}/join?userId={userId}&username={username}
```

### 6. 离开看板

**请求**
```http
POST /api/boards/{boardId}/leave?userId={userId}&username={username}
```

---

## 任务管理 API

### 1. 创建任务

**请求**
```http
POST /api/tasks
Content-Type: application/json

{
  "boardId": 1,
  "columnId": 1,
  "title": "新任务",
  "description": "任务描述",
  "assigneeId": 2,
  "priority": 2,
  "labels": ["前端", "优化"]
}
```

**响应**
```json
{
  "code": 200,
  "message": "创建成功",
  "data": {
    "id": 10,
    "boardId": 1,
    "columnId": 1,
    "title": "新任务",
    "description": "任务描述",
    "assigneeId": 2,
    "priority": 2,
    "sortOrder": "0.0000000003",
    "version": 0
  }
}
```

### 2. 更新任务

**请求**
```http
PUT /api/tasks/{taskId}
Content-Type: application/json

{
  "title": "更新后的标题",
  "description": "更新后的描述",
  "priority": 3,
  "version": 1
}
```

**注意**: `version` 字段必须提交，用于并发控制。

### 3. 移动任务（拖拽）

**请求**
```http
POST /api/tasks/move
Content-Type: application/json

{
  "taskId": 1,
  "targetColumnId": 2,
  "previousOrderId": "0.0000000001",
  "nextOrderId": "0.0000000003",
  "version": 1
}
```

**参数说明**:
- `taskId`: 要移动的任务 ID
- `targetColumnId`: 目标列 ID
- `previousOrderId`: 前一个任务的 sort_order（如果没有则为 null）
- `nextOrderId`: 后一个任务的 sort_order（如果没有则为 null）
- `version`: 任务当前版本号（乐观锁）

**响应**
```json
{
  "code": 200,
  "message": "移动成功",
  "data": {
    "id": 1,
    "columnId": 2,
    "sortOrder": "0.0000000002",
    "version": 2
  }
}
```

### 4. 删除任务

**请求**
```http
DELETE /api/tasks/{taskId}
```

**响应**
```json
{
  "code": 200,
  "message": "删除成功"
}
```

---

## WebSocket API

### 连接

```
ws://localhost:8080/api/ws
```

### 订阅看板

**请求**
```
SUBSCRIBE
destination:/topic/board/{boardId}
```

### 消息格式

**任务移动事件**
```json
{
  "eventType": "TASK_MOVE",
  "boardId": 1,
  "payload": {
    "id": 1,
    "columnId": 2,
    "sortOrder": "0.0000000002"
  },
  "operatorId": 1,
  "operatorName": "张三",
  "timestamp": "2026-01-31T12:00:00"
}
```

**任务更新事件**
```json
{
  "eventType": "TASK_UPDATE",
  "boardId": 1,
  "payload": {
    "id": 1,
    "title": "更新后的标题",
    "priority": 3
  },
  "operatorId": 1,
  "operatorName": "张三",
  "timestamp": "2026-01-31T12:00:00"
}
```

**任务创建事件**
```json
{
  "eventType": "TASK_CREATE",
  "boardId": 1,
  "payload": {
    "id": 10,
    "title": "新任务",
    "columnId": 1
  },
  "operatorId": 1,
  "operatorName": "张三",
  "timestamp": "2026-01-31T12:00:00"
}
```

**任务删除事件**
```json
{
  "eventType": "TASK_DELETE",
  "boardId": 1,
  "payload": {
    "id": 1
  },
  "operatorId": 1,
  "operatorName": "张三",
  "timestamp": "2026-01-31T12:00:00"
}
```

**用户在线事件**
```json
{
  "eventType": "USER_PRESENCE",
  "boardId": 1,
  "payload": {
    "userId": 1,
    "username": "张三",
    "action": "join"
  },
  "operatorId": 1,
  "operatorName": "张三",
  "timestamp": "2026-01-31T12:00:00"
}
```

---

## 错误码

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未认证 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 409 | 版本冲突（并发修改） |
| 500 | 服务器内部错误 |

**错误响应示例**
```json
{
  "code": 409,
  "message": "任务已被其他用户修改，请刷新后重试"
}
```

---

## 示例代码

### JavaScript 示例

```javascript
// 登录
async function login(username, password) {
  const response = await fetch('http://localhost:8080/api/users/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ username, password })
  });

  const result = await response.json();
  if (result.code === 200) {
    localStorage.setItem('token', result.data.token);
    localStorage.setItem('user', JSON.stringify(result.data.user));
  }
  return result;
}

// 创建任务
async function createTask(taskData) {
  const response = await fetch('http://localhost:8080/api/tasks', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${localStorage.getItem('token')}`
    },
    body: JSON.stringify(taskData)
  });

  return await response.json();
}

// WebSocket 连接
function connectWebSocket(boardId) {
  const ws = new WebSocket('ws://localhost:8080/api/ws');

  ws.onopen = () => {
    // 订阅看板更新
    ws.send(JSON.stringify({
      command: 'SUBSCRIBE',
      destination: `/topic/board/${boardId}`
    }));
  };

  ws.onmessage = (event) => {
    const message = JSON.parse(event.body);
    console.log('收到更新:', message);

    switch (message.eventType) {
      case 'TASK_MOVE':
        handleTaskMove(message.payload);
        break;
      case 'TASK_UPDATE':
        handleTaskUpdate(message.payload);
        break;
      // ... 其他事件处理
    }
  };
}
```

---

## 更新日志

### v1.0.0 (2026-01-31)

- 初始版本
- 用户认证 API
- 看板管理 API
- 任务管理 API
- WebSocket 实时推送
