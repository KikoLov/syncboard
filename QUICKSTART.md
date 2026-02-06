# 🚀 SyncBoard 快速启动指南

## ⚡ 5 分钟快速体验

### 步骤 1: 启动服务

在 PowerShell 中执行：

```powershell
cd C:\projects\SyncBoard
& "C:\Users\赵慧楠\Desktop\宁波实训\apache-maven-3.9.9-bin\apache-maven-3.9.9\bin\vn.cmd" spring-boot:run
```

看到这个消息就成功了：

```
===================================
   🚀 SyncBoard 启动成功！
   实时协作任务平台运行中...
   WebSocket: ws://localhost:8080/api/ws
   API文档: http://localhost:8080/api
===================================
```

### 步骤 2: 打开浏览器

在浏览器中访问：

**http://localhost:8080**

### 步骤 3: 开始使用

你会看到：

1. **三列看板**：
   - To Do (待处理)
   - In Progress (进行中)
   - Done (已完成)

2. **示例任务**：
   - Design Database
   - Setup Spring Boot
   - Implement WebSocket
   - Environment Setup

3. **在线用户统计**：右上角显示当前在线人数

---

## 🎮 核心功能操作

### 创建任务

1. 点击右上角 **"+ 新建任务"** 按钮
2. 填写任务信息：
   - 标题（必填）
   - 描述（可选）
   - 所属列（必填）
   - 优先级（低/中/高）
3. 点击 **"创建"** 按钮

### 移动任务（拖拽）

1. 鼠标按住任务卡片
2. 拖拽到目标列
3. 松开鼠标
4. 任务自动移动并保存

### 删除任务

1. 点击任务卡片右下角的 🗑️ 图标
2. 确认删除

### 刷新看板

点击右上角 **🔄 刷新** 按钮重新加载数据

---

## 🎨 界面特性

### 颜色标识

- 🔴 **红色边框** = 高优先级任务
- 🟠 **橙色边框** = 中优先级任务
- 🟢 **绿色边框** = 低优先级任务

### 动画效果

- ✨ 卡片悬停上浮
- ✨ 拖拽时旋转效果
- ✨ 模态框滑入动画
- ✨ 右下角消息提示

### 响应式设计

- 💻 支持桌面浏览器
- 📱 支持移动设备

---

## 🔧 故障排除

### 问题 1: 端口被占用

**错误信息**：`Port 8080 was already in use`

**解决方法**：
```powershell
# 查找占用进程
netstat -ano | findstr :8080

# 停止进程
taskkill /F /PID <进程ID>
```

### 问题 2: 页面显示 404

**原因**：后端服务未启动

**解决方法**：
1. 检查终端是否显示启动成功
2. 确认看到 "SyncBoard 启动成功" 消息

### 问题 3: 数据加载失败

**原因**：数据库没有数据

**解决方法**：
```powershell
# 插入测试数据
"C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe" -u root -pEA7music666 -e "USE syncboard; INSERT INTO sb_board (name, description, owner_id) VALUES ('Test Board', 'Test', 1);"
```

---

## 📊 查看数据

### Druid 监控页面

访问：**http://localhost:8080/api/druid**

可以看到：
- SQL 执行统计
- 慢查询日志
- 数据库连接池状态

### 数据库查看

```bash
mysql -u root -pEA7music666 syncboard -e "SELECT * FROM sb_task;"
```

---

## 🎯 下一步

### 测试 API

使用 PowerShell 测试 API：

```powershell
# 获取看板数据
Invoke-RestMethod -Uri "http://localhost:8080/api/boards/1"

# 获取在线用户数
Invoke-RestMethod -Uri "http://localhost:8080/api/boards/1/online-count"
```

### 创建新看板

```powershell
$body = @{
    name = "我的看板"
    description = "项目描述"
    ownerId = 1
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/boards" -Method Post -Body $body -ContentType "application/json"
```

---

## 💡 专业技巧

### 1. 快速创建多个任务

利用表单的"记住上次选择"功能，快速创建相似任务。

### 2. 优先级管理

使用颜色快速识别高优先级任务，优先处理红色边框的任务。

### 3. 看板组织

- 把紧急任务放在 "To Do"
- 把进行中的任务放在 "In Progress"
- 把完成的任务移到 "Done"

---

## 📚 更多资源

- **详细文档**: [USER_GUIDE.md](USER_GUIDE.md)
- **项目摘要**: [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)
- **API 文档**: 见 USER_GUIDE.md

---

## 🆘 获取帮助

遇到问题？

1. 查看 [USER_GUIDE.md](USER_GUIDE.md) 常见问题章节
2. 检查后端控制台日志
3. 访问 Druid 监控页面查看 SQL 执行情况

---

*祝使用愉快！🎉*
